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

interface APB (input logic clk);
    logic write, ready, enable, reset;
    logic [7:0] wdata, rdata, addr, waits;
    logic sel;

    task reset_slave;
        @ (negedge clk);
        reset = 1'b1;
        @ (negedge clk);
        reset = 1'b0;
    endtask
    
    modport master (input clk, ready, rdata, output write, sel, wdata, enable, waits, addr);
    modport slave (input clk, write, sel, wdata, enable, reset, waits, addr, output ready, rdata);
endinterface

interface Memory_Bus();
    logic wren, rden, clk;
    logic [7:0] wdata, rdata, addr;

    modport slave (input rdata, output wdata, wren, rden, clk, addr);
    modport mem (output rdata, addr, input wdata, wren, rden, clk);
endinterface 

module APB_Slave(APB.slave sl, Memory_Bus.slave msl);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_write = 1, s_read = 2, s_write_done=3, s_read_done=4;
    logic [7:0] cycles;
    assign msl.clk = sl.clk;
    assign msl.addr = sl.addr;
    assign msl.wdata = sl.wdata;
    
     //Control Signals
    always @(posedge sl.clk) begin
        state = next_state;
        if (state == s_idle) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b0;
            msl.rden <= 1'b0;
        end else if (state == s_write) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;         
        end else if (state == s_read) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
        end else if (state == s_write_done) begin
            sl.ready <= 1'b1;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;
        end else if (state == s_read_done) begin
            sl.ready <= 1'b1;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
        end 
        
    end
    
    //States
    always @(negedge sl.clk) begin
        if (state == s_idle) begin
            case ({sl.sel, sl.write}) 
                2'b00: 
                    begin
                        next_state <= s_idle;
                    end
                2'b01: 
                    begin 
                        next_state <= s_idle;
                    end
                2'b10: 
                    begin
                        if (sl.waits > 0) begin
                            next_state <= s_read;
                            cycles <= sl.waits;
                        end else begin
                            next_state <= s_read_done;
                        end 
                    end 
                2'b11:
                    begin
                        if (sl.waits > 0) begin
                            next_state <= s_write;
                            cycles <= sl.waits;
                        end else begin
                            next_state <= s_write_done;
                        end

                    end 
            endcase
        end else if (sl.reset) begin
            next_state <= s_idle;
        end else if (state == s_write) begin
            if (cycles > 1) begin
                cycles = cycles - 1'b1;
            end else begin
                next_state <= s_write_done;
            end
        end else if (state == s_read) begin
            if (cycles > 1) begin
                cycles = cycles - 1'b1;
            end else begin
                next_state <= s_read_done;
            end
        end else if (state == s_write_done) begin
                next_state <= s_idle;
        end else if (state == s_read_done) begin
                next_state <= s_idle;
        end
        
    end
    
   
    
endmodule
