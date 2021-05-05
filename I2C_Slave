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
 input logic clk,
 I2C_test_signals test);//id can be 2 bits
 
    logic [3:0] state;
    logic [3:0] next_state, state_completed;
    parameter s_stop = 0, s_slave_address = 1, s_rw = 2, 
    s_acknowledge_selection = 3, s_mem_address = 4, s_acknowledge_address = 5, 
    s_read = 6, s_write = 7, s_r_acknowledge = 8, s_w_acknowledge = 9, s_none = 10, s_error = 11;
    logic [7:0] slave_address_buffer, mem_address_buffer, data_buffer;
    logic [3:0] counter;
    
    logic start;
    logic read;
    //assign slave_address_buffer_m = slave_address_buffer;
    
    //for keeping track of start/stop conditions
    logic oldSCL; 
    logic oldSDA;
    
    logic selected = 0;
    logic rejected = 0;
 
    assign mem.clk = sl.SCL;
    
    logic reset_flag = 1;
    logic write_flag = 0;
    logic ack = 0;    //flag to make sure that sda is tied low for acknowledge
    
    //test output signals
    assign test.slave_state = state;
    assign test.slave_data = data_buffer;
    assign test.slave_select = slave_address_buffer;
    assign test.slave_mem_address = mem_address_buffer;
    
    
    //Start and Stop conditions
    always @(posedge clk) begin 
        oldSCL <= sl.SCL;
    end
    always @(posedge clk) begin//store previous SDA value
        oldSDA <= sl.SDA;
    end
    
    //start condition
    always @(posedge clk) begin // change to clock as condition
        //slave_address_buffer_m <= {reset_flag, oldSCL, oldSDA, sl.SCL, sl.SDA};
        if (sl.SCL && oldSCL && (oldSDA == 1 && sl.SDA == 0)) begin //negedge
                    
            next_state <= s_slave_address;//try to make all assignments non-blocking
            reset_flag <= 1;
        end
        
    end
    //stop condition
    always @(posedge clk) begin // change to clock as condition
        if (sl.SCL && oldSCL && (oldSDA == 0 && sl.SDA == 1)) begin //posedge
            next_state <= s_stop;//try to make all assignments non-blocking
        end 
    end
    
    //combinational logic
    //acknowledge bit tying low
    always@(*) begin
        if (ack == 0) begin
            if (state == s_acknowledge_selection || state == s_acknowledge_address || state == s_w_acknowledge) begin
                sl.SDA <= 0;
            end
        end
    end
    
    //next state gen
    always @(*) begin
        //slave_address_buffer_m <= {reset_flag, oldSCL, oldSDA, sl.SCL, sl.SDA};
        // if (state == s_stop) begin
        //     if (start) begin
        //         next_state == s_slave_address;
        //     end
        // end else 
        //slave_address_buffer_m <= counter;
        //slave_address_buffer_m <= sl.SDA;
        //slave_address_buffer_m = state_completed;
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
                //slave_address_buffer_m <= slave_address_buffer;
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


    //need some states to work on negedge, since signals can opnly be set during negedge
    //state updater
    always @(posedge sl.SCL or negedge sl.SCL) begin
        if (sl.reset) begin
            state <= s_stop;
            next_state <= s_stop;
            state_completed <= s_none;
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
        end else if (state == s_slave_address) begin //re-start condition working
            if (reset_flag) begin
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
        end else if (state == s_rw) begin
            read <= sl.SDA;
            data_buffer <= 0;
            counter <= 0;
            state_completed <= s_rw;
        end else if (state == s_acknowledge_selection) begin
            state_completed <= s_acknowledge_selection;
        end else if (state == s_mem_address) begin
            mem_address_buffer[7 - counter] <= sl.SDA;
            counter <= counter + 1;
        end else if (state == s_acknowledge_address) begin
            state_completed <= s_acknowledge_address;
        end else if (state == s_read) begin
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
        end else if (state == s_r_acknowledge) begin
            if (sl.SDA == 0) begin
                state_completed <= s_r_acknowledge;
            end else begin // master does not acknowledge, error occurs, should be handled by the master, no need to pass signal
                state <= s_stop;
                next_state <= s_stop;
                state_completed <= s_none;
            end
            
        end else if (state == s_w_acknowledge) begin
            state_completed <= s_w_acknowledge;
        end
        
        ack <= 1; // making sure acknowledge only affects data at proper time
        
    end
    
    //state actions negedge (send data, do not take data inputs)
    
    always @(negedge sl.SCL) begin
        if (state == s_acknowledge_selection) begin
            if (slave_address_buffer == id) begin
                
                sl.SDA <= 0;//1 if error, 0 if ack
                ack <= 0;//1 if error, 0 if ack
                counter <= 0;
                selected <= 1;
                rejected <= 0;
            end else begin
                ack <= 1;//1 if error, 0 if ack
                selected <= 0;
                rejected <= 1;
                state <= s_stop;
                next_state <= s_stop;
                state_completed <= s_none;
            end
            
        end else if (state == s_acknowledge_address) begin
            //first set up memory buffers as necessary, blocking
            if (read == 1'b1) begin
                
                mem.addr <= mem_address_buffer;
                mem.rden <= 1'b1;
                mem.ce <= 1'b1;
                
                //data_buffer = mem.rdata;
            end 
            
            //todo: check if mem address is valid
            sl.SDA <= 0;//1 if error, 0 if ack
            ack = 0;//1 if error, 0 if ack
            counter <= 0;

        end else if (state == s_read) begin // will be read from, slave is transmitter
            //at least one clock pulse whould have passed since s_acknowledge_addresss, so data_buffer should be updated
            data_buffer <= mem.rdata;
            
            //mem.ce = 1'b0;
            sl.SDA <= data_buffer[7 - counter];
            counter <= counter + 1;
            ack <= 1; // making sure acknowledge only affects data at proper time


        end else if (state == s_r_acknowledge) begin
            //should be done by master
            //so we write SDA high amd make sure the master sets it low on posedge
            //in order to make sure that timing works out, since both master and lsave would set
            //SDA on negedge, slave's SDA set needs to be blocking to ensure it happens first
            sl.SDA = 1;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;
            mem.ce <= 1'b0;
            mem.rden <= 1'b0;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
           
        end else if (state == s_w_acknowledge) begin
            //data_buffer should be stored into memory by now
            sl.SDA <= 0;//1 if error, 0 if ack
            ack <= 0;//1 if error, 0 if ack
            data_buffer <= 0;
            counter <= 0;
            write_flag <= 0;
            
        end
    end


endmodule
