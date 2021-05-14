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
    logic ready;
    logic [4:0] master_state;
    logic [7:0] master_data;

    
    //apb-master signals
    logic wren, rden, clk, ce, error;
    logic [7:0] wdata, rdata, addr;
    
    //interfaces
    I2C_Bus I2C_Bus(clk);
    APB_I2C_Bus apb();
    
    //modules
    I2C_Master dut(I2C_Bus.master, apb.master, clk);
    
    //control vars linkage to interfaces
    assign SCL = I2C_Bus.SCL;
    assign SDA = I2C_Bus.SDA;
    assign reset = I2C_Bus.reset;
    
    assign apb.wren = wren;
    assign apb.rden = rden;
    //assign apb.clk = clk8x;// should be set in apb separately
    assign apb.ce = ce;
    assign apb.wdata = wdata;
    assign rdata = apb.rdata;
    assign apb.addr = addr;
    assign error = apb.error;
    
    assign master_state = dut.state;
    assign master_data = dut.data;
    assign ready = apb.ready;
    
    
    initial
    begin
        clk <= 1;
        SCL <= 1;
        
        I2C_Bus.reset_master;
//        @(negedge clk); reset <= 1; @(posedge clk);
//        @(negedge clk); reset <= 0; @(posedge clk);
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//slave acknowledge selection
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data read
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA = 1; @(posedge SCL);//acknowledge from master
        
        
        //stop happens between here
        
        
        @(negedge SCL);//reseting ce so that master stays idle
        ce <= 0;
        
        @(posedge SCL); 
        
        //idle state starts between here
        
        @(negedge SCL);
        @(posedge SCL);//still idle
        @(posedge SCL);//still idle
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//slave acknowledge selection
        
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
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from slave
        
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
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from slave
        
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
           
//error testing
//error 1: enable signal becomes 0 before transfer is complete   
        @(negedge SCL);
        rden = 1;
        wren = 0;
        ce = 1;
        addr = 8'b01000001;//first 2 bits device id, second 6 bits mem address

        @(posedge SCL);//read transfer starting with start state
        
        //device address bits sent at each negedge
        @(posedge SCL);
        ce = 0;
        
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);//idle
        @(posedge SCL);//idle
        
//error 2: slave doesnt acknowledge address (i.e. no slaves with desired address are connected)
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
        @(negedge SCL); //no acknowledge happens here
         @(posedge SCL);
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);// since ce is active immediately back to addressing state
        @(posedge SCL);//addressing
        ce = 0;
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);//idle
        @(posedge SCL);//idle
        
//error 3: no acknowledge on slave memory address
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//slave acknowledge selection
        
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
        @(negedge SCL);// no acknowledge 
         @(posedge SCL);
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);// since ce is active immediately back to addressing state
        @(posedge SCL);//addressing
        ce = 0;
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);//idle
        @(posedge SCL);//idle
        
//error 4: an X in received data when reading
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//slave acknowledge selection
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from slave
        
        @(posedge SCL);//data read
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(posedge SCL);
        @(negedge SCL); I2C_Bus.SDA <= 1; @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);
        @(negedge SCL); I2C_Bus.SDA <= 1'bx; @(posedge SCL);
        
        @(negedge SCL); I2C_Bus.SDA = 1; @(posedge SCL);//acknowledge from master
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);// since ce is active immediately back to addressing state
        @(posedge SCL);//addressing
        ce = 0;
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);//idle
        @(posedge SCL);//idle
        
//error 5: no acknowledge from slave at the end of a write transfer
        
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
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//slave acknowledge selection
        
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
        
        @(negedge SCL); I2C_Bus.SDA <= 0; @(posedge SCL);//acknowledge from slave
        
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
        
        @(negedge SCL); //no acknowledge from slave
         @(posedge SCL);
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);// since ce is active immediately back to addressing state
        @(posedge SCL);//addressing
        ce = 0;
        //between these clock pulses an error should be thrown and the device reset to idle state
        @(posedge SCL);//idle
        @(posedge SCL);//idle
        
        
        $finish;
    end
    
    always begin
        #5 clk <= ~clk;
    end
endmodule
