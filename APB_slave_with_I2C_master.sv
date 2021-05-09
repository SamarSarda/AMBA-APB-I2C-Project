`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 11:14:29 PM
// Design Name: 
// Module Name: APB_slave_with_I2C_master
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


module APB_slave_with_I2C_master(
    APB_Bus apb_bus,
    I2C_Bus i2c_bus,
    input logic [1:0] id,
    input clk
    );
   
    //interfaces
    APB_I2C_Bus apb_i2c_bus();
    Memory_Bus memory_bus();
    
    //modules
    I2C_Master i2c_master(i2c_bus.master, apb_i2c_bus.master, clk);
     
    APB_Slave apb_slave(.sl(apb_bus.slave),
     .msl(memory_bus.slave),
      .id(id),
       .usesSubModuleReady(1'b1),
        .clk(clk));
        
    //connecting io of 2 different busses
    assign apb_i2c_bus.wren = memory_bus.wren;
    assign apb_i2c_bus.rden = memory_bus.rden;
    assign apb_i2c_bus.ce = memory_bus.ce;
    assign apb_i2c_bus.wdata = memory_bus.wdata;
    assign memory_bus.rdata = apb_i2c_bus.rdata;
    assign apb_i2c_bus.addr = memory_bus.addr;
    assign memory_bus.error = apb_i2c_bus.error;
    assign memory_bus.ready = apb_i2c_bus.ready;
    
endmodule
