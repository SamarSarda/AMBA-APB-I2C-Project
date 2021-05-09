`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2021 03:07:25 PM
// Design Name: 
// Module Name: apb_master_to_apb_slave_and_mem
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


module apb_master_to_apb_slave_and_mem();
    logic clk;
    logic [4:0] apb_slave_state, apb_master_state;
   // logic i2c_master_ready;
    logic [7:0]  apb_slave_memory_bus_rdata;
    
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
    
    APB_Slave_with_mem sm(apb_bus, id, clk);
    
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
    assign apb_slave_state = sm.dut.state;
    assign apb_slave_memory_bus_rdata = sm.Memory_Bus_i.rdata;
    assign ce = sm.Memory_Bus_i.ce;
    assign wren = sm.Memory_Bus_i.wren;
    assign rden = sm.Memory_Bus_i.rden;
    
    
    
    
    
    
    initial 
    begin
        
    end
    initial
    begin
        apb_slave_id = 1;
        clk = 0;
        sm.initiate;
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
