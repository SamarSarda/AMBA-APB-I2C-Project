`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 07:17:43 PM
// Design Name: 
// Module Name: I2C_slave_and_mem_testbench
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
module I2C_slave_with_mem_testbench();
    
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
    I2C_Bus I2C_Bus(clk);
    
    //modules
        
    I2C_slave_with_mem sm(I2C_Bus, id, clk);
    
    //control vars linkage to interfaces
    assign I2C_Bus.SCL = SCL;
    assign SDA = I2C_Bus.SDA;
    assign reset = I2C_Bus.reset;
    
    assign slave_state = sm.slave.state;
    assign slave_data = sm.slave.data_buffer;
    assign slave_select = sm.slave.slave_address_buffer;
    assign slave_mem_address = sm.slave.mem_address_buffer;
    

    initial
    begin
        //load memory values that correspond to their index
        sm.mem.initiate();
        //setup inputs to dut
        id <= 1;
        clk <= 1;
        SCL <= 1;
        
//read transfer from addr 0000 0001, should be 0000 0101
        I2C_Bus.reset_slave;//set state to stop, initial state
       
        
        I2C_Bus.SDA <= 1;
        @(posedge SCL);
        @(posedge SCL);//start condition
        @(posedge clk);
        @(posedge clk);
        I2C_Bus.SDA <= 0;
        @(posedge SCL);//device address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        
        @(posedge SCL);//read
        //1
        @(posedge SCL);//acknowledge selection
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//memory address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data read
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from master
        
//write tranfer to addr 0000 0010 of data 0111 1111
        @(posedge SCL);//stop condition

        I2C_Bus.SDA <= 0;
        @(posedge clk);
        @(posedge clk);
        I2C_Bus.SDA <= 1;
        @(posedge SCL);//start condition
        @(posedge clk);
        @(posedge clk);
        I2C_Bus.SDA <= 0;
        
        
        
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//device address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//write
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);//acknowledge selection
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//memory address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);
        //0
        
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data write
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        @(posedge SCL);
        //1
        
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);//acknowledge from slave
        
//read transfer of written data
//read transfer from addr 0000 0010, should be 0111 1111
        @(posedge SCL);//re-start condition
        I2C_Bus.SDA <= 1;
        @(posedge clk);
        @(posedge clk);
        I2C_Bus.SDA <= 0;
        
        @(posedge SCL);//device address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(posedge SCL);//read
        //1
        @(negedge SCL); I2C_Bus.SDA <= 1;@(posedge SCL);//acknowledge selection
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//memory address
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(posedge SCL);
        //0
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        //1
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);
        //0
        
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data read
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from master
        
        
        $finish;
    end
    always begin
        #40 SCL <= ~SCL;
    end
    always begin
        #5 clk <= ~clk;
    end
    
endmodule


