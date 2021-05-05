`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2021 09:27:24 AM
// Design Name: 
// Module Name: APB_Master
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


//needs error code to account for processor providing invalid input combinations e.g. start = 1, but sel = 0
module APB_Master(APB_Bus.master ms1, APB_Bus.master ms2, Processor_Bus.master pm);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_setup = 1, s_access = 2;
    logic after_ready;
    
    logic write, ready, enable, reset;
    logic [7:0] wdata, rdata, addr, wait_cycles;
    logic [1:0] sel;
    
    
    assign ms1.clk = pm.clk;
    assign ms2.clk = pm.clk;
    //assign pm.ready = ms.ready;
    //assign pm.rdata = ms.rdata;
    //States
    always @(*) begin
        if (state == s_idle) begin
            case (pm.start) // basing state changes off of the start signal that comes from the processor - might be flawed way of implementing
                1'b1: 
                    begin
                        next_state = s_setup;
                    end
            endcase
        end else if (state == s_setup) begin
            next_state = s_access; //access always happens on next clock after setup phase
        end else if (state == s_access) begin
            case ((ms1.ready && sel == 1) || (ms2.ready && sel == 2))
                1'b0:
                    begin
                        next_state = s_access;
                    end
                1'b1:
                    begin
                        case (pm.start) 
                            1'b0: 
                                begin
                                    next_state = s_idle;
                                end
                            1'b1: //and if pm.sel is nonzero - too lazy atm to add that, not to mention there is probably efficient syntax that i dont know
                                begin
                                    next_state = s_setup;
                                end
                          endcase
                    end
              endcase
        end
    end

    always @(posedge pm.clk) begin
        if (pm.reset) begin
            state = s_idle;
            next_state = s_idle;
            after_ready = 0;
        end else begin
            state = next_state;
        end
    end

    //Control Signals
    always @(posedge pm.clk) begin 
        if (state == s_idle) begin
            if (sel == 1) begin // last select input
                ms1.sel <= 2'b00;
                ms1.enable <= 1'b0;
                pm.rdata <= ms1.rdata;
                
                ready <= ms1.ready;
            end else if (sel == 2) begin
                ms2.sel <= 2'b00;
                ms2.enable <= 1'b0;
                pm.rdata <= ms2.rdata;
                
                ready <= ms2.ready;
            end else begin
                //not error, just idles
            end
            
                sel <= 2'b00;
                enable <= 1'b0;
                rdata <= ms2.rdata;
            
            if (after_ready) begin
                pm.stable <= 1'b1;
                after_ready <= 0;
            end
        end else if (state == s_setup) begin
            //should be only place where address, wdata and wait cycles are changed, 
            //by arm documentation, not changing addr or wdata unless there is a new transfer saves power
            if (pm.sel == 1) begin
                ms1.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
                ms1.enable <= 1'b0;
                ms1.write <= pm.write;
                ms1.addr <= pm.addr;
                ms1.wdata <= pm.wdata;
                pm.rdata <= ms1.rdata;
                
                ready <= ms1.ready;
            end else if (pm.sel == 2) begin
                ms2.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
                ms2.enable <= 1'b0;
                ms2.write <= pm.write;
                ms2.addr <= pm.addr;
                ms2.wdata <= pm.wdata;
                pm.rdata <= ms2.rdata;
                
                ready <= ms2.ready;
            end else begin
                //error
            end
                sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
                enable <= 1'b0;
                write <= pm.write;
                addr <= pm.addr;
                wdata <= pm.wdata;
                rdata <= ms1.rdata;
                
            
            if (after_ready) begin
                pm.stable <= 1'b1;
                after_ready <= 0;
            end
        end else if (state == s_access) begin
            if (pm.sel == 1) begin
                ms1.sel <= pm.sel; 
                ms1.enable <= 1'b1;
                
                ready <= ms1.ready;
            end else if (pm.sel == 2) begin
                ms2.sel <= pm.sel;
                ms2.enable <= 1'b1;
                
                ready <= ms2.ready;
            end else begin
                //error
            end
            sel <= pm.sel;
            enable <= 1'b1;
            
            pm.stable <= 1'b0;
            after_ready <= 1;
        end
        
    end
    
endmodule