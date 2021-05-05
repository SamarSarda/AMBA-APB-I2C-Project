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


module APB_Slave(APB_Bus.slave sl, Memory_Bus.slave msl, input logic [1:0] id); // fix next state logic
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_write = 1, s_read = 2, s_write_done=3, s_read_done=4;
    logic [7:0] cycles_remaining;
    assign msl.clk = sl.clk;
    assign msl.addr = sl.addr;
    assign msl.wdata = sl.wdata;
    assign sl.rdata = msl.rdata;

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
                {id, 1'b1}:
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
            msl.ce <= 1'b0;
        end else if (state == s_write) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;
            msl.ce <= 1'b1;         
        end else if (state == s_read) begin
            sl.ready <= 1'b0;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
            msl.ce <= 1'b1;
        end else if (state == s_write_done) begin
            sl.ready <= 1'b1;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;
            msl.ce <= 1'b1;
        end else if (state == s_read_done) begin
            sl.ready <= 1'b1;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
            msl.ce <= 1'b1;
        end 
        
    end
    
endmodule