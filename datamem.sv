module datamem (
				input [7:0] read_addr,
				input [7:0] write_addr,
				input [7:0] write_data,
				input mem_write,
				input mem_read,
				input clk, 
				output reg [7:0] read_data
				);

reg [7:0] register [255:0];

always@(clk && mem_write,clk && mem_read) 
begin
	if(mem_write) begin 
	   register[write_addr] = write_data;
	end
	if(mem_read) begin 
	   read_data = register[read_addr];
    end
end

endmodule 