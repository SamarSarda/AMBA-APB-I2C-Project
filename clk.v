`timescale 1 ns / 1 ps
module cpu;

reg clk,clk2;

bit_cpu cpu(.clk(clk),.clk2(clk2));

initial
	begin
		clk<=0;
		clk2<=0;
		#300
		$finish;
	end
always 
	begin
		#5 clk = ~clk;
		#30 clk2 = ~clk2;
	end
endmodule