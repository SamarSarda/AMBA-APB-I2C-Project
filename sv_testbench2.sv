`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2021 11:17:27 AM
// Design Name: 
// Module Name: sv_testbench
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



module sv_testbench2(
       
    );
    
    reg clk;
    reg write;
    reg sel;
    reg enable;
    wire rdy, wren, rden;
    APB intf(.clk(clk));
    Memory_Bus intf2();
    APB_Slave dut(intf.slave, intf2.slave);
    assign write = intf.write;
    assign enable = intf.enable;
    assign sel = intf.sel;
    assign rdy = intf.ready;
    assign wren = intf2.wren;
    assign rden = intf2.rden;
    initial begin
        intf.reset_slave;
    end
    initial
    begin
        intf.wait_cycles = 5;
        #10;   //write transfer
        clk <= 1;
        write <= 1;
        sel <= 1;
        #10;
        clk <=0;
        #10;
        clk <= 1;
        enable <= 1;
        #10;
        clk <= 0;
        #10;
        clk <= 1;
        enable <=0;
        sel <= 0;
        #10;
        clk <= 0;
        #10;
        clk <= 1;
        #10;
        clk <= 0;
        #10;     //read transfer
        clk <= 1;
        write <= 0;
        sel <= 1;
        #10;
        clk <=0;
        #10;
        clk <= 1;
        enable <= 1;
        #10;
        clk <= 0;
        #10;
        clk <= 1;
        enable <=0;
        sel <= 0;
        #10;
        clk <= 0;
        #10;
        clk <= 1;
        #10;
        clk <= 0;
        $finish;
    end
endmodule