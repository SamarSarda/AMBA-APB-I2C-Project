`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2021 05:03:49 AM
// Design Name: 
// Module Name: top_level_tb
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


module top_level_tb();
    
    logic clk;
    logic [4:0] apb_slave1_state, apb_slave2_state, i2c_master_state, i2c_slave_state, apb_master_state;
    logic i2c_master_ready;
    logic [7:0] i2c_master_rdata, apb_slave_memory_bus_rdata;
    
    logic [1:0] apb_slave1_id, apb_slave2_id;

    //processor
    logic p_write, stable, start;
    logic [7:0] p_wdata, p_rdata, p_addr;
    logic [1:0] p_sel;
    
    //apb
    logic a_write, a_ready, enable, a_reset;
    logic [7:0] a_wdata, a_rdata, a_addr;
    logic [1:0] a_sel;
    
    logic [7:0] s1_rdata, s2_rdata, rdata_mux_result;
    logic s1_ready, s2_ready, ready_mux_result;
    
    integer i, r, r_w, a, wd;
    integer success_reads, success_writes, failure_reads, failure_writes;
    
    //interfaces
    APB_Bus apb_bus(clk);
    Processor_Bus processor_bus();
    
    //modules
    APB_Master master(apb_bus.master, processor_bus.master, clk);
    mux4to1_8bit rdata_mux(.Data_in_0(0), .Data_in_1(s1_rdata), .Data_in_2(s2_rdata), .Data_in_3(0), .sel(apb_bus.sel));
    mux4to1_1bit ready_mux(.Data_in_0(0), .Data_in_1(s1_ready), .Data_in_2(s2_ready), .Data_in_3(0), .sel(apb_bus.sel));
    APB_slave_with_I2C_peripheral si2c(apb_bus, apb_slave1_id, clk, s1_rdata, s1_ready);
    APB_Slave_with_mem sm(apb_bus, apb_slave2_id, clk, s2_rdata, s2_ready);
    
    //apb
    assign a_ready = apb_bus.ready;
    assign enable = apb_bus.enable;
    assign a_write = apb_bus.write;
    assign a_reset = apb_bus.reset;
    assign a_wdata = apb_bus.wdata;
    assign a_addr = apb_bus.addr;
    assign a_sel = apb_bus.sel;
    assign a_rdata = apb_bus.rdata;
    
    assign apb_bus.rdata = rdata_mux.Data_out;
    assign apb_bus.ready = ready_mux.Data_out;
    assign rdata_mux_result = rdata_mux.Data_out;
    assign ready_mux_result = ready_mux.Data_out;
    
    //processor
    assign processor_bus.write = p_write;
    assign stable = processor_bus.stable;
    assign processor_bus.start = start;
    assign processor_bus.wdata = p_wdata;
    assign processor_bus.addr = p_addr;
    assign processor_bus.sel = p_sel;
    assign p_rdata = processor_bus.rdata;
    
    //important values
    assign apb_master_state = master.state;
    assign apb_slave1_state = si2c.a2im.apb_slave.state;
    assign apb_slave2_state = sm.dut.state;
    assign i2c_master_state = si2c.a2im.i2c_master.state;
    assign i2c_slave_state = si2c.sm.slave.state;
    assign i2c_master_ready = si2c.a2im.apb_i2c_bus.ready;
    assign i2c_master_rdata = si2c.a2im.apb_i2c_bus.rdata;
    assign apb_slave_memory_bus_rdata = si2c.a2im.memory_bus.rdata;
    assign ce = si2c.a2im.memory_bus.ce;
    assign wren = si2c.a2im.memory_bus.wren;
    assign rden = si2c.a2im.memory_bus.rden;
    
    
    
    
    
    initial 
    begin
        
    end
    initial
    begin
        apb_slave1_id = 1;
        apb_slave2_id = 2;
        clk = 0;
        si2c.initiate;
        apb_bus.reset_APBs;
        sm.initiate;
        success_reads = 0;
        failure_reads = 0;
        success_writes = 0;
        failure_writes = 0;
        r = $urandom(100); // seeding value
        for (i = 0; i < 50; i = i + 1) begin // make value to store number of successes and failures
            r = $urandom_range(0,1);
            r_w = $urandom_range(0,1);
            wd = $urandom_range(0,255);
            
            p_write = r_w[0];
            p_wdata = wd[7:0];
            if (r == 1) begin //I2C transfer
                a = $urandom_range(0,63);
                p_sel = 1;
                p_addr = {2'b01, a[5:0]};
                
                if (p_write == 1) begin
                    $display("Writing %d to APB Slave with I2C at address %d", p_wdata, a[5:0]);
                end else begin
                    $display("Reading from APB Slave with I2C at address %d", a[5:0]);
                end
                
                start = 1;
                
                @(posedge clk);
                start = 0;
                
                while (!apb_bus.ready) begin
                    @(posedge clk);
                end
                
                @(posedge clk);
                p_sel = 0;
                
                
                if (p_write == 1) begin
                    if (p_wdata == si2c.sm.mem.mem[{2'b00,a[5:0]}]) begin
                        $display("Write transfer succeeded");
                        success_writes = success_writes + 1;
                    end else begin
                        $display("Write transfer failed");
                        failure_writes = failure_writes + 1;
                    end
                    
                end else begin
                    if (p_rdata == si2c.sm.mem.mem[{2'b00,a[5:0]}]) begin
                        $display("Read transfer succeeded");
                        success_reads = success_reads + 1;
                    end else begin
                        $display("Read transfer failed");
                        $display("Value was %d, should be %d", p_rdata, si2c.sm.mem.mem[{2'b00,a[5:0]}]);
                        failure_reads = failure_reads + 1;
                    end
                end
                
                @(posedge clk); 
                
            end else begin //mem transfer
                a = $urandom_range(0,255);
                p_sel = 2;
                p_addr = a[7:0];
                
                if (p_write == 1) begin
                    $display("Writing %d to APB Slave with memory at address %d", p_wdata, a[7:0]);
                end else begin
                    $display("Reading from APB Slave with memory at address %d", a[7:0]);
                    $display("Value was %d, should be %d", p_rdata, si2c.sm.mem.mem[a[7:0]]);
                end
                
                start = 1;
                
                @(posedge clk);
                start = 0;
                
                while (!apb_bus.ready) begin
                    @(posedge clk);
                end
                
                @(posedge clk);
                p_sel = 0;
                
                if (p_write == 1) begin
                    if (p_wdata == sm.mem.mem[a[7:0]]) begin
                        $display("Write transfer succeeded");
                        success_writes = success_writes + 1;
                    end else begin
                        $display("Write transfer failed");
                        failure_writes = failure_writes + 1;
                    end
                    
                end else begin
                    if (p_rdata == sm.mem.mem[a[7:0]]) begin
                        $display("Read transfer succeeded");
                        success_reads = success_reads + 1;
                    end else begin
                        $display("Read transfer failed");
                        failure_reads = failure_reads + 1;
                    end
                end
                
                @(posedge clk); 
            end
            $display("Num loops: %d", i);
            
        end
        
        $display("Read successes: %d", success_reads);
        $display("Read failures: %d", failure_reads);
        $display("Write successes: %d", success_writes);
        $display("Write failures: %d", failure_writes);
        $display("End.");
 
        $finish;
    end
    always begin
        #5 clk = ~clk;
    end
endmodule
