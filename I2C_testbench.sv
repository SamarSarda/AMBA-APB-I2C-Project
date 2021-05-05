`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/25/2021 07:17:43 PM
// Design Name: 
// Module Name: I2C_testbench
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
module I2C_testbench();
    
    
    //control vars to be linked with interfaces
    logic clk;//clk
    logic clk8x;//8 times as fast clk
    
    //I2C signals
    logic SCL;
    logic SDA;
    logic reset;
    logic [7:0] id;
    
    //apb-i2c bus interface signals
    logic wren, rden, clk, ce, error, ready;
    logic [7:0] wdata, rdata, addr;
    
    //etset interface signals
    logic [3:0] slave_state;
    logic [7:0] slave_data, slave_select, slave_mem_address;
    logic [4:0] master_state;
    logic [7:0] master_data;
    
    //verification structures
    logic [7:0] memory_shadow [0:255];
    
    //loop values
    integer i;
    integer c;
    
    //interfaces
    I2C_Memory_Bus I2C_Memory_Bus_i();
    I2C_Bus i2c_bus();
    I2C_test_signals test();
    APB_I2C_Bus apb();
    
    //modules
    memory mem(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
        
    I2C i2c(i2c_bus, I2C_Memory_Bus_i, apb, id, clk8x, test);//connect with system clock (clk8x)
    
    
    //control vars linkage to interfaces
    assign SCL = i2c_bus.SCL;
    assign SDA = i2c_bus.SDA;
    assign i2c_bus.reset = reset;
    
    //apb interface linkage
    assign apb.wren = wren;
    assign apb.rden = rden;
    assign apb.ce = ce;
    assign apb.wdata = wdata;
    assign apb.rdata = rdata;
    assign apb.addr = addr;
    assign error = apb.error;
    assign ready = apb.ready;
    
    //test interface linkage
    assign slave_state = test.slave_state;
    assign slave_data = test.slave_data;
    assign master_state = test.master_state;
    assign master_data = test.master_data;
    assign slave_select = test.slave_select;
    assign slave_mem_address = test.slave_mem_address;
    
    initial 
    begin
    id <= 1;
    //memory initialization
    mem.initiate(); // initialize values in memory module to be equal to thier index
    //memory_shadow - a copy of all modifications to memory module, for comparison and verification of transfers
    for (i = 0; i < 256; i = i + 1) begin
        memory_shadow[i] = i; //initialized to same values as stored in memory module
    end
    
    
    
    
    end
    initial
    begin
        c = 0;
        clk8x <= 1;
        assign clk = SCL;
        //memory_shadow[0] = mem.mem[1];
        
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
        @(posedge clk);//slave acknowledge selection
        
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
        @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data read
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        @(posedge clk);
        @(posedge clk);
        
        @(posedge clk);//acknowledge from master
        
        
        //stop happens between here
        
        
        @(negedge clk);//reseting ce so that master stays idle
        //ce <= 0;
        
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
        @(posedge clk);//slave acknowledge selection
        
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
        
        @(posedge clk);//acknowledge from slave
        
        @(posedge clk);//data write
        //0
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
        @(posedge clk);
        //1
        
        @(posedge clk);//acknowledge from slave
        
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
    always @(posedge clk8x) begin
        c = c + 1;
    end
    
endmodule


