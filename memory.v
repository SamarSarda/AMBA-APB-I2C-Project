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


module memory (clk, addr, ce, wren, rden, wr_data, rd_data);

input clk, ce, wren, rden;
input [7:0] addr, wr_data;
output reg [7:0] rd_data;

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

always @ (posedge clk) begin
if (ce) 
begin
   if (rden) 
       rd_data <= mem[addr];
   else if (wren) 
       mem[addr] <= wr_data;
end

endmodule

