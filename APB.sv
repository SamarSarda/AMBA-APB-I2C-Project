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
    logic [1:0] sel;

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

interface Processor_Bus(); // not sure if processor should determine wait cycles, but it seems logical to pass that functionality to the processor as opposed to a general purpose bus
    logic write, clk, reset, ready, start;
    logic [7:0] wdata, rdata, addr, wait_cycles;
    logic [1:0] sel;

    modport processor (input clk, rdata, ready, output write, sel, reset, addr, wdata, start, wait_cycles);
    modport master (input clk, write, sel, reset, addr, wdata, start, wait_cycles, output, rdata, ready);
endinterface

module APB_Slave(APB.slave sl, Memory_Bus.slave msl, logic [1:0] id);
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
                        if (sl.wait_cycles > 0) begin
                            next_state <= s_read;
                            cycles_remaining <= sl.wait_cycles;
                        end else begin
                            next_state <= s_read_done;
                        end 
                    end 
                {id, 1'b0}:
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

//needs error code to account for processor providing invalid input combinations e.g. start = 1, but sel = 0
module APB_Master(APB.master ms, Processor_Bus.master pm);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_setup = 1, s_access = 2;
    assign ms.clk = pm.clk;
    

    //States
    always @(negedge pm.clk) begin
        if (pm.reset) begin
            next_state <= s_idle;
        end else if (state == s_idle) begin
            case (pm.start) // basing state changes off of the start signal that comes from the processor - might be flawed way of implementing
                1'b1: 
                    begin
                        next_state <= s_setup;
                    end
        end else if (state == s_setup) begin
            next_state <= s_access; //access always happens on next clock after setup phase
        end else if (state == s_access) begin
            case (ms.ready)
                1'b0:
                    begin
                        next_state <= s_access;
                    end
                1'b1:
                    begin
                        case (pm.start) 
                            1'b0: 
                                begin
                                    next_state <= s_idle;
                                end
                            1'b1: //and if pm.sel is nonzero - too lazy atm to add that, not to mention there is probably efficient syntax that i dont know
                                begin
                                    next_state <= s_setup;
                                end
                    end
        end
    end
    
    //Control Signals
    always @(posedge pm.clk) begin
        state = next_state;
        if (state == s_idle) begin
            ms.sel <= 2'b00;
            pm.enable <= 1'b0;
        end else if (state == s_setup) begin
            //should be only place where address, wdata and wait cycles are changed, 
            //by arm documentation, not changing addr or wdata unless there is a new transfer saves power
            ms.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
            pm.enable <= 1'b0;
            ms.addr <= pm.addr;
            ms.wdata <= pm.wdata;
            ms.wait_cyces = pm.wait_cycles;
        end else if (state == s_access) begin
            ms.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
            pm.enable <= 1'b1;
        end
        
    end
    
endmodule
