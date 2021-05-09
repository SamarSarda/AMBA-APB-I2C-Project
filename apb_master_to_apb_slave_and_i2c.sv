`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 01:56:16 PM
// Design Name: 
// Module Name: apb_master_to_apb_slave_and_i2c
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


module apb_master_to_apb_slave_and_i2c();
    logic clk;
    logic [4:0] apb_slave_state, i2c_master_state, i2c_slave_state, apb_master_state;
    logic i2c_master_ready;
    logic [7:0] i2c_master_rdata, apb_slave_memory_bus_rdata;
    
    logic [1:0] apb_slave_id;

    //processor
    logic p_write, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb
    logic a_write, a_ready, enable, a_reset;
    logic [7:0] a_wdata, a_rdata, a_addr;
    logic [1:0] a_sel;
    
    //interfaces
    APB_Bus apb_bus(clk);

    //modules
    Processor_Bus processor_bus();
    APB_Master master(apb_bus.master, processor_bus.master, clk);
    
    APB_slave_with_I2C_peripheral slave(apb_bus, apb_slave_id, clk);
    
    //apb
    assign a_ready = apb_bus.ready;
    assign enable = apb_bus.enable;
    assign a_write = apb_bus.write;
    assign a_reset = apb_bus.reset;
    assign a_wdata = apb_bus.wdata;
    assign a_addr = apb_bus.addr;
    assign a_sel = apb_bus.sel;
    assign a_rdata = apb_bus.rdata;
    
    //processor
    assign processor_bus.write = p_write;
    assign stable = processor_bus.stable;
    assign processor_bus.start = start;
    assign processor_bus.wdata = p_wdata;
    assign processor_bus.addr = p_addr;
    assign processor_bus.sel = p_sel;
    assign p_rdata = processor_bus.rdata;
    
    //important values
    assign apb_master_state = master.state;
    assign apb_slave_state = slave.a2im.apb_slave.state;
    assign i2c_master_state = slave.a2im.i2c_master.state;
    assign i2c_slave_state = slave.sm.slave.state;
    assign i2c_master_ready = slave.a2im.apb_i2c_bus.ready;
    assign i2c_master_rdata = slave.a2im.apb_i2c_bus.rdata;
    assign apb_slave_memory_bus_rdata = slave.a2im.memory_bus.rdata;
    assign ce = slave.a2im.memory_bus.ce;
    assign wren = slave.a2im.memory_bus.wren;
    assign rden = slave.a2im.memory_bus.rden;
    
    
    
    
    
    
    initial 
    begin
        
    end
    initial
    begin
        apb_slave_id = 1;
        clk = 0;
        slave.initiate;
        apb_bus.reset_APBs;
        
        
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);   //write transfer
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_addr = 8'b01000001;//first 2 bits are i2c peripheral device address, rest are mem address
        p_wdata = 5;
        start = 1;
        @(posedge clk);
        start = 0;
        
        while (!apb_bus.ready) begin
            @(posedge clk);
        end

        @(posedge clk);

        p_sel = 0;
        @(posedge clk);    //read transfer
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr = 8'b01000001;//first 2 bits are i2c peripheral device address, rest are mem address
        start = 1;
        @(posedge clk);
        start = 0;
        
        while (!apb_bus.ready) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        p_sel = 0;
        @(posedge clk);
        
        
        
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
    
endmodule
