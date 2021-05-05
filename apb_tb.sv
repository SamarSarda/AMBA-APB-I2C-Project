`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/16/2021 06:37:46 PM
// Design Name: 
// Module Name: apb_tb
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


module apb_tb();

    logic clk, reset;

    //states
    logic [2:0] state;
    logic [4:0] apb_master_state, apb_slave1_state, apb_slave2_state, i2c_master_state, i2c_slave_state;

    //processor
    logic p_write, clk, p_reset, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb1
    logic a_write1, a_ready1, enable1, a_reset1;
    logic [7:0] a_wdata1, a_rdata1, a_addr1;
    logic [1:0] a_sel1;
    //apb2
    logic a_write2, a_ready2, enable2, a_reset2;
    logic [7:0] a_wdata2, a_rdata2, a_addr2;
    logic [1:0] a_sel2;
    
    //slave ids
    logic [1:0] id1; 
    logic [1:0] id2;
    
    //i2c
    logic [7:0] id;
    
    //i2c test interface signals
    logic [3:0] slave_state;
    logic [7:0] slave_data, slave_select, slave_mem_address;
    logic [4:0] master_state;
    logic [7:0] master_data;
    
//    //memory1
//    logic ready1, wren1, ce1, rden1;
//    logic [7:0] rdata1;
    
    //interfaces
    APB_Bus APB_1(clk);
    APB_Bus APB_2(clk);
    Memory_Bus Memory_Bus_1();
    Memory_Bus Memory_Bus_2();
    Processor_Bus Processor_bus_i(clk, reset);
    //I2C
    I2C_Memory_Bus I2C_Memory_Bus_i();
    I2C_Bus i2c_bus();
    I2C_test_signals test();
    APB_I2C_Bus apb();
    
    
    //APB_Slave dut(.sl(APB_i.slave), .msl(Memory_Bus_i.slave));
    
    //modules
    APB dut(APB_1, 
    APB_2, 
    Memory_Bus_1, 
    Memory_Bus_2, 
    Processor_bus_i, 
    id1, 
    id2, 
    clk);
    
    memory mem1(.clk(Memory_Bus_1.clk), .ce(Memory_Bus_1.ce), .rden(Memory_Bus_1.rden), 
        .wren(Memory_Bus_1.wren), .wr_data(APB_1.wdata), .rd_data(Memory_Bus_1.rdata), .addr(APB_1.addr));
    
    //modules
    memory memi2c(.clk(I2C_Memory_Bus_i.clk), .ce(I2C_Memory_Bus_i.ce), .rden(I2C_Memory_Bus_i.rden), 
        .wren(I2C_Memory_Bus_i.wren), .wr_data(I2C_Memory_Bus_i.wdata), .rd_data(I2C_Memory_Bus_i.rdata), .addr(I2C_Memory_Bus_i.addr));
        
    I2C i2c(i2c_bus, I2C_Memory_Bus_i, apb, id, clk, test);//connect with system clock (clk)

    
    //connecting I2C to apb slave:
    //apb interface linkage
    assign apb.wren = Memory_Bus_2.wren;
    assign apb.rden = Memory_Bus_2.rden;
    assign apb.ce = Memory_Bus_2.ce;
    assign apb.wdata = Memory_Bus_2.wdata;
    assign apb.addr = Memory_Bus_2.addr;
    assign Memory_Bus_2.rdata = apb.rdata;
    assign Memory_Bus_2.error = apb.error;
    assign Memory_Bus_2.ready = apb.ready;

    //i2c bus
    assign SCL = i2c_bus.SCL;
    assign SDA = i2c_bus.SDA;
    assign i2c_bus.reset = reset;
    
    //i2c test interface linkage
    assign slave_state = test.slave_state;
    assign slave_data = test.slave_data;
    assign master_state = test.master_state;
    assign master_data = test.master_data;
    assign slave_select = test.slave_select;
    assign slave_mem_address = test.slave_mem_address;

    //apb master signals
    assign a_ready1 = APB_1.ready;
    assign enable1 = APB_1.enable;
    assign a_write1 = APB_1.write;
    assign a_reset1 = APB_1.reset;
    assign a_wdata1 = APB_1.wdata;
    assign a_addr1 = APB_1.addr;
    assign a_sel1 = APB_1.sel;
    assign a_rdata1 = APB_1.rdata;
    
    assign a_ready2 = APB_2.ready;
    assign enable2 = APB_2.enable;
    assign a_write2 = APB_2.write;
    assign a_reset2 = APB_2.reset;
    assign a_wdata2 = APB_2.wdata;
    assign a_addr2 = APB_2.addr;
    assign a_sel2 = APB_2.sel;
    assign a_rdata2 = APB_2.rdata;
    
    //processor bus
    assign Processor_bus_i.write = p_write;
    assign p_reset = Processor_bus_i.reset;
    assign stable = Processor_bus_i.stable;
    assign Processor_bus_i.start = start;
    assign Processor_bus_i.wdata = p_wdata;
    assign Processor_bus_i.addr = p_addr;
    assign Processor_bus_i.sel = p_sel;
    assign p_rdata = Processor_bus_i.rdata;
    
    
//    //memory 1
//    assign ready1 = Memory_Bus_i.ready;
//    assign wren1 = Memory_Bus_i.wren;
//    assign rden1 = Memory_Bus_i.rden;
//    assign ce1 = Memory_Bus_i.ce;
//    assign rdata1 = Memory_Bus_i.rdata;
    
    
    
    initial 
    begin
        id1 = 1;
        id2 = 2;
        Processor_bus_i.reset_master;
        APB_1.reset_slave;
        APB_2.reset_slave;
        assign apb_master_state = dut.master.state;
        assign apb_slave1_state = dut.slave1.state;
        assign apb_slave2_state = dut.slave2.state;
        assign i2c_master_state = i2c.master.state;
        assign i2c_slave_state = i2c.slave.state;
        
        mem1.initiate();
        memi2c.initiate();
        
        @(negedge clk); reset <= 1; @(posedge clk);
        @(negedge clk); reset <= 0; @(posedge clk);
    end
    initial
    begin
        clk = 0;
        
        @(posedge clk);   //write transfer
        p_write = 1;
        p_sel = 1;
        p_wdata = 5;
        start = 1;
        @(posedge clk);
        start = 0;
        while (!a_ready1) begin
            @(posedge clk);
        end
        //en 1
        @(posedge clk);
        //en 0
        p_sel = 0;
        
        @(posedge clk);   //read transfer
        p_write = 0;
        p_sel = 1;
        p_addr = 6;
        start = 1;
        @(posedge clk);
        start = 0;
        while (!a_ready1) begin
            @(posedge clk);
        end
        //en 1
        @(posedge clk);
        //en 0
        p_sel = 0;
        
        
        @(posedge clk);    //read transfer
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr = 6;
        start = 1;
        @(posedge clk);
        start = 0;
        
        @(posedge clk);
        p_sel = 0;
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_i.wait_cycles = 5;
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_wdata = 4;
        p_addr= 5;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_i.wait_cycles = 5;
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr= 5;
        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //write transfer with wait states
        //APB_i.wait_cycles = 1;
        @(posedge clk);
        p_write = 1;
        p_sel = 1;
        p_wdata = 3;
        p_addr= 4;

        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);

        @(posedge clk);

        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);     //read transfer with wait states
        //APB_i.wait_cycles = 1;
        @(posedge clk);
        p_write = 0;
        p_sel = 1;
        p_addr= 4;

        start = 1;
        @(posedge clk);
        start = 0;
        @(posedge clk);

        @(posedge clk);
        
        p_sel = 0;  
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
    always begin
        #10 clk = ~clk;
    end
endmodule