`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 12:16:01 AM
// Design Name: 
// Module Name: APB_slave_with_I2C_peripheral
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


module APB_slave_with_I2C_peripheral(
    APB_Bus apb_bus,
    input logic [1:0] apb_slave_id,
    input clk,
    output logic [7:0] rdata,
    output logic ready);
    
    
    //interfaces
    I2C_Bus i2c_bus(clk);
    
    
    //modules
    I2C_slave_with_mem sm(i2c_bus, 8'b1, clk);//address of i2c slave is 1
    
    APB_slave_with_I2C_master a2im(apb_bus, i2c_bus, apb_slave_id, clk, rdata, ready);
    
    
    task initiate;
        i2c_bus.reset_I2Cs;
        apb_bus.reset_APBs;
        sm.initiate_mem;
    endtask
endmodule
