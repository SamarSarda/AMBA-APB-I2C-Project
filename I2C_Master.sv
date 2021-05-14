`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2021 01:56:13 AM
// Design Name: 
// Module Name: I2C_Master
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




module I2C_Master(I2C_Bus.master ms, APB_I2C_Bus apb, input clk);
    
    logic [7:0] slave_address, mem_address, data; // data registers
    logic [3:0] counter; //for counting number of bits sent accross SDA
    logic [2:0] clk_pulse_counter; // counts 4 clk pulses, then toggles SCL
    logic [1:0] x2clk_pulse_counter; // second clock counter, used for timing start and stop conditions
    logic reset_flag; // used for re-start conditions
    logic ready_flag; // used to time apb_bus.ready 
    
    ///states
    logic [4:0] state;
    logic [4:0] next_state, state_completed;//state_completed for making sure state continues through a positive edge
    parameter s_stop = 0, s_slave_address = 1, s_rw = 2, 
    s_acknowledge_selection = 3, s_mem_address = 4, s_acknowledge_address = 5, 
    s_read = 6, s_write = 7, s_r_acknowledge = 8, s_w_acknowledge = 9, s_none = 10,
    s_start = 11, s_idle = 12, s_error = 13;
    
    
    
    always @(posedge clk) begin// make scl 1/8 speed of system clock
        if (clk_pulse_counter < 3 || (clk_pulse_counter > 3 && clk_pulse_counter < 7)) begin
            clk_pulse_counter <= clk_pulse_counter + 1;
        end else if (clk_pulse_counter == 3 || clk_pulse_counter == 7) begin
            ms.SCL = ~ms.SCL;
            clk_pulse_counter <= clk_pulse_counter + 1;
        end
        
    end
    
    
    //combinational logic

    //next state gen
    always @(*) begin
         if (apb.ce == 0 && state !== 5'bxxxxx && (state != s_idle && state != s_stop)) begin
            next_state = s_error;
         end else if (state == s_stop && state_completed == s_stop) begin
             next_state = s_idle;
         end else if (state == s_idle && state_completed == s_idle) begin
            if (apb.ce) begin
                 next_state = s_start;
             end
         end else if (state == s_start && state_completed == s_start) begin
             next_state = s_slave_address;
             
         end else if (state == s_slave_address && state_completed == s_slave_address) begin
            case (counter)
                8:
                    begin
                   
                        next_state = s_rw;
                    end
            endcase
        end else if (state == s_rw && state_completed == s_rw) begin
            next_state = s_acknowledge_selection;
        end else if (state == s_acknowledge_selection && state_completed == s_acknowledge_selection) begin
            next_state = s_mem_address;
        end else if (state == s_mem_address && state_completed == s_mem_address) begin
            case (counter) 
                8:
                    begin
                        next_state = s_acknowledge_address;
                    end
            endcase
        end else if (state == s_acknowledge_address && state_completed == s_acknowledge_address) begin
            if (apb.rden) begin
                next_state = s_read;
            end else begin
                next_state = s_write;
            end
        end else if (state == s_write && state_completed == s_write) begin
            case (counter) 
                8:
                    begin
                        next_state = s_w_acknowledge;
                    end
            endcase
        end else if (state == s_read) begin
            case (counter) 
                8:
                    begin
                        next_state = s_r_acknowledge;
                    end
            endcase
        end else if (state == s_w_acknowledge && state_completed == s_w_acknowledge) begin
                next_state = s_stop; // could be expanded to allow longer transfers would need apb to have larger data register
        end else if (state == s_r_acknowledge && state_completed == s_r_acknowledge) begin
                next_state = s_stop; // could be expanded to allow longer transfers would need apb to have larger data register
        end
    end


    //state functions

    //loosely a mirror of I2C_slave's state functions
    
    //read SDA on posedge SCL
    //write to SDA on negedge SCL
    //for the purpose of following I2C standard on writing only when SCL low
    //also allows signals to stabilize by the time SCL is high, allowing master and slave to read properly
    
    //state updater
    always @(posedge clk) begin
        if (ms.reset) begin
            ready_flag <= 0;
            ms.SCL <= 1;
            clk_pulse_counter <= 0;
            state <= s_idle;
            next_state <= s_idle;
            state_completed <= s_none;
        end else begin
            state = next_state;
        end
    end
    
    //state actions on clk
    //for the purpose of generating start and stop signals
    //as well as entering the error state
    always @(posedge clk) begin
        
        if (state == s_start) begin //start signal gen
            
            if (x2clk_pulse_counter == 0 && clk_pulse_counter == 6 && ms.SCL == 0) begin // making sure it starts with middle of negedge
                ms.SDA = 1;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if (x2clk_pulse_counter > 0 && x2clk_pulse_counter < 3) begin
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if(x2clk_pulse_counter == 3) begin //toggle occurs in middle of posedge SCL
                ms.SDA = 0;
                state_completed = s_start;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end 
                apb.ready <= 0;
            
        end else if (state == s_stop) begin //stop signal gen
            if (x2clk_pulse_counter == 0 && clk_pulse_counter == 6 && ms.SCL == 0) begin // making sure it starts with middle of negedge
                ms.SDA = 0;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if (x2clk_pulse_counter > 0 && x2clk_pulse_counter < 3) begin
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if(x2clk_pulse_counter == 3) begin //toggle occurs in middle of posedge SCL
                ms.SDA = 1;
                state_completed = s_stop;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end 
            
            if (ready_flag) begin
                apb.ready <= 1;
                ready_flag <= 0;
                
            end else begin
                apb.ready <= 0;
            end
           
        end else if (state == s_error) begin //used to report errors
            apb.error <= 1;
            next_state <= s_idle;
            state_completed <= s_none;
        end else if (state == s_idle) begin //used to reser signals while idle
            ms.SDA <= 1; //data line released
            slave_address <= 0;
            mem_address <= 0;
            apb.error <= 0;
            x2clk_pulse_counter <= 0;
            state_completed <= s_idle;
            apb.ready <= 0;
        end 
        
    end
   
    //state actions on posedge SCL
    //read SDA on posedge
    always @(posedge ms.SCL) begin
        if (state == s_stop) begin 
        end else if (state == s_start) begin //master starts
            slave_address <= apb.addr[7:6];
            mem_address <= apb.addr[5:0];
            if (apb.wren) begin
                data <= apb.wdata;
            end else begin
                data <= 0;
            end
            counter <= 0; 
        end else if (state == s_slave_address) begin //master done sending slave address
            x2clk_pulse_counter = 0; //reset for next use of start/stop conditions
            if (counter == 8) begin
                state_completed <= s_slave_address;
            end
        end else if (state == s_rw) begin //master done sending r/w bit
            state_completed <= s_rw;
        end else if (state == s_acknowledge_selection) begin //slave acknowledges being selected
            if (ms.SDA == 1) begin //if no acknowledge, error
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_acknowledge_selection;
            end
            counter <= 0;
        end else if (state == s_mem_address) begin //master done sending mem address
            if (counter == 8) begin
                state_completed <= s_mem_address;
            end
        end else if (state == s_acknowledge_address) begin //slave confirms that it got the data for the mem address
            if (ms.SDA == 1) begin //if no acknowledge, error
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_acknowledge_address;
            end
            counter <= 0;
        end else if (state == s_read) begin // will be read from, slave is transmitter
            data[7 - counter] <= ms.SDA;
            counter <= counter + 1;
        end else if (state == s_write) begin
            if (counter == 8) begin
                state_completed <= s_write;
            end
        end else if (state == s_r_acknowledge) begin //master acknowledges receiving data
            state_completed <= s_r_acknowledge;
            ready_flag <= 1;
        end else if (state == s_w_acknowledge) begin //slave acknowledges writing data data
            //1 if error, 0 if ack
            if (ms.SDA == 1) begin //if no acknowledge error occurrs
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_w_acknowledge;
                ready_flag <= 1;
            end
            counter <= 0;
        end
    end
    //state actions on negedge SCL
    //write to SDA on negedge
    always @ (negedge ms.SCL) begin
     if (state == s_acknowledge_selection) begin //slave acknowledges being selected
            //ms.SDA = 1; //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            counter <= 0;
        end else if (state == s_slave_address) begin //master sends slave address one bit at a time on SDA
            x2clk_pulse_counter = 0;
            if (reset_flag) begin
                slave_address <= apb.addr[7:6];
                mem_address <= apb.addr[5:0];
                if (apb.wren) begin
                    data <= apb.wdata;
                end else begin
                    data <= 0;
                end
                counter <= 1;
                reset_flag <= 0;
                ms.SDA <= slave_address[7 - counter];
            end else begin
                ms.SDA <= slave_address[7 - counter];
                counter <= counter + 1;
            end
        end else if (state == s_rw) begin //send read/write bit
            ms.SDA <= apb.rden;
            if (apb.wren) begin
                data <= apb.wdata;
            end else begin
                data <= 0;
            end
            counter <= 0;
        end  else if (state == s_mem_address) begin //master sends mem address one bit at a time on SDA
            ms.SDA = mem_address[7 - counter];
            counter <= counter + 1;
        end else if (state == s_acknowledge_address) begin //slave confirms that it got the data for the mem address
            ms.SDA = 1; //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            counter <= 0;
        end else if (state == s_write) begin //master sends write address one bit at a time on SDA
            ms.SDA <= data[7 - counter];
            counter <= counter + 1;
        end else if (state == s_r_acknowledge) begin //master acknowledges receiving data
            if (data[0] !== 1'bx && data[1] !== 1'bx && data[2] !== 1'bx && data[3] !== 1'bx
            && data[4] !== 1'bx && data[5] !== 1'bx && data[6] !== 1'bx && data[7] !== 1'bx) begin
                ms.SDA <= 0;//1 if error, 0 if ack
                apb.rdata <= data;
            end else begin//error occurrs
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end
            counter <= 0;
        end else if (state == s_w_acknowledge) begin //slave acknowledges receiving write data
            ms.SDA = 1; //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            counter <= 0;
        end
    end

    


endmodule