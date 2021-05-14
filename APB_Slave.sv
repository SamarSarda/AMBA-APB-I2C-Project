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


module APB_Slave(APB_Bus.slave sl, 
    Memory_Bus.slave msl, 
    input logic [1:0] id, 
    input logic clk, 
    input logic usesSubModuleReady,
    output logic [7:0] rdata,
    output logic ready); 

    //states
    logic [2:0] state;
    logic [2:0] next_state;
    parameter s_idle = 0, s_write = 1, s_read = 2, s_write_done=3, s_read_done=4;
    
    //connecting wires
    assign rdata = msl.rdata;//rdata is tied to memory rdata
    assign msl.ce = sl.enable;//ce/enable is passed through to memory from apb
    
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
            if (ready) begin // when this module writes a ready signal, signals will be ready next cycle
                next_state <= s_idle;
            end
        end else if (state == s_read) begin
            if (ready) begin // when this module writes a ready signal, signals will be ready next cycle
                next_state <= s_idle;
                
            end
        end
        
    end
    
    
    always @(posedge clk) begin
        if (sl.reset) begin
            state = s_idle;
            next_state = s_idle; 
            if (usesSubModuleReady) begin//if we use the submodule's ready signal, our output register ready gets connected here
                assign ready = msl.ready;
            end else begin // else tie to 1 for 2 cycle transfers
                ready <= 1;
            end
        end else begin
            state = next_state;
        end
    end
    //Control Signals
    always @(posedge clk) begin
        if (state == s_idle) begin
            msl.wren <= 1'b0;
            msl.rden <= 1'b0;
        end else if (state == s_write) begin
           msl.wdata <= sl.wdata;
            msl.addr <= sl.addr;
            msl.wren <= 1'b1;
            msl.rden <= 1'b0;
        end else if (state == s_read) begin
            msl.addr <= sl.addr;
            msl.wren <= 1'b0;
            msl.rden <= 1'b1;
        end
        
    end
    
endmodule