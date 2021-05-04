`timescale 1 ns / 1 ps
module cpu;

logic clk,clk2;
reg [7:0] read_array [7:0];
reg [7:0] reg_array [7:0];
wire [7:0] apb_addr;
wire [7:0] apb_data;
wire [3:0] apb_device;
wire apb_write;
wire ready;
bit_cpu cpu(.clk(clk),.clk2(clk2), .ready(ready), .apb_write(apb_write), .apb_addr(apb_addr), .apb_data(apb_data), .apb_device(apb_device));

int i;
initial
	begin
	    reg_array[0] = 8'b00011111;
	    reg_array[1] = 8'b00000001;
	    reg_array[2] = 8'b00011110;
	    reg_array[3] = 8'b00000001;
	    reg_array[4] = 8'b00000001;
	    reg_array[5] = 8'b00011111;
	    reg_array[6] = 8'b00011111;
		clk<=0;
		clk2<=0;
		#1000
		$finish;
	end
always 
	begin
		#5 clk = ~clk;
		#30 clk2 = ~clk2;
	end

initial begin
$readmemb ("C:\Users\samsa\Desktop\ENEE459D\I2C project\I2C project.sim\sim_1\behav\xsim\result.dat",read_array,0,7); 
$display("im gere now");
for (i = 0; i<7; i=i+1)
    if(reg_array[i] != read_array[i]) begin
        $display("an error occurred");
    end
end
endmodule