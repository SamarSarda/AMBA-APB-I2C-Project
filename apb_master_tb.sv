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
    logic p_write, clk, p_reset, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb
    logic a_write, a_ready, enable, a_reset;
    logic [7:0] a_wdata, a_rdata, a_addr;
    logic [1:0] a_sel;
    
    APB_Bus APB_1(clk);
    APB_Bus APB_2(clk);

    Processor_Bus Processor_bus_i(clk, reset);
    //APB_Slave dut(.sl(APB_1.slave), .msl(Memory_Bus_i.slave));
    APB_Master dut(APB_1.master, APB_2.master, Processor_bus_i.master);
    
    assign APB_1.ready = a_ready;
    assign enable = APB_1.enable;
    assign a_write = APB_1.write;
    assign a_reset = APB_1.reset;
    assign a_wdata = APB_1.wdata;
    assign a_addr = APB_1.addr;
    assign a_sel = APB_1.sel;
    assign APB_1.rdata = a_rdata;
    
    
    assign Processor_bus_i.write = p_write;
    assign p_reset = Processor_bus_i.reset;
    assign stable = Processor_bus_i.stable;
    assign Processor_bus_i.start = start;
    assign Processor_bus_i.wdata = p_wdata;
    assign Processor_bus_i.addr = p_addr;
    assign Processor_bus_i.sel = p_sel;
    assign p_rdata = Processor_bus_i.rdata;
    
    
    
    
    
    initial 
    begin
        Processor_bus_i.reset_master;
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
        //APB_1.wait_cycles = 5;
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

        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_1.wait_cycles = 5;
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
        
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_1.wait_cycles = 1;
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

        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_1.wait_cycles = 1;
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
        
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule