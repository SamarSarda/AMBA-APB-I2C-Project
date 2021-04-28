/*
 *
 * Opcodes
 *
 */

`define REGISTER_OPS 4'd0
`define	ADD	3'd0
`define	SUB	3'd1
`define AND 3'd2
`define OR  3'd3
`define ADD_I 4'd4
`define LW 4'd11
`define SW 4'd15
`define BEQ 4'd8
`define JMP 4'd2

/*
 *
 * ALU Ops
 *
 */

`define ALU_OP_ADD 3'b000,
`define ALU_OP_SUB 3'b001,
`define ALU_OP_AND 3'b010,
`define ALU_OP_OR 3'b011,
`define ALU_OP_ADDI 3'b100,
`define ALU_OP_LW 3'b101,
`define ALU_OP_SW 3'b110,
`define ALU_OP_BEQ 3'b111;

/*
 *
 * MUX constants
 *
 */
`define rb_or_mem_out 1'b0
`define imm_or_aluout 1'b1

module control_unit(
    input [3:0] opcode,
    input [2:0] func,
    output reg reg_dst,
    output reg reg_write,
    output reg alusrc,
    output reg [2:0]alufn,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg nia
);

always @(*) 
begin
	if (opcode == `REGISTER_OPS) 
	begin
		if (func == `ADD) 
		begin
		alufn		= `ALU_OP_ADD;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == `SUB) 
		begin
		alufn		= `ALU_OP_SUB;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == `AND) 
		begin
		alufn		= `ALU_OP_AND;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
		if (func == `OR) 
		begin
		alufn		= `ALU_OP_OR;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;
		end
	end
	else if (opcode ==`ADD_I)
		begin
		alufn		= `ALU_OP_ADDI;
		alusrc		= `imm_or_aluout;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode ==`LW)
		begin
		alufn		= `ALU_OP_LW;
		alusrc		= `imm_or_aluout;
		mem_to_reg 	= 1'b0;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b1;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode == `SW)
		begin
		alufn		= `ALU_OP_SW;
		alusrc		= `imm_or_aluout;
		reg_dst		= 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode== `BEQ)
		begin
		alufn		= `ALU_OP_BEQ;
		alusrc		= `imm_or_aluout;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b1;	
		end
	else if (opcode == `JMP)
		begin
		alusrc		= `imm_or_aluout;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b0;	
		end
end
endmodule
