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


module apb_slave_tb();

    logic clk;
    logic write;
    logic sel;
    logic enable;
    logic ready, wren, rden;
    logic [2:0] state;
    logic [1:0] id;

    //interfaces
    APB_Bus APB_i(clk);
    Memory_Bus Memory_Bus_i();
    
    //modules
    APB_Slave dut(.sl(APB_i.slave), .msl(Memory_Bus_i.slave), .id(id));
    
    assign APB_i.write = write;
    assign APB_i.sel = sel;
    assign APB_i.enable = enable;
    assign ready = APB_i.ready;
    assign wren = Memory_Bus_i.wren;
    assign rden = Memory_Bus_i.rden;
    
    initial 
    begin
        APB_i.reset_slave;
        assign state = dut.state;
        id = 1;
    end
    initial
    begin
        clk = 0;
        APB_i.wait_cycles = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);   //write transfer
        @(posedge clk);
        write = 1;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable =0;
        sel = 0;
        @(posedge clk);    //read transfer
        @(posedge clk);
        write = 0;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable =0;
        sel = 0;
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        APB_i.wait_cycles = 5;
        @(posedge clk);
        write = 1;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        APB_i.wait_cycles = 5;
        @(posedge clk);
        write = 0;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        APB_i.wait_cycles = 1;
        @(posedge clk);
        write = 1;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        APB_i.wait_cycles = 1;
        @(posedge clk);
        write = 0;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        APB_i.wait_cycles = 3;
        @(posedge clk);
        write = 1;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        APB_i.wait_cycles = 3;
        @(posedge clk);
        write = 0;
        sel = 1;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule