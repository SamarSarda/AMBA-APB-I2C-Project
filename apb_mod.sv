`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/05/2021 05:28:55 AM
// Design Name: 
// Module Name: apb_mod
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


module apb_mod(APB_Bus a, Memory_Bus m1, Memory_Bus m2, Processor_Bus pm,input logic [7:0] id, input logic clk);
    APB_Slave slave1(a.slave, m1.slave, id);
    APB_Slave slave2(a.slave, m2.slave, id);
    APB_Master master(a.master, pm.master);
endmodule
