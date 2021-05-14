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



interface I2C_Bus (input logic clk);
    logic SDA, SCL, reset;
    
    task reset_slave; //used only in testing slave
        @ (posedge SCL);
        reset = 1'b1;
        @ (posedge SCL);
        reset = 1'b0;
    endtask
    
    task reset_master; //used in testing master
        @ (posedge clk);
        reset = 1'b1;
        //SCL = 1;
        @ (posedge clk);
        reset = 1'b0;
    endtask
    
    //used when master and slave are together, 
    //master sets SCL high on reset, causing the posege needed for slave to reset
    task reset_I2Cs; 
        @ (posedge clk);
        reset = 1'b1;
        @ (posedge clk);
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

    modport slave (input rdata, addr, output wdata, wren, rden, clk,  ce);
    modport mem (output rdata, input wdata, wren, rden, clk, ce, addr);
endinterface 

interface APB_I2C_Bus();
    logic wren, rden, clk, ce, error, ready;
    logic [7:0] wdata, rdata, addr;

    modport APB (input rdata, error, output wdata, wren, rden, clk, addr, ce, inout ready);
    modport master (output rdata, addr, error, input wdata, wren, rden, clk, ce, inout ready);
endinterface


module I2C (I2C_Bus i2c_bus, I2C_Memory_Bus mem, APB_I2C_Bus apb, input logic [7:0] id, input logic clk);

    I2C_Slave slave(i2c_bus.slave, 
        mem.slave, 
        id,
        clk);
        
    I2C_Master master(i2c_bus.master,
        apb, 
        clk);

    

endmodule

