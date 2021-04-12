`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2021 09:27:24 AM
// Design Name: 
// Module Name: APB_Slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

interface I2C ();
    logic SDA, SCL, reset;
    
    task reset_slave;
        @ (negedge SCL);
        reset = 1'b1;
        @ (negedge SCL);
        reset = 1'b0;
    endtask

    modport master (input reset, inout SDA, SCL);
    modport slave (input reset, inout SDA, SCL);
endinterface

interface Memory_Bus();
    logic wren, rden, clk, ce;
    logic [7:0] wdata, rdata, addr;

    task write;

    endtask

    task read;

    endtask

    modport slave (input rdata, output wdata, wren, rden, clk, addr, ce);
    modport mem (output rdata, addr, ce, input wdata, wren, rden, clk);
endinterface 

module I2C_Slave(I2C.slave sl, Memory_Bus.slave mem, logic [7:0] id);
    logic [3:0] state;
    logic [3:0] next_state;
    parameter s_stop = 0, s_slave_address = 1, s_rw = 2, s_acknowledge_selection = 3, s_mem_address = 4, s_acknowledge_address = 5, s_read = 6, s_write = 7, s_r_acknowledge = 8, s_w_acknowledge = 9;
    logic [7:0] slave_address_buffer, mem_address_buffer, data;
    logic [2:0] counter;
    logic start;
    logic write;
    mem.clk = sl.SCL;

    //Start and Stop conditions
    always @(negedge sl.SDA) begin
        if (SCL) begin
            next_state = s_slave_address;
        end 
    end
    always @(posedge sl.SDA) begin
        if (SCL) begin
            next_state = stop;
        end 
    end

    //next state gen
    always @(*) begin
        // if (state == s_stop) begin
        //     if (start) begin
        //         next_state == s_slave_address;
        //     end
        // end else 
        if (state == s_slave_address) begin
            case (counter) 
                8:
                    begin
                        state = s_rw;
                    end
            endcase
        end else if (state == s_rw) begin
            state = s_acknowledge_selection;
        end else if (state == s_acknowledge_selection) begin
            state = s_mem_address;
        end else if (state == s_mem_address) begin
            case (counter) 
                8:
                    begin
                        next_state = s_acknowledge_address;
                    end
            endcase
        end else if (state == s_acknowledge_address) begin
            if (write) begin
                next_state <= s_write;
            end else begin
                next_state <= s_read;
            end
        end else if (state == s_write) begin
            case (counter) 
                8:
                    begin
                        next_state = s_acknowledge;
                    end
            endcase
        end else if (state == s_read) begin
            case (counter) 
                8:
                    begin
                        next_state = s_acknowledge;
                    end
            endcase
        end else if (state == s_acknowledge) begin
            if (write) begin
                next_state = s_write;
            end else begin
                next_state = s_read;
            end
        end
    end



    //state updater
    always @(posedge sl.SCL) begin
        if (sl.reset) begin
            next_state <= s_stop;
        end else begin
            state = next_state;
        end
    end
    //state actions
    always @(posedge sl.SCL) begin
        if (state == s_stop) begin
            slave_address_buffer <= 0;
            mem_address_buffer <= 0;
            data_buffer <= 0;
            counter <= 0;
        end else if (state == s_slave_address) begin
           
            slave_address_buffer[counter] <= sl.SDA;
            counter <= counter + 1;

        end else if (state == s_rw) begin
            write <= sl.SDA;
            buffer <= 0;
            counter <= 0;

        end else if (state == s_acknowledge_selection) begin
            if (slave_address_buffer == id) begin
                sl.SDA <= 0;//1 if error, 0 if ack
                counter <= 0;
            end else begin
                state == s_stop;
            end
        end else if (state == s_mem_address) begin

            mem_address_buffer[counter] <= sl.SDA;
            counter <= counter + 1;

        end else if (state == s_acknowledge_address) begin
            //first set up memory buffers as necessary, blocking
            if (write == 1'b0) begin
                mem.addr = mem_address_buffer;
                mem.rden = 1'b1;
                mem.ce = 1'b1;
                data_buffer = mem.rdata;
            end 
            //todo: check if mem address is valid
            sl.SDA <= 0;//1 if error, 0 if ack
            counter <= 0;

        end else if (state == read) begin // will be read from, slave is transmitter
            //at least one clock pulse whould have passed since s_acknowledge_addresss, so data_buffer should be updated
            mem.ce = 1'b0;
            sl.SDA = data_buffer[counter];
            counter <= counter + 1;


        end else if (state == write) begin // will be written to, slave is receiver

            data_buffer[counter] <= sl.SDA;
            counter <= counter + 1;
            if (counter == 8) begin
                mem.addr <= mem_address_buffer;
                mem.wren <= 1'b1;
                mem.ce <= 1'b1;
                mem.wdata <= data_buffer;
            end

        end else if (state == s_r_acknowledge) begin
            sl.SDA <= 0;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;

        end else if (state == s_w_acknowledge) begin
            //at least one clock pulse whould have passed since s_write, so data_buffer should be stored into memory by now
            sl.SDA <= 0;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;
            mem.ce <= 1'b0;

        end

    end
    



endmodule

module I2C_Master(I2C.master ms, input clk);

    always @(posedge clk) begin// make scl 1/2 speed of system clock
        ms.SCL = clk;
    end
    //next state gen
    always @() begin
        
    end

    //states
    always @(posedge ms.SCL) begin
        

    end

    task start;
        ms.SCL = 1'b1;
        ms.SDA = 1'b1;
        ms.SDA = 1'b0;
    endtask

    task stop;
        ms.SCL = 1'b1;
        ms.SDA = 1'b0;
        ms.SDA = 1'b1;
    endtask


endmodule


