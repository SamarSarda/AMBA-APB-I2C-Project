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
module APB_Master(APB_Bus.master ms, Processor_Bus.master pm, input clk);
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_setup = 1, s_access = 2;
    logic after_ready;
    
    //assign ms.clk = pm.clk;
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
            case (ms.ready)
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

    always @(posedge clk) begin
        if (ms.reset) begin
            state = s_idle;
            next_state = s_idle;
            after_ready = 0;
        end else begin
            state = next_state;
        end
    end

    //Control Signals
    always @(posedge clk) begin 
        if (state == s_idle) begin
            ms.sel <= 2'b00;
            ms.enable <= 1'b0;
            pm.rdata <= ms.rdata;
            if (after_ready) begin
                pm.stable <= 1'b1;
                after_ready <= 0;
            end else begin
                pm.stable <= 1'b0;
            end
        end else if (state == s_setup) begin
            //should be only place where address, wdata and wait cycles are changed, 
            //by arm documentation, not changing addr or wdata unless there is a new transfer saves power
            ms.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
            ms.enable <= 1'b0;
            ms.write <= pm.write;
            ms.addr <= pm.addr;
            ms.wdata <= pm.wdata;
            pm.rdata <= ms.rdata;
            if (after_ready) begin
                pm.stable <= 1'b1;
                after_ready <= 0;
            end
        end else if (state == s_access) begin
            ms.sel <= pm.sel; // assume that pm will always give valid id, but consider throwing errors
            
            pm.stable <= 1'b0;
            after_ready <= 1;
            if (ms.ready) begin//this code can probably be deleted, i think it doesnt execute ever
                ms.enable <= 1'b0;
                pm.rdata <= ms.rdata;
            end else begin
                ms.enable <= 1'b1;
            end
        end
        
    end
    
endmodule