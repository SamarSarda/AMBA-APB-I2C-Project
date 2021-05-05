`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 07:17:43 PM
// Design Name: 
// Module Name: I2C_slave_testbench
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

//need to make sure to set memory to have mem[1] <= 5; when running this code
module I2C_slave_testbench();
    
    //control vars to be linked with interfaces
    logic clk;
    logic clk8x;
    logic SCL;
    logic SDA;
    logic reset;
    logic [7:0] id;
    logic [3:0] slave_state;
    logic [7:0] slave_data;
    
    //interfaces
    I2C_Memory_Bus I2C_Memory_Bus_i();
    I2C_Bus I2C_Bus();
    I2C_test_signals test();
    
    //modules
    memory mem(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
        
    I2C_Slave dut(I2C_Bus.slave, I2C_Memory_Bus.slave, id, clk8x, test);
    
    //control vars linkage to interfaces
    assign I2C_Bus.SCL = SCL;
    assign SDA = I2C_Bus.SDA;
    assign I2C_Bus.reset = reset;
    
    assign slave_state = test.slave_state;
    assign slave_data = test.slave_data;
    
    initial 
    begin
    id <= 1;
    mem.initiate();
    end
    initial
    begin
        clk <= 1;
        clk8x <= 1;
        SCL <= 0;
        I2C_Bus.SDA <= 1;
                    //read transfer
        reset = 1;//set state to stop, initial state
        @(posedge clk);
        SCL <= 1;
        @(negedge clk);
        SCL = 0;
        reset = 0;
        @(posedge clk);
        SCL <= 1;
        
        @(posedge clk);
        SCL <= 1;
        @(negedge clk);//start condition
        I2C_Bus.SDA <= 0;
        @(negedge clk);
        assign SCL = clk;
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        
        @(posedge clk);//read
        //1
        @(posedge clk);//acknowledge selection
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//memory address
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//acknowledge from master
        
        //write tranfer
        @(posedge clk);//stop condition

        I2C_Bus.SDA <= 0;
        @(posedge clk8x);
        @(posedge clk8x);
        I2C_Bus.SDA <= 1;
        @(posedge clk);//start condition
        @(posedge clk8x);
        @(posedge clk8x);
        I2C_Bus.SDA <= 0;
        
        
        
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//device address
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//write
        //0
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);//acknowledge selection
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//memory address
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);
        //0
        
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);//acknowledge from slave
        
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
        
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);//acknowledge from slave

        //read transfer of written data
        @(posedge clk);//re-start condition
        I2C_Bus.SDA <= 1;
        @(posedge clk8x);
        @(posedge clk8x);
        I2C_Bus.SDA <= 0;
        
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(posedge clk);//read
        //1
        @(negedge clk); I2C_Bus.SDA <= 1;@(posedge clk);//acknowledge selection
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//memory address
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
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);
        //1
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);
        //0
        
        @(negedge clk); I2C_Bus.SDA <= 1; @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(negedge clk); I2C_Bus.SDA <= 0; @(posedge clk);//acknowledge from master
        
        
        $finish;
    end
    always begin
        #40 clk <= ~clk;
    end
    always begin
        #5 clk8x <= ~clk8x;
    end
    
endmodule


