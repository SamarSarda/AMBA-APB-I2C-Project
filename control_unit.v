module control (
				input [3:0] opcode,
				input [2:0] func,
				output reg reg_dst,
				output reg reg_write,
				output reg alusrc,
				output reg [2:0]alufn,
				output reg mem_write, 
				output reg mem_read,
				output reg mem_to_reg,
				output reg nia);
always @(*) 
begin
	if (opcode == 4'b0000) 
	begin
		if (func == 3'b000) 
		begin
		alufn		= 3'b000;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == 3'b010) 
		begin
		alufn		= 3'b001;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == 3'b100) 
		begin
		alufn		= 3'b010;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == 3'b101) 
		begin
		alufn		= 3'b011;
		alusrc		= 1'b0;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
	end
	else if (opcode==4'b0100)
		begin
		alufn		= 3'b100;
		alusrc		= 1'b1;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1011)
		begin
		alufn		= 3'b101;
		alusrc		= 1'b1;
		mem_to_reg 	= 1'b0;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b1;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1111)
		begin
		alufn		= 3'b110;
		alusrc		= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode==4'b1000)
		begin
		alufn		= 3'b111;
		alusrc		= 1'b1;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode==4'b0010)
		begin
		alusrc		= 1'b1;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b0;	
		end
end
endmodule