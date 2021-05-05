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
interface I2C_Bus ();
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

interface I2C_test_signals();
    logic [4:0] master_state, slave_state;
    logic [7:0] master_data, slave_data, slave_select, slave_mem_address;

endinterface

module I2C (I2C_Bus i2c_bus, I2C_Memory_Bus mem, APB_I2C_Bus apb, input logic [7:0] id, input logic clk, I2C_test_signals test);

    I2C_Slave slave(i2c_bus.slave, 
        mem.slave, 
        id,
        clk,
        test);
        
    I2C_Master master(i2c_bus.master,
        apb, 
        clk, 
        test);

    

endmodule



