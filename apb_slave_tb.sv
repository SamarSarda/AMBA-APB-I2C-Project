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
    logic ready, wren, ce, rden;
    logic [2:0] state;
    logic [1:0] id;
    logic [7:0] wdata, rdata, addr;

    //interfaces
    APB_Bus APB_i(clk);
    Memory_Bus Memory_Bus_i();
    
    //modules
    APB_Slave dut(.sl(APB_i.slave),
     .msl(Memory_Bus_i.slave),
      .id(id),
       .usesSubModuleReady(1),
        .clk(clk));
        //we are simulating a submodule ready signal for testing wait cycles in the apb slave, 
          //so usesSubModuleReady is set to 1 to allow us to control ready signal explicitly
    memory mem(.clk(clk),
     .ce(Memory_Bus_i.ce),
      .rden(Memory_Bus_i.rden),
        .wren(Memory_Bus_i.wren),
         .wr_data(Memory_Bus_i.wdata),
          .rd_data(Memory_Bus_i.rdata),
           .addr(Memory_Bus_i.addr));
    
    //apb
    assign APB_i.write = write;
    assign APB_i.sel = sel;
    assign APB_i.enable = enable;
    assign APB_i.wdata = wdata;
    assign APB_i.addr = addr;
    
    //memory
    assign ready = Memory_Bus_i.ready;
    assign wren = Memory_Bus_i.wren;
    assign rden = Memory_Bus_i.rden;
    assign ce = Memory_Bus_i.ce;
    assign rdata = Memory_Bus_i.rdata;
    

    initial
    begin
        clk = 0;
        APB_i.reset_all_apbs; // resetting slave
        assign state = dut.state;
        id = 1;
        mem.initiate();
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);   //write transfer
        @(posedge clk);
        write = 1;
        sel = 1;
        wdata = 5;
        addr= 6;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable =0;
        sel = 0;
        @(posedge clk);    //read transfer
        @(posedge clk);
        write = 0;
        sel = 1;
        addr = 6;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable =0;
        sel = 0;
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_i.wait_cycles = 5;
        @(posedge clk);
        write = 1;
        sel = 1;
        wdata = 4;
        addr= 5;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_i.wait_cycles = 5;
        @(posedge clk);
        write = 0;
        sel = 1;
        addr= 5;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_i.wait_cycles = 1;
        @(posedge clk);
        write = 1;
        sel = 1;
        wdata = 3;
        addr= 4;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_i.wait_cycles = 1;
        @(posedge clk);
        write = 0;
        sel = 1;
        addr= 4;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_i.wait_cycles = 3;
        @(posedge clk);
        write = 1;
        sel = 1;
        wdata = 2;
        addr= 3;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        Memory_Bus_i.ready = 1;
        @(posedge clk);
        enable =0;
        sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_i.wait_cycles = 3;
        @(posedge clk);
        write = 0;
        sel = 1;
        addr= 3;
        Memory_Bus_i.ready = 0;
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        Memory_Bus_i.ready = 1;
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