`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2021 03:15:31 AM
// Design Name: 
// Module Name: mux4to1_8bit
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


module mux4to1_8bit(
    input logic [7:0] Data_in_0,
    input logic [7:0] Data_in_1,
    input logic [7:0] Data_in_2,
    input logic [7:0] Data_in_3,
    input logic [1:0] sel,
    output logic [7:0] Data_out
    ); 
    logic [7:0] prev_data_out;
    
    always @(*)
    begin
        if(sel == 0) begin 
            Data_out = prev_data_out; 
        end if(sel == 1) begin 
            Data_out = Data_in_1; 
            prev_data_out = Data_in_1; 
        end else if (sel == 2) begin
            Data_out = Data_in_2;
            prev_data_out = Data_in_2;
        end else if (sel == 3) begin
            Data_out = Data_in_3;
            prev_data_out = Data_in_3;
        end 
    end
endmodule
