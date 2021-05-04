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
    logic [4:0] state;
    logic [7:0] test;
    
    //apb-master signals
    logic wren, rden, clk, ce, error;
    logic [7:0] wdata, rdata, addr;
    
    //interfaces
    I2C I2C();
    APB_I2C_Bus apb();
    
    //modules
//    memory mem(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
//        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
    I2C_Master dut(I2C.master, apb.master, clk8x, state, test);
    
    //control vars linkage to interfaces
    assign SCL = I2C.SCL;
    assign SDA = I2C.SDA;
    assign I2C.reset = reset;
    
    assign apb.wren = wren;
    assign apb.rden = rden;
    //assign apb.clk = clk8x;// should be set in apb separately
    assign apb.ce = ce;
    assign apb.wdata = wdata;
    assign apb.rdata = rdata;
    assign apb.addr = addr;
    assign apb.error = error;
    
    
    initial
    begin
        clk8x <= 1;
        assign clk = SCL;
        
        @(negedge clk8x); reset <= 1; @(posedge clk8x);
        @(negedge clk8x); reset <= 0; @(posedge clk8x);
        
        @(negedge clk);
        rden = 1;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address
        //start state initialized after 2 clk8s
        @(posedge clk);//read transfer starting with start state
        //start state ends afte 2 clk8s
        
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
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//slave acknowledge selection
        
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
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//acknowledge from master
        
        //write tranfer
        @(posedge clk);//stop condition

        I2C.SDA <= 0;
        @(posedge clk8x);
        @(posedge clk8x);
        I2C.SDA <= 1;
        @(posedge clk);//start condition
        I2C.SDA <= 1;
        @(posedge clk8x);
        @(posedge clk8x);
        I2C.SDA <= 0;
        
        
        
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//device address
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
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//write
        //0
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);//acknowledge selection
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//memory address
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
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);
        //0
        
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data write
        //0
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);
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
        
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);//acknowledge from slave

        //read transfer of written data
        @(posedge clk);//re-start condition
        I2C.SDA <= 1;
        @(posedge clk8x);
        @(posedge clk8x);
        I2C.SDA <= 0;
        
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
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);
        //1
        @(posedge clk);//read
        //1
        @(negedge clk); I2C.SDA <= 1;@(posedge clk);//acknowledge selection
        
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//memory address
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
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);
        //0
        
        @(negedge clk); I2C.SDA <= 1; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(negedge clk); I2C.SDA <= 0; @(posedge clk);//acknowledge from master
        
        
        
        $finish;
    end
    
    always begin
        #5 clk8x <= ~clk8x;
    end
endmodule
