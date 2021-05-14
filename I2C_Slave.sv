`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2021 04:33:05 PM
// Design Name: 
// Module Name: I2C_Slave
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


module I2C_Slave(I2C_Bus.slave sl, 
 I2C_Memory_Bus.slave mem, 
 input logic [7:0] id,
 input logic clk);//id can be 2 bits
 
    logic [7:0] slave_address_buffer, mem_address_buffer, data_buffer;//store data during transfers
    logic [3:0] counter;//counts number of bits when reading/writing data from/to SDA
    
    //states
    logic [3:0] state;
    logic [3:0] next_state, state_completed;
    parameter s_stop = 0, s_slave_address = 1, s_rw = 2, 
    s_acknowledge_selection = 3, s_mem_address = 4, s_acknowledge_address = 5, 
    s_read = 6, s_write = 7, s_r_acknowledge = 8, s_w_acknowledge = 9, s_none = 10, s_error = 11;
    
    logic read;//1 if read transfer, 0 if write transfer
    
    //for keeping track of start/stop conditions
    logic oldSCL; 
    logic oldSDA;
    
    logic selected; // if slave acknowledges selection
    logic rejected;
    
    logic reset_flag;//flag for resetting values when there is a re-start condition
    logic write_flag;//flag to time writing to memory once data is stable, if 0, memory will not be written to
    
    
    
    //Start and Stop conditions
    always @(posedge clk) begin 
        oldSCL <= sl.SCL;
    end
    always @(posedge clk) begin//store previous SDA value
        oldSDA <= sl.SDA;
    end
    
    //start condition
    always @(posedge clk) begin 
        if (sl.SCL && oldSCL && (oldSDA == 1 && sl.SDA == 0)) begin //negedge      
            next_state <= s_slave_address;
            reset_flag <= 1; 
            //reset_flag makes sure that the i2c resets values 
            //in the case of a re-start condition as opposed to stop then start
        end
        
    end
    //stop condition
    always @(posedge clk) begin
        if (sl.SCL && oldSCL && (oldSDA == 0 && sl.SDA == 1)) begin //posedge
            next_state <= s_stop;
        end 
    end
    
    //combinational logic

    //next state gen
    always @(*) begin
        if (state == s_slave_address) begin
            case (counter) 
                8:
                    begin
                        next_state <= s_rw;
                    end
            endcase
        end else if (state == s_rw && state_completed == s_rw) begin
                next_state <= s_acknowledge_selection;
        end else if (state == s_acknowledge_selection && state_completed == s_acknowledge_selection) begin
            if (selected) begin
                next_state <= s_mem_address;
            end
             if (rejected) begin
                next_state = s_stop;
            end
        end else if (state == s_mem_address) begin
            case (counter) 
                8:
                    begin
                        next_state <= s_acknowledge_address;
                    end
            endcase
        end else if (state == s_acknowledge_address && state_completed == s_acknowledge_address) begin
            if (read) begin
                next_state <= s_read;
            end else begin
                next_state <= s_write;
            end
        end else if (state == s_write) begin
            case (counter) 
                8:
                    begin
                        next_state <= s_w_acknowledge;
                    end
            endcase
        end else if (state == s_read && state_completed == s_read) begin
            case (counter) 
                8:
                    begin
                        next_state <= s_r_acknowledge;
                    end
            endcase
        end else if (state == s_w_acknowledge && state_completed == s_w_acknowledge) begin
                next_state <= s_write; // could be expanded to allow longer transfers would need apb to have larger data register
        end else if (state == s_r_acknowledge && state_completed == s_r_acknowledge) begin
                next_state <= s_read; // could be expanded to allow longer transfers would need apb to have larger data register
        end
    end


    //states involved in sending signals occur on the negedge
    //state updater
    always @(posedge sl.SCL or negedge sl.SCL) begin
        if (sl.reset) begin
            state <= s_stop;
            next_state <= s_stop;
            state_completed <= s_none;
            reset_flag <= 1;
            write_flag <= 0;
            selected <= 0;
            rejected <= 0;
        end else begin
            state = next_state;
        end
    end
    
    //state actions posedge (take data inputs, do not send data)
    always @(posedge sl.SCL) begin
        if (state == s_stop) begin //idle state
            slave_address_buffer <= 0;
            mem_address_buffer <= 0;
            data_buffer <= 0;
            counter <= 0;
            mem.ce <= 1'b0;
            mem.wren <= 1'b0;
            mem.rden <= 1'b0;
            state_completed <= s_stop;
        end else if (state == s_slave_address) begin //start, sets/resets initial signals
            if (reset_flag) begin //re-start condition 
                slave_address_buffer <= 0;
                mem_address_buffer <= 0;
                data_buffer <= 0;
                counter <= 1;
                mem.ce <= 1'b0;
                mem.wren <= 1'b0; 
                mem.rden <= 1'b0;
                reset_flag <= 0; 
                selected <= 0;
                rejected <= 0;
                slave_address_buffer[7 - counter] <= sl.SDA;    
            end else begin
                counter <= counter + 1;
                slave_address_buffer[7 - counter] <= sl.SDA;
            end       
        end else if (state == s_rw) begin //read or write transfer
            read <= sl.SDA;
            data_buffer <= 0;
            counter <= 0;
            state_completed <= s_rw;
        end else if (state == s_acknowledge_selection) begin //slave acknowledges being selected
            state_completed <= s_acknowledge_selection;
        end else if (state == s_mem_address) begin //slave reads memory adress
            mem_address_buffer[7 - counter] <= sl.SDA;
            counter <= counter + 1;
        end else if (state == s_acknowledge_address) begin //slave acknowledges receiving memory adress
            state_completed <= s_acknowledge_address;
        end else if (state == s_read) begin  // will be read from, slave is transmitter
            if (counter == 8) begin
                state_completed <= s_read;
            end
        end else if (state == s_write) begin // will be written to, slave is receiver 
            data_buffer[7 - counter] = sl.SDA;
            counter = counter + 1;
            if (counter == 8) begin
                mem.addr <= mem_address_buffer;
                mem.wren <= 1'b1;
                mem.ce <= 1'b1;
                write_flag <= 1;
                mem.wdata <= data_buffer;
                
            end else if (write_flag == 0) begin
                mem.ce = 1'b0;
                mem.wren <= 1'b0;
            end
        end else if (state == s_r_acknowledge) begin //master acknowledges receiving data
            if (sl.SDA == 0) begin
                state_completed <= s_r_acknowledge;
            end else begin // master does not acknowledge, error occurs, should be handled by the master, no need to pass signal
                state <= s_stop;
                next_state <= s_stop;
                state_completed <= s_none;
            end
            
        end else if (state == s_w_acknowledge) begin //slave acknowledges writing data
            state_completed <= s_w_acknowledge;
        end
    end
    
    //state actions negedge (send data, do not take data inputs)
    always @(negedge sl.SCL) begin
        if (state == s_acknowledge_selection) begin //slave acknowledges being selected
            if (slave_address_buffer == id) begin
                sl.SDA <= 0;//1 if error, 0 if ack
                counter <= 0;
                selected <= 1;
                rejected <= 0;
            end else begin
                selected <= 0;
                rejected <= 1;
                state <= s_stop;
                next_state <= s_stop;
                state_completed <= s_none;
            end
        end else if (state == s_acknowledge_address) begin //slave confirms that it got the data for the mem address
            if (read == 1'b1) begin  
                mem.addr <= mem_address_buffer;
                mem.rden <= 1'b1;
                mem.ce <= 1'b1;
            end 
            sl.SDA <= 0;//1 if error, 0 if ack
            counter <= 0;
        end else if (state == s_read) begin // will be read from, slave is transmitter
            //at least one clock pulse whould have passed since s_acknowledge_addresss, so data_buffer should be updated
            data_buffer <= mem.rdata;
            sl.SDA <= data_buffer[7 - counter];
            counter <= counter + 1;
        end else if (state == s_r_acknowledge) begin //master acknowledges receiving data
            //should be done by master
            //so we write SDA high amd make sure the master sets it low on posedge
            //in order to make sure that timing works out, since both master and lsave would set
            //SDA on negedge, slave's SDA set needs to be blocking to ensure it happens first
            sl.SDA <= 1;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;
            mem.ce <= 1'b0;
            mem.rden <= 1'b0;
        end else if (state == s_w_acknowledge) begin //slave acknowledges writing data
            //data_buffer should be stored into memory by now
            sl.SDA <= 0;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;
            write_flag <= 0;
            
        end
    end


endmodule
