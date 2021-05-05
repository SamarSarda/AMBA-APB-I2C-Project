`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/28/2021 10:04:41 AM
// Design Name: 
// Module Name: I2C_master_testbench
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


module I2C_master_testbench();
    //control vars to be linked with interfaces
    //i2c master-slave signals
    logic clk;
    logic clk8x;
    logic SCL;
    logic SDA;
    logic reset;
    logic [4:0] master_state;
    logic [7:0] master_data;
    
    //apb-master signals
    logic wren, rden, clk, ce, error;
    logic [7:0] wdata, rdata, addr;
    
    //interfaces
    I2C_Bus I2C_Bus();
    I2C_test_signals test();
    APB_I2C_Bus apb();
    
    //modules
//    memory mem(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
//        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
    I2C_Master dut(I2C_Bus.master, apb.master, clk8x, test);
    
    //control vars linkage to interfaces
    assign SCL = I2C_Bus.SCL;
    assign SDA = I2C_Bus.SDA;
    assign I2C_Bus.reset = reset;
    
    assign apb.wren = wren;
    assign apb.rden = rden;
    //assign apb.clk = clk8x;// should be set in apb separately
    assign apb.ce = ce;
    assign apb.wdata = wdata;
    assign apb.rdata = rdata;
    assign apb.addr = addr;
    assign apb.error = error;
    
    assign master_state = test.master_state;
    assign master_data = test.master_data;
    
    
    initial
    begin
        clk8x <= 1;
        assign clk = SCL;
        
        @(negedge clk8x); reset <= 1; @(posedge clk8x);
        @(negedge clk8x); reset <= 0; @(posedge clk8x);
        
        @(negedge clk);
        rden = 1;
        wren = 0;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address

        @(posedge clk);//read transfer starting with start state
        
        //device address bits sent at each negedge
        @(posedge clk);//device address
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //1
        
        @(posedge clk);//read
        //1
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//slave acknowledge selection
        
        @(posedge clk);//memory address
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //1
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        
        @(negedge clk); I2C_Bus.SDA = 1; @(posedge clk);//acknowledge from master
        
        
        //stop happens between here
        
        
        @(negedge clk);//reseting ce so that master stays idle
        ce <= 0;
        
        @(posedge clk); 
        
        //idle state starts between here
        
        @(negedge clk);
        @(posedge clk);//still idle
        @(posedge clk);//still idle
        
        //write tranfer
        @(negedge clk);
        rden = 0;
        wren = 1;
        wdata = 8'b01011111;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address
        
        //write transfer starting with start state
        
        @(posedge clk);//start
        
        @(posedge clk);//device address
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //1
        @(posedge clk);//write
        //0
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//slave acknowledge selection
        
        @(posedge clk);//memory address
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //0
        @(posedge clk);
        //1
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data write
        //0
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(posedge clk);
        //1
        @(posedge clk);
        //1
        @(posedge clk);
        //1
        @(posedge clk);
        //1
        @(posedge clk);
        //1
        @(posedge clk);
        //1
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//acknowledge from slave
        
        //reseting ce so that master stays idle
        @(negedge clk);
        ce <= 0;
        @(posedge clk); //still idle
        
        //stop happens between here
        
        @(negedge clk);
        
        //idle state starts between here
        
        @(posedge clk); //still idle
        @(posedge clk); //still idle
        @(posedge clk); //still idle
        @(posedge clk); //still idle
           
        
        
        
        $finish;
    end
    
    always begin
        #5 clk8x <= ~clk8x;
    end
endmodule
