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




 //change all if/else to case
module I2C_Master(I2C_Bus.master ms, APB_I2C_Bus apb, input clk, I2C_test_signals test);
    logic [4:0] state;
    logic [4:0] next_state, state_completed;
    parameter s_stop = 0, s_slave_address = 1, s_rw = 2, 
    s_acknowledge_selection = 3, s_mem_address = 4, s_acknowledge_address = 5, 
    s_read = 6, s_write = 7, s_r_acknowledge = 8, s_w_acknowledge = 9, s_none = 10,
    s_start = 11, s_idle = 12, s_error = 13;
    logic [7:0] slave_address, mem_address, data;
    logic [3:0] counter;
    logic [2:0] clk_pulse_counter;
    logic [1:0] x2clk_pulse_counter;
    logic reset_flag;
    
    logic ack = 0;    //flag to make sure that sda is tied low for acknowledge
    
    assign test.master_state = state;
    assign test.master_data = data;
    
    
    always @(posedge clk) begin// make scl 1/8 speed of system clock
        if (clk_pulse_counter < 3 || (clk_pulse_counter > 3 && clk_pulse_counter < 7)) begin
            clk_pulse_counter <= clk_pulse_counter + 1;
        end else if (clk_pulse_counter == 3 || clk_pulse_counter == 7) begin
            ms.SCL = ~ms.SCL;
            clk_pulse_counter <= clk_pulse_counter + 1;
        end
        
    end
    
    //combinational logic
    //acknowledge bit tying low
    always@(*) begin
        if (ack == 0) begin
            if (state == s_r_acknowledge) begin
                ms.SDA <= 0;
            end
        end
    end

    //next state gen
    always @(*) begin // need to add state_completed code
         if (apb.ce == 0 && state !== 5'bxxxxx && (state != s_idle && state != s_stop)) begin//could have errors on initialization
            next_state = s_error;
         end else if (state == s_stop && state_completed == s_stop) begin
             next_state = s_idle;
         end else if (state == s_idle) begin//may require checking other signals for validity
            if (apb.ce) begin
                 next_state = s_start;//clocked
             end
         end else if (state == s_start && state_completed == s_start) begin//need to and with completed
             next_state = s_slave_address;
             
         end else if (state == s_slave_address && state_completed == s_slave_address) begin
            case (counter) //these cases are redundant, since state completed involves checking these values
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
            ms.SCL = 1;
            clk_pulse_counter = 0;
            state = s_idle;
            next_state = s_idle;
            state_completed <= s_none;
        end else begin
            state = next_state;//blocking so it happens first
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
            end else if(x2clk_pulse_counter == 3) begin
                ms.SDA = 0;
                state_completed = s_start;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end 
                
            
        end else if (state == s_stop) begin //stop signal gen
            if (x2clk_pulse_counter == 0 && clk_pulse_counter == 6 && ms.SCL == 0) begin // making sure it starts with middle of negedge
                ms.SDA = 0;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if (x2clk_pulse_counter > 0 && x2clk_pulse_counter < 3) begin
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end else if(x2clk_pulse_counter == 3) begin
                ms.SDA = 1;
                state_completed = s_stop;
                x2clk_pulse_counter = x2clk_pulse_counter + 1;
            end 
        end else if (state == s_error) begin
            apb.error <= 1;
            next_state <= s_idle;
        end
        
    end
    //state actions on posedge SCL
    //read SDA on posedge
    always @(posedge ms.SCL) begin//state completed needs to work only on
        if (state == s_idle) begin
            ms.SDA <= 1; //data line released
            slave_address <= 0;
            mem_address <= 0;
            apb.error <= 0;
            x2clk_pulse_counter <= 0;
        end else if (state == s_stop) begin // need to check if i need stop or idle or both
            //no apb ready signal, need to time correctly
        end else if (state == s_start) begin
            slave_address <= apb.addr[7:6];
            mem_address <= apb.addr[5:0];
            if (apb.wren) begin
                data <= apb.wdata;
            end else begin
                data <= 0;
            end
            counter <= 0;
            
        end else if (state == s_slave_address) begin
            x2clk_pulse_counter = 0;
            if (counter == 8) begin
                state_completed <= s_slave_address;
            end
        end else if (state == s_rw) begin
            state_completed <= s_rw;//making sure state continues through a positive edge
        end else if (state == s_acknowledge_selection) begin
            if (ms.SDA == 1) begin //if no acknowledge
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_acknowledge_selection;
            end
            counter <= 0;
            
        end else if (state == s_mem_address) begin
            if (counter == 8) begin
                state_completed <= s_mem_address;
            end
        end else if (state == s_acknowledge_address) begin
            //first set up memory buffers as necessary, blocking
            if (ms.SDA == 1) begin //if no acknowledge, error
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_acknowledge_address;
            end
            counter <= 0;

        end else if (state == s_read) begin // will be read from, slave is transmitter
            //at least one clock pulse whould have passed since s_acknowledge_addresss, so data_buffer should be updated
            data[7 - counter] <= ms.SDA;
            //mem.ce = 1'b0;
            counter <= counter + 1;
            //perhaps send signal to apb when done?
            //can also be accomplished by having correct timing, determined by processor and told to apb

        end else if (state == s_write) begin
            if (counter == 8) begin
                state_completed <= s_write;
            end
        end else if (state == s_r_acknowledge) begin
            state_completed <= s_r_acknowledge;
        end else if (state == s_w_acknowledge) begin
            //1 if error, 0 if ack
            if (ms.SDA == 1) begin //if no acknowledge //error occurrs, probably do not want a ready signal being sent
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
            end else begin
                state_completed <= s_w_acknowledge;
            end
            counter <= 0;
            //apb timing needs to line up here for write ops
        end
        
        ack <= 1; // making sure acknowledge only affects data at proper time
    end
    //state actions on negedge SCL
    //write to SDA on negedge
    always @ (negedge ms.SCL) begin
     if (state == s_acknowledge_selection) begin
            ms.SDA = 1; $display ("1"); //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            
            counter <= 0;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end else if (state == s_slave_address) begin
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
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end else if (state == s_rw) begin
            ms.SDA <= apb.rden;
            if (apb.wren) begin
                data <= apb.wdata;
            end else begin
                data <= 0;
            end
            counter <= 0;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end  else if (state == s_mem_address) begin
            ms.SDA = mem_address[7 - counter];
            counter <= counter + 1;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end else if (state == s_acknowledge_address) begin
            ms.SDA = 1; //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            counter <= 0;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end else if (state == s_write) begin // will be written to, slave is receiver
            ms.SDA <= data[7 - counter];
            counter <= counter + 1;

            ack <= 1; // making sure acknowledge only affects data at proper time
        end else if (state == s_r_acknowledge) begin
            if (data[0] !== 1'bx && data[1] !== 1'bx && data[2] !== 1'bx && data[3] !== 1'bx
            && data[4] !== 1'bx && data[5] !== 1'bx && data[6] !== 1'bx && data[7] !== 1'bx) begin
                ms.SDA <= 0;//1 if error, 0 if ack
                ack <= 0;//1 if error, 0 if ack
                apb.rdata <= data;
                //apb timing needs to line up here for read ops
            end else begin//error occurrs, probably do not want a ready signal being sent
                
                state <= s_error;
                next_state <= s_error;
                state_completed <= s_none;
                
                ack <= 1; // making sure acknowledge only affects data at proper time
            end
            counter <= 0;
            //apb timing needs to line up here for end of read ops
        end else if (state == s_w_acknowledge) begin
            ms.SDA = 1; //release clock to be high, wait for acknowledge, needs to be blocking so occurs before slave acknowledge
            counter <= 0;
            
            ack <= 1; // making sure acknowledge only affects data at proper time
        end
    end

    


endmodule