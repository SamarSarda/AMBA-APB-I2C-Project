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

interface APB_Bus (input logic clk);
    logic write, ready, enable, reset;
    logic [7:0] wdata, rdata, addr;
    logic [1:0] sel;
    
    task reset_APBs; 
    @ (negedge clk);
    reset = 1'b1;
    @ (negedge clk); 
    reset =1'b0;
    endtask
    
    modport master (input ready, rdata, reset, output write, sel, wdata, enable, addr);
    modport slave (input write, sel, wdata, enable, reset, addr); 
    // ready and rdata oputputs are unique to each slave, and need to be muxed
endinterface

interface Memory_Bus();
    logic wren, rden, ce, ready, error;
    logic [7:0] wdata, rdata, addr;

    modport slave (input rdata, addr, output wdata, wren, rden, ce, inout ready);
    modport mem (output rdata, input wdata, wren, rden, ce, addr, inout ready);
endinterface 

interface Processor_Bus(); 
    logic write, stable, start;
    logic [7:0] wdata, rdata, addr;
    logic [1:0] sel;


    modport processor (input rdata, stable, output write, sel, addr, wdata, start);
    modport master (input write, sel, addr, wdata, start, output rdata, stable);
endinterface


module APB(APB_Bus apb1, APB_Bus apb2, Memory_Bus m1, Memory_Bus m2, Processor_Bus pm, input logic [1:0] id1, input logic [1:0] id2, input logic clk);
    APB_Slave slave1(apb1.slave, m1.slave, id1);
    APB_Slave slave2(apb2.slave, m2.slave, id2);
    //APB_Master master(apb1.master, apb2.master, pm.master);
endmodule

