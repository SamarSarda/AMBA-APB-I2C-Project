`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2021 07:11:47 PM
// Design Name: 
// Module Name: APB_Slave_with_mem
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


module APB_Slave_with_mem(
    APB_Bus APB_i,
    input logic [1:0] id,
    input clk
    );
    
    Memory_Bus Memory_Bus_i();

    memory mem(.clk(clk),
         .ce(Memory_Bus_i.ce),
          .rden(Memory_Bus_i.rden),
            .wren(Memory_Bus_i.wren),
             .wr_data(Memory_Bus_i.wdata),
              .rd_data(Memory_Bus_i.rdata),
               .addr(Memory_Bus_i.addr));
               
     APB_Slave dut(.sl(APB_i.slave),
     .msl(Memory_Bus_i.slave),
      .id(id),
       .usesSubModuleReady(1),
        .clk(clk));
endmodule
