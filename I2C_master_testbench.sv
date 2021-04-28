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
    logic clk;
    logic clk2x;
    logic SCL;
    logic SDA;
    logic reset;
    logic [3:0] state;
    logic [7:0] s_a_b_m;
    
    logic wren, rden, clk, ce;
    logic [7:0] wdata, rdata, addr;
    
    //interfaces
    I2C I2C();
    APB_bus apb();
    
    //modules
    memory mem(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
    I2C_Slave dut(I2C.slave, I2C_Memory_Bus.slave, id, state, s_a_b_m, clk2x);
    
    //control vars linkage to interfaces
    assign SCL = I2C.SCL;
    assign SDA = I2C.SDA;
    assign I2C.reset = reset;
    
    assign apb.wren = wren;
    assign apb.rden = rden;
    assign apb.clk = clk;
    assign apb.ce = ce;
    assign apb.wdata = wdata;
    assign apb.rdata = rdata;
    assign apb.addr = addr;
    
    
    initial
    begin
        clk = 0;
        
        rden = 1;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address
        
        @(posedge SCL);//
        
                    //read transfer
        reset <= 1;//set state to stop, initial state
        @(posedge clk);
        SCL = 1;
        @(negedge clk);
        SCL = 0;
        reset <= 0;
        @(posedge clk);
        SCL = 1;
        
        @(posedge clk);
        SCL = 1;
        @(negedge clk);//start condition
        I2C.SDA = 0;
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
        @(posedge clk);
        //1
        I2C.SDA = 1;
        @(posedge clk);//read
        //1
        @(posedge clk);//acknowledge selection
        
        @(posedge clk);//memory address
        I2C.SDA = 0;
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
        I2C.SDA = 1;
        @(posedge clk);//acknowledge
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(posedge clk);//acknowledge from master
        
        //write tranfer
        @(posedge clk);//stop condition
        I2C.SDA = 0;
        @(posedge clk2x);
        I2C.SDA = 1;
        @(posedge clk);//start condition
        I2C.SDA = 1;
        @(posedge clk2x);
        I2C.SDA = 0;
        
        
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
        I2C.SDA = 1;
        @(posedge clk);//write
        I2C.SDA = 0;
        //0
        @(posedge clk);//acknowledge selection
         @(posedge clk);//memory address
        I2C.SDA = 0;
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
        I2C.SDA = 1;
        //1
        @(posedge clk);
        //0
        I2C.SDA = 0;
        
        @(posedge clk);//acknowledge
        
        @(posedge clk);//data write
        //0
        @(posedge clk);
        //1
        I2C.SDA = 1;
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
        
        @(posedge clk);//acknowledge

        //read transfer of written data
        @(posedge clk);//re-start condition
        I2C.SDA = 1;
        @(posedge clk2x);
        I2C.SDA = 0;
        
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
        I2C.SDA = 1;
        @(posedge clk);//read
        //1
        @(posedge clk);//acknowledge selection
        
        @(posedge clk);//memory address
        I2C.SDA = 0;
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
        I2C.SDA = 1;
        @(posedge clk);
        //0
        I2C.SDA = 0;
        
        @(posedge clk);//acknowledge
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(posedge clk);//acknowledge from master
        
        
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule
