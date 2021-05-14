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
    I2C_Bus i2c_bus(clk);
    APB_I2C_Bus apb_i2c_bus();
    
    //modules
    memory mem(.clk(clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
        
    I2C i2c(i2c_bus, I2C_Memory_Bus_i, apb_i2c_bus, id, clk);//connect with system clock (clk8x)
    
    
    //control vars linkage to interfaces
    assign SCL = i2c_bus.SCL;
    assign SDA = i2c_bus.SDA;
    assign reset = i2c_bus.reset;
    
    //apb_i2c_bus interface linkage
    assign apb_i2c_bus.wren = wren;
    assign apb_i2c_bus.rden = rden;
    assign apb_i2c_bus.ce = ce;
    assign apb_i2c_bus.wdata = wdata;
    assign rdata = apb_i2c_bus.rdata;
    assign apb_i2c_bus.addr = addr;
    assign error = apb_i2c_bus.error;
    assign ready = apb_i2c_bus.ready;
    
    //test signals
    assign slave_state = i2c.slave.state;
    assign slave_data = i2c.slave.data_buffer;
    assign master_state = i2c.master.state;
    assign master_data = i2c.master.data;
    assign slave_select = i2c.slave.slave_address_buffer;
    assign slave_mem_address = i2c.slave.mem_address_buffer;
    
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
        clk <= 1;
        //memory_shadow[0] = mem.mem[1];
        
//        @(negedge clk); reset <= 1; @(posedge clk);
//        @(negedge clk); reset <= 0; @(posedge clk);
        I2C_Bus.reset_I2Cs;
        
         //write tranfer
        @(negedge SCL);

        rden = 0;
        wren = 1;
        wdata = 8'b01011111;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address
        
        //write transfer starting with start state
        
        @(posedge SCL);//start
        
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
        @(posedge SCL);
        //1
        @(posedge SCL);//write
        //0
        @(posedge SCL);//slave acknowledge selection
        
        @(posedge SCL);//memory address
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
        @(posedge SCL);
        //1
        
        @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data write
        //0
        @(posedge SCL);
        //1
        @(posedge SCL);
        //0
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
        
        @(posedge SCL);//acknowledge from slave
        
        //reseting ce so that master stays idle
        @(negedge SCL);
        ce <= 0;
        @(posedge SCL); //still idle
        
        //stop happens between here
        
        @(negedge SCL);
        
        //idle state starts between here
        
        @(posedge SCL); //still idle
        @(posedge SCL); //still idle
        @(posedge SCL); //still idle
        @(posedge SCL); //still idle
           
        
        @(negedge SCL);
        
        
        rden = 1;
        wren = 0;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address

        @(posedge SCL);//read transfer starting with start state
        
        //device address bits sent at each negedge
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
        @(posedge SCL);
        //1
        
        @(posedge SCL);//read
        //1
        @(posedge SCL);//slave acknowledge selection
        
        @(posedge SCL);//memory address
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
        @(posedge SCL);
        //1
        @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data read
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        
        @(posedge SCL);
        @(posedge SCL);
        
        @(posedge SCL);//acknowledge from master
        
        
        //stop happens between here
        
        
        @(negedge SCL);//reseting ce so that master stays idle
        ce <= 0;
        
        @(posedge SCL); 
        
        //idle state starts between here
        
        @(negedge SCL);
        @(posedge SCL);//still idle
        @(posedge SCL);//still idle
        
       
        
        
        
        $finish;
    end
    always begin
        #5 clk <= ~clk;
    end
    always @(posedge clk) begin
        c = c + 1;
    end
    
endmodule

