`timescale 1 ns / 1 ps
module regfile (
				input clk,
				input [2:0] reg_write_addr,
				input [7:0] reg_write_data,
				input reg_write_en,
				input [2:0] reg1_read_addr,
				input [2:0] reg2_read_addr, 
				input apb_op,
				input [7:0] apb_data,
				output [7:0] reg1_read_data, 
				output [7:0] reg2_read_data);

reg [7:0] reg_array [7:0];
reg [7:0] read_array [7:0];
integer i,f;

initial 
begin
  for(i=0;i<8;i=i+1)
   reg_array[i] <= 8'd0;
end

always@(posedge clk) 
begin
    if(reg_write_en && apb_op) begin reg_array[7] = apb_data;
    end 
  
	else if(reg_write_en) begin reg_array[reg_write_addr] = reg_write_data;
	//$display ("%b",reg_write_addr);
	end
end

initial
 begin
 #1000

$writememb ("C:\Users\samsa\Desktop\ENEE459D\I2C project\I2C project.sim\sim_1\behav\xsim\result.dat",reg_array,0,7); 
 

 
  

  /*
  $display ("time = %d\n", $time, 
  "\treg[0] = %b\n", reg_array[0],   
  "\treg[1] = %b\n", reg_array[1],
  "\treg[2] = %b\n", reg_array[2],
  "\treg[3] = %b\n", reg_array[3],
  "\treg[4] = %b\n", reg_array[4],
  "\treg[5] = %b\n", reg_array[5],
  "\treg[6] = %b\n", reg_array[6],
  "\treg[7] = %b\n", reg_array[7]);
 end
*/
end

assign  reg1_read_data = reg_array[reg1_read_addr];
assign  reg2_read_data = reg_array[reg2_read_addr];
endmodule