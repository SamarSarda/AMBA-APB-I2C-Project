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


module APB_Slave(APB_Bus.slave sl, Memory_Bus.slave msl, input logic [1:0] id, input logic clk); // fix next state logic
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_write = 1, s_read = 2, s_write_done=3, s_read_done=4;
    logic [7:0] cycles_remaining;
    //assign msl.clk = sl.clk; // do exterally
    //so in states
    //assign msl.addr = sl.addr;
    //assign msl.wdata = sl.wdata;
    //assign sl.rdata = msl.rdata;
    //assign sl.ready = msl.ready;
    //assign sl.ready = ready;
    //assign msl.ce = sl.enable; //done in states kind of, no reliance on sl
    
    //combinational logic
    //attached device setting ready if it wants to have control of it
    //otherwise, apb slave ties it high always
//    always @(*) begin
//        if (msl.ready === 1) begin
//            ready = 1;
//        end else if (msl.ready === 0) begin
//            ready = 0;
//        end
        
//    end
    
    //States
    always @(*) begin
         if (state == s_idle) begin
            case ({sl.sel, sl.write}) 
                3'b000: 
                    begin
                        next_state <= s_idle;
                    end
                3'b001: 
                    begin 
                        next_state <= s_idle;
                    end
                {id, 1'b0}: 
                    begin
                            next_state <= s_read;
                    end 
                {id, 1'b1}:
                    begin
                            next_state <= s_write;

                    end 
            endcase
        end else if (state == s_write) begin
            if (msl.ready) begin // wait until attached device is ready
                next_state <= s_idle;
            end
        end else if (state == s_read) begin
            if (msl.ready) begin
                next_state <= s_idle;
                
            end
        end
        
    end
    
    
    always @(posedge sl.clk) begin
        if (sl.reset) begin
            state = s_idle;
            next_state = s_idle; 
            //msl.ready <= 1'b1;
        end else begin
            state = next_state;
        end
    end
    //Control Signals
    always @(posedge sl.clk) begin
        if (state == s_idle) begin
            //msl.ready <= 1'b1;//tie ready high while enable is low, 
            //so that attached device can tie low if necessary, but doesnt need to if no wait states
            msl.wren <= 1'b0;
            msl.rden <= 1'b0;
            sl.ready <= 0;
            msl.ce <= 1;
        end else if (state == s_write) begin
           msl.wdata <= sl.wdata;
            msl.addr <= sl.addr;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;
            msl.ce <= 1;
            if (msl.ready) begin
                sl.ready <= 1;
            end
        end else if (state == s_read) begin
            msl.addr <= sl.addr;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
            msl.ce <= 1;
            if (msl.ready) begin
                sl.rdata <= msl.rdata;
                sl.ready <= 1;
            end
        end
        
    end
    
endmodule