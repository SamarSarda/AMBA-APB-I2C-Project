`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 08:36:13 PM
// Design Name: 
// Module Name: processor_master_tb
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


module processor_master_tb();
    
    
    
    logic clk,clk2;
    reg [7:0] read_array [7:0];
    reg [7:0] reg_array [7:0];
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [3:0] sel;
    logic [2:0] state;
    logic stable;
    logic start;
    logic ready;
    APB_Bus APB_i(clk2);
    Processor_Bus Processor_bus_i();
    bit_cpu cpu(.clk(clk),.clk2(clk2), .pm(Processor_bus_i.processor));
    APB_Master dut(APB_i.master, Processor_bus_i.master, clk);
    assign stable = Processor_bus_i.stable;
    assign addr = Processor_bus_i.addr;
    assign wdata = Processor_bus_i.wdata;
    assign sel = Processor_bus_i.sel;
    assign start = Processor_bus_i.start;
    assign rdata = Processor_bus_i.rdata;
    assign APB_i.ready = 1;
    assign state = dut.state;
    assign ready = APB_i.ready;
    int i;
    initial
        begin
            reg_array[0] = 8'b00011111;
            reg_array[1] = 8'b00000001;
            reg_array[2] = 8'b00011110;
            reg_array[3] = 8'b00000001;
            reg_array[4] = 8'b00000001;
            reg_array[5] = 8'b00011111;
            reg_array[6] = 8'b00011111;
            clk<=1;
            clk2<=1;
            APB_i.reset_APBs; // reset_all_apbs;
            #1000
            $finish;
        end
    always 
        begin
            #5 clk = ~clk;
            #30 clk2 = ~clk2;
        end
    
    initial begin
    $readmemb ("C:\Users\samsa\Desktop\ENEE459D\I2C project\I2C project.sim\sim_1\behav\xsim\result.dat",read_array,0,7); 
    $display("im gere now");
    for (i = 0; i<7; i=i+1)
        //if(reg_array[i] != read_array[i]) begin
        //    $display("an error occurred");
        //end
        $display("%b", read_array[i]);
    end

endmodule
