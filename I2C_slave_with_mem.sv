`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 06:50:33 PM
// Design Name: 
// Module Name: I2C_slave_with_mem
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


module I2C_slave_with_mem(I2C_Bus i2c_bus, input logic [7:0] id, input clk);
    
    //interfaces
    I2C_Memory_Bus I2C_Memory_Bus_i();
    
    //modules
    memory mem(.clk(clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
        
    I2C_Slave slave(i2c_bus.slave, I2C_Memory_Bus.slave, id, clk);
    
endmodule
