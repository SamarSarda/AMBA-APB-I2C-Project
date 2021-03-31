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
    logic [7:0] wdata, rdata, addr, wait_cycles;
    logic sel;

    task reset_slave;
        @ (negedge clk);
        reset = 1'b1;
        @ (negedge clk);
        reset = 1'b0;
    endtask
    
    modport master (input clk, ready, rdata, output write, sel, wdata, enable, wait_cycles, addr);
    modport slave (input clk, write, sel, wdata, enable, reset, wait_cycles, addr, output ready, rdata);
endinterface

interface Memory_Bus();
    logic wren, rden, clk;
    logic [7:0] wdata, rdata, addr;

    modport slave (input rdata, output wdata, wren, rden, clk, addr);
    modport mem (output rdata, addr, input wdata, wren, rden, clk);
endinterface 

interface Processor_Bus();
    logic write, clk, reset, sel, ready;
    logic [7:0] wdata, rdata, addr;

    modport processor (input clk, rdata, ready, output write, sel, reset, addr, wdata);
    modport master (input clk, write, sel, reset, addr, wdata, output, rdata, ready);
endinterface

module APB_Slave(APB.slave sl, Memory_Bus.slave msl);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_write = 1, s_read = 2, s_write_done=3, s_read_done=4;
    logic [7:0] cycles_remaining;
    assign msl.clk = sl.clk;
    assign msl.addr = sl.addr;
    assign msl.wdata = sl.wdata;

    //States
    always @(negedge sl.clk) begin
        if (sl.reset) begin
            next_state <= s_idle;
        end else if (state == s_idle) begin
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
                        if (sl.wait_cycles > 0) begin
                            next_state <= s_read;
                            cycles_remaining <= sl.wait_cycles;
                        end else begin
                            next_state <= s_read_done;
                        end 
                    end 
                2'b11:
                    begin
                        if (sl.wait_cycles > 0) begin
                            next_state <= s_write;
                            cycles_remaining <= sl.wait_cycles;
                        end else begin
                            next_state <= s_write_done;
                        end

                    end 
            endcase
        end else if (state == s_write) begin
            if (cycles_remaining > 1) begin
                cycles_remaining = cycles_remaining - 1'b1;
            end else begin
                next_state <= s_write_done;
            end
        end else if (state == s_read) begin
            if (cycles_remaining > 1) begin
                cycles_remaining = cycles_remaining - 1'b1;
            end else begin
                next_state <= s_read_done;
            end
        end else if (state == s_write_done) begin
                next_state <= s_idle;
        end else if (state == s_read_done) begin
                next_state <= s_idle;
        end
        
    end
    
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
    
endmodule


module APB_Master(APB.master ms, Processor_Bus.master pm);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_setup = 1, s_access = 2;
    logic [7:0] cycles_remaining;
    assign msl.clk = sl.clk;
    assign msl.addr = sl.addr;
    assign msl.wdata = sl.wdata;

    //States
    always @(negedge sl.clk) begin
        if (sl.reset) begin
            next_state <= s_idle;
        end else if (state == s_idle) begin
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
                        if (sl.wait_cycles > 0) begin
                            next_state <= s_read;
                            cycles_remaining <= sl.wait_cycles;
                        end else begin
                            next_state <= s_read_done;
                        end 
                    end 
                2'b11:
                    begin
                        if (sl.wait_cycles > 0) begin
                            next_state <= s_write;
                            cycles_remaining <= sl.wait_cycles;
                        end else begin
                            next_state <= s_write_done;
                        end

                    end 
            endcase
        end else if (state == s_write) begin
            if (cycles_remaining > 1) begin
                cycles_remaining = cycles_remaining - 1'b1;
            end else begin
                next_state <= s_write_done;
            end
        end else if (state == s_read) begin
            if (cycles_remaining > 1) begin
                cycles_remaining = cycles_remaining - 1'b1;
            end else begin
                next_state <= s_read_done;
            end
        end else if (state == s_write_done) begin
                next_state <= s_idle;
        end else if (state == s_read_done) begin
                next_state <= s_idle;
        end
        
    end
    
    //Control Signals
    always @(posedge pm.clk) begin
        state = next_state;
        if (state == s_idle) begin
            pm.enable = 1'b0;
        end else if (state == s_setup) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;         
        end else if (state == s_access) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
        end
        
    end
    
endmodule
