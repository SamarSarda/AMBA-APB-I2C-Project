`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 01:00:29 AM
// Design Name: 
// Module Name: apb_slave_with_i2c_peripheral_tb
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


module apb_slave_with_i2c_peripheral_tb();
    
    logic clk;
    logic write;
    logic sel;
    logic enable;
    logic ready, wren, ce, rden;
    logic [4:0] apb_slave_state, i2c_master_state, i2c_slave_state;
    logic i2c_master_ready;
    logic [7:0] i2c_master_rdata, apb_slave_memory_bus_rdata;

    logic [7:0] wdata, rdata, addr;
    
    logic [1:0] apb_slave_id;
    
    //interfaces
    APB_Bus apb_bus(clk);
    
    //modules
    APB_slave_with_I2C_peripheral dut(apb_bus, apb_slave_id, clk);

    
    //apb
    assign apb_bus.write = write;
    assign apb_bus.sel = sel;
    assign apb_bus.enable = enable;
    assign apb_bus.wdata = wdata;
    assign apb_bus.addr = addr;
    assign ready = apb_bus.ready;
    assign rdata = apb_bus.rdata;
    
    //memory
    
//    assign wren = memory_bus.wren;
//    assign rden = memory_bus.rden;
//    assign ce = memory_bus.ce;
    assign apb_slave_state = dut.a2im.apb_slave.state;
    assign i2c_master_state = dut.a2im.i2c_master.state;
    assign i2c_slave_state = dut.sm.slave.state;
    assign i2c_master_ready = dut.a2im.apb_i2c_bus.ready;
    assign i2c_master_rdata = dut.a2im.apb_i2c_bus.rdata;
    assign apb_slave_memory_bus_rdata = dut.a2im.memory_bus.rdata;
    assign ce = dut.a2im.memory_bus.ce;
    assign wren = dut.a2im.memory_bus.wren;
    assign rden = dut.a2im.memory_bus.rden;
    

    initial
    begin
        clk = 1;
        dut.initiate; // resetting apb slave, i2c master and i2c slave, initiating memory to store the address of each address
        
        
        apb_slave_id = 1;
        
        
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);   //write transfer
        @(posedge clk);
        write = 1;
        sel = 1;
        wdata = 5;
        addr= 8'b01000001;//first 2 bits are address of i2c slave
        @(posedge clk);
        enable = 1;
        
        while (!apb_bus.ready) begin
            @(posedge clk);
        end
        enable = 0;
        sel = 0;
        @(posedge clk);
        
        
        @(posedge clk);    //read transfer
        @(posedge clk);
        write = 0;
        sel = 1;
        addr= 8'b01000001;
        @(posedge clk);
        enable = 1;
        
        while (!apb_bus.ready) begin
            @(posedge clk);
        end
        enable =0;
        sel = 0;
        @(posedge clk);
        
        @(posedge clk);
        
        
        
       
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule
