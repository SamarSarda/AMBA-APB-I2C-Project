/*
 *
 * Opcodes
 *
 */

`define REGISTER_OPS 4'd0
`define	ADD	3'b000
`define	SUB	3'b010
`define AND 3'b100
`define OR  3'b101
`define ADD_I 4'd4
`define LW 4'b1011
`define SW 4'b1111
`define BEQ 4'b1000
`define JMP 4'b0010

/*
 *
 * ALU Ops
 *
 */

`define ALU_OP_ADD 3'b000
`define ALU_OP_SUB 3'b001
`define ALU_OP_AND 3'b010
`define ALU_OP_OR 3'b011
`define ALU_OP_ADDI 3'b100
`define ALU_OP_LW 3'b101
`define ALU_OP_SW 3'b110
`define ALU_OP_BEQ 3'b111

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
    input ready,
    output reg reg_dst,
    output reg reg_write,
    output reg alusrc,
    output reg [2:0]alufn,
    output reg apb_op,
    output reg mem_write,
    output reg mem_read,
    output reg mem_to_reg,
    output reg apb_write,
    output reg continue_flag,
    output reg nia
);

always @(*) 
begin
	if (opcode == `REGISTER_OPS) 
	begin
		if (func == `ADD) 
		begin
		alufn		= `ALU_OP_ADD;
		apb_op      = 1'b0;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;
		end
		if (func == `SUB) 
		begin
		alufn		= `ALU_OP_SUB;
		apb_op      = 1'b0;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;
		end
		if (func == `AND) 
		begin
		alufn		= `ALU_OP_AND;
		apb_op      = 1'b0;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;
		end
		if (func == `OR) 
		begin
		alufn		= `ALU_OP_OR;
		apb_op      = 1'b0;
		alusrc		= `rb_or_mem_out;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;
		end
	end
	else if (opcode ==`ADD_I)
		begin
		alufn		= `ALU_OP_ADDI;
		apb_op      = 1'b0;
		alusrc		= `imm_or_aluout;
		mem_to_reg 	= 1'b1;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode ==`LW)
		begin
		alufn		= `ALU_OP_LW;
		apb_op      = 1'b0;
		alusrc		= `imm_or_aluout;
		mem_to_reg 	= 1'b0;
		reg_dst		= 1'b0;
		reg_write	= 1'b1;
		mem_read	= 1'b1;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode == `SW)
		begin
		alufn		= `ALU_OP_SW;
		apb_op      = 1'b0;
		alusrc		= `imm_or_aluout;
		reg_dst		= 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b1;
		continue_flag = 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode== `BEQ)
		begin
		alufn		= `ALU_OP_BEQ;
		apb_op      = 1'b0;
		alusrc		= `imm_or_aluout;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b1;	
		end
	else if (opcode == `JMP)
		begin
		alusrc		= `imm_or_aluout;
		apb_op      = 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		continue_flag = 1'b1;
		nia			= 1'b0;	
		end
    else if (opcode == 4'b1100)
		begin
		apb_write = 1'b1;
		apb_op      = 1'b1;
		reg_write	= 1'b1;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b0;	
		
		continue_flag = 1'b0;
		
		while(ready == 0) begin
		// do nothing 
		;
		end
		continue_flag = 1'b1;
		// store pm.rdata in register
		end
	else if (opcode == 4'b0001)
		begin
		apb_write = 1'b0;
		apb_op      = 1'b0;
		reg_write	= 1'b0;
		mem_read	= 1'b0;
		mem_write	= 1'b0;
		nia			= 1'b0;	
		continue_flag = 1'b0;
		//add flage
		while(ready == 0) begin
		// do nothing 
		;
		end
		continue_flag = 1'b1;
		end
end
endmodule
