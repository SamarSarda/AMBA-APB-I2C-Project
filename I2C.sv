`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 07:01:20 PM
// Design Name: 
// Module Name: I2C_Slave
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


//make test modport to make valuable signals visible e.g. state, buffers, id
//chanege all if/else to case
interface I2C ();
    logic SDA, SCL, reset;
    
    task reset_slave;
        @ (negedge SCL);
        reset = 1'b1;
        @ (negedge SCL);
        reset = 1'b0;
    endtask

    modport master (input reset, inout SDA, SCL);
    modport slave (input reset, inout SDA, SCL);
endinterface

interface I2C_Memory_Bus();
    logic wren, rden, clk, ce;
    logic [7:0] wdata, rdata, addr;

    task write;

    endtask

    task read;

    endtask

    modport slave (input rdata, output wdata, wren, rden, clk, addr, ce);
    modport mem (output rdata, addr, input wdata, wren, rden, clk, ce);
endinterface 

interface APB_I2C_Bus();
    logic wren, rden, clk, ce, error;
    logic [7:0] wdata, rdata, addr;

    modport APB (input rdata, error, output wdata, wren, rden, clk, addr, ce);
    modport master (output rdata, addr, error, input wdata, wren, rden, clk, ce);
endinterface


module I2C ();

endmodule




