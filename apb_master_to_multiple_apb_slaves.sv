`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 05:39:54 PM
// Design Name: 
// Module Name: apb_master_to_multiple_apb_slaves_and_peripherals
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


module apb_master_to_multiple_apb_slaves();

    logic clk;
    logic [4:0] apb_slave1_state, apb_slave2_state, i2c_master_state, i2c_slave_state, apb_master_state;
    logic i2c_master_ready;
    logic [7:0] i2c_master_rdata, apb_slave_memory_bus_rdata;
    
    logic [1:0] apb_slave1_id, apb_slave2_id;

    //processor
    logic p_write, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb
    logic a_write, a_ready, enable, a_reset;
    logic [7:0] a_wdata, a_rdata, a_addr;
    logic [1:0] a_sel;
    
    logic [7:0] s1_rdata, s2_rdata, rdata_mux_result;
    logic s1_ready, s2_ready, ready_mux_result;
    
    //interfaces
    APB_Bus apb_bus(clk);
    Processor_Bus processor_bus();
    
    //modules
    APB_Master master(apb_bus.master, processor_bus.master, clk);
    mux4to1_8bit rdata_mux(.Data_in_0(0), .Data_in_1(s1_rdata), .Data_in_2(s2_rdata), .Data_in_3(0), .sel(apb_bus.sel));
    mux4to1_1bit ready_mux(.Data_in_0(0), .Data_in_1(s1_ready), .Data_in_2(s2_ready), .Data_in_3(0), .sel(apb_bus.sel));
    APB_slave_with_I2C_peripheral si2c(apb_bus, apb_slave1_id, clk, s1_rdata, s1_ready);
    APB_Slave_with_mem sm(apb_bus, apb_slave2_id, clk, s2_rdata, s2_ready);
    
    //apb
    assign a_ready = apb_bus.ready;
    assign enable = apb_bus.enable;
    assign a_write = apb_bus.write;
    assign a_reset = apb_bus.reset;
    assign a_wdata = apb_bus.wdata;
    assign a_addr = apb_bus.addr;
    assign a_sel = apb_bus.sel;
    assign a_rdata = apb_bus.rdata;
    
    assign apb_bus.rdata = rdata_mux.Data_out;
    assign apb_bus.ready = ready_mux.Data_out;
    assign rdata_mux_result = rdata_mux.Data_out;
    assign ready_mux_result = ready_mux.Data_out;
    
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
    assign apb_slave1_state = si2c.a2im.apb_slave.state;
    assign apb_slave2_state = sm.dut.state;
    assign i2c_master_state = si2c.a2im.i2c_master.state;
    assign i2c_slave_state = si2c.sm.slave.state;
    assign i2c_master_ready = si2c.a2im.apb_i2c_bus.ready;
    assign i2c_master_rdata = si2c.a2im.apb_i2c_bus.rdata;
    assign apb_slave_memory_bus_rdata = si2c.a2im.memory_bus.rdata;
    assign ce = si2c.a2im.memory_bus.ce;
    assign wren = si2c.a2im.memory_bus.wren;
    assign rden = si2c.a2im.memory_bus.rden;
    
    
    
    
    
    initial 
    begin
        
    end
    initial
    begin
        apb_slave1_id = 1;
        apb_slave2_id = 2;
        clk = 0;
        si2c.initiate;
        apb_bus.reset_APBs;
        sm.initiate;
        
 //APB SLave - I2C peripheral       
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
        
//APB Slave - Memory        
        @(posedge clk);   //write transfer
        @(posedge clk);
        p_write = 1;
        p_sel = 2;
        p_addr = 8'b00000001;//first 2 bits are i2c peripheral device address, rest are mem address
        p_wdata = 5;
        start = 1;
        @(posedge clk);
        start = 0;
        
        while (!apb_bus.ready || !enable) begin
            @(posedge clk);
        end

        @(posedge clk);

        p_sel = 0;
        @(posedge clk);    //read transfer
        @(posedge clk);
        p_write = 0;
        p_sel = 2;
        p_addr = 8'b00000001;//first 2 bits are i2c peripheral device address, rest are mem address
        start = 1;
        @(posedge clk);
        start = 0;
        
        while (!apb_bus.ready || !enable) begin
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
