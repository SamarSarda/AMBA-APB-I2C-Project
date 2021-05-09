`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2021 06:37:46 PM
// Design Name: 
// Module Name: apb_tb
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


module apb_master_tb();

    logic clk;

    logic [2:0] state;

    //processor
    logic p_write, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb
    logic a_write, a_ready, enable, a_reset;
    logic [7:0] a_wdata, a_rdata, a_addr;
    logic [1:0] a_sel;
    
    APB_Bus apb_bus(clk);

    Processor_Bus processor_bus();
    //APB_Slave dut(.sl(apb_bus.slave), .msl(Memory_Bus_i.slave));
    APB_Master dut(apb_bus.master, processor_bus.master, clk);
    
    assign apb_bus.ready = a_ready;
    assign enable = apb_bus.enable;
    assign a_write = apb_bus.write;
    assign a_reset = apb_bus.reset;
    assign a_wdata = apb_bus.wdata;
    assign a_addr = apb_bus.addr;
    assign a_sel = apb_bus.sel;
    assign apb_bus.rdata = a_rdata;
    
    
    assign processor_bus.write = p_write;
    assign stable = processor_bus.stable;
    assign processor_bus.start = start;
    assign processor_bus.wdata = p_wdata;
    assign processor_bus.addr = p_addr;
    assign processor_bus.sel = p_sel;
    assign p_rdata = processor_bus.rdata;
    
    
    
    
    
    initial 
    begin
        apb_bus.reset_APBs;
        assign state = dut.state;
    end
    initial
    begin
        clk = 0;
        a_ready = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);   //write transfer
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_wdata = 5;
        start = 1;
        @(posedge clk);
        start = 0;
        //en 1
        @(posedge clk);
        //en 0
        p_sel = 0;
        @(posedge clk);    //read transfer
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr = 6;
        start = 1;
        @(posedge clk);
        start = 0;
        
        @(posedge clk);
        a_rdata = 5;
        p_sel = 0;
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //apb_bus.wait_cycles = 5;
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_wdata = 4;
        p_addr= 5;
        a_ready = 0;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        a_ready = 1;
        @(posedge clk);
        a_ready = 0;
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //apb_bus.wait_cycles = 5;
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr= 5;
        a_ready = 0;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        a_ready = 1;
        a_rdata = 6;
        @(posedge clk);
        a_ready = 0;
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //apb_bus.wait_cycles = 1;
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_wdata = 3;
        p_addr= 4;
        a_ready = 0;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        a_ready = 1;
        @(posedge clk);
        a_ready = 0;
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //apb_bus.wait_cycles = 1;
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr= 4;
        a_ready = 0;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        a_ready = 1;
        a_rdata = 7;
        @(posedge clk);
        a_ready = 0;
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule