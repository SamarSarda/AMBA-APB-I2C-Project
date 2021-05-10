`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/03/2021 09:27:24 AM
// Design Name: 
// Module Name: memory
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


module memory (clk, addr, ce, wren, rden, wr_data, rd_data, ready);

input clk, ce, wren, rden;
input [7:0] addr, wr_data;
output reg [7:0] rd_data;
output reg ready;

reg [7:0] mem [0:255];

integer i;
task initiate(); // used for testing
    begin
        $display ("Memory initiating...");
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = i;
        end
        $display ("Memory initiation complete.");
    end
endtask

//memory access logic
always @ (posedge clk) begin
    if (ce) begin
       if (rden) begin 
           rd_data <= mem[addr];
       end else if (wren) begin
           mem[addr] <= wr_data;
       end
    end 
end

//memory ready signal logic
always @ (posedge clk) begin
    if (ce) begin
        if (ready) begin
            ready <= 0;
        end else if (rden || wren) begin
            ready <= 1;
        end 
    end else begin
       ready <= 0;
    end
end

endmodule

