`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2021 02:59:24 AM
// Design Name: 
// Module Name: 1bit_mux2to1
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


module mux4to1_1bit(
    input logic Data_in_0,
    input logic Data_in_1,
    input logic Data_in_2,
    input logic Data_in_3,
    input logic [1:0] sel,
    output logic Data_out
    ); 
    always @(*)
    begin
        if(sel == 0) begin 
            Data_out = Data_in_0; 
        end if(sel == 1) begin 
            Data_out = Data_in_1; 
        end else if (sel == 2) begin
            Data_out = Data_in_2;
        end else if (sel == 3) begin
            Data_out = Data_in_3;
        end 
    end
    
endmodule

