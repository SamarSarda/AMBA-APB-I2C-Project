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


module APB_Master(APB_Bus.master ms, Processor_Bus.master pm, input clk);

    ///states
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_setup = 1, s_access = 2;
    
    // to make sure that 1 cycle and for 1 cycle after ready signal is received 
    //we tell the processor that the signal is stable
    logic after_ready; 
    
    //States
    always @(*) begin
        if (state == s_idle) begin
            case (pm.start) // basing state changes off of the start signal that comes from the processor 
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
                            1'b1: 
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
            state <= s_idle;
            next_state <= s_idle;
            after_ready <= 0;
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
            if (after_ready) begin // ready happened, so we make sure to make stable 1 for 1 cycle
                pm.stable <= 1'b1;
                after_ready <= 0;
            end else begin
                pm.stable <= 1'b0;
            end
        end else if (state == s_setup) begin
            //should be only place where address and wdata are changed, 
            //by arm documentation, not changing addr or wdata unless there is a new transfer saves power
            ms.sel <= pm.sel;
            ms.enable <= 1'b0;
            ms.write <= pm.write;
            ms.addr <= pm.addr;
            ms.wdata <= pm.wdata;
            pm.rdata <= ms.rdata;
            //for re-start condition
            if (after_ready) begin // ready happened, so we make sure to make stable 1 for 1 cycle
                pm.stable <= 1'b1;
                after_ready <= 0;
            end
        end else if (state == s_access) begin
            ms.sel <= pm.sel;
            pm.stable <= 1'b0;
            after_ready <= 1;
            ms.enable <= 1'b1;
        end
        
    end
    
endmodule