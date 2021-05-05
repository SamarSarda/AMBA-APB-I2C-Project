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

interface APB_Bus (input logic clk, input logic reset);
    logic write, ready, enable, reset;
    logic [7:0] wdata, rdata, addr, wait_cycles;
    logic [1:0] sel;
    task reset_slave; 
    @ (negedge clk);
    reset = 1'b1;
    @ (negedge clk); 
    reset =1'b0;
    endtask
    modport master (input clk, ready, rdata, output write, sel, wdata, enable, wait_cycles, addr);
    modport slave (input clk, write, sel, wdata, enable, reset, wait_cycles, addr, output ready, rdata);
endinterface

interface Memory_Bus();
    logic wren, rden, clk, ce, ready;
    logic [7:0] wdata, rdata, addr;

    modport slave (input rdata, addr, output wdata, wren, rden, clk, ce, inout ready);
    modport mem (output rdata, input wdata, wren, rden, clk, ce, addr, inout ready);
endinterface 

interface Processor_Bus(input logic clk, input logic reset); // not sure if processor should determine wait cycles, but it seems logical to pass that functionality to the processor as opposed to a general purpose bus
    logic write, clk, reset, stable, start;
    logic [7:0] wdata, rdata, addr, wait_cycles;
    logic [1:0] sel;

    task reset_master; 
    @ (negedge clk);
    reset = 1'b1;
    @ (negedge clk); 
    reset =1'b0;
    endtask

    modport processor (input clk, rdata, stable, output write, sel, addr, wdata, start, wait_cycles);
    modport master (input clk, write, sel, reset, addr, wdata, start, wait_cycles, output rdata, stable);
endinterface

module APB(APB_Bus a, Memory_Bus m1, Memory_Bus m2, Processor_Bus pm,input logic [7:0] id, input logic clk);
    APB_Slave slave1(a.slave, m1.slave, id);
    APB_Slave slave2(a.slave, m2.slave, id);
    APB_Master master(a.master, pm.master);
endmodule


