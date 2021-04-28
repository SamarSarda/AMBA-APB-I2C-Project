module alu(
	input [2:0] alufn,
	input [7:0] ra,
	input [7:0] rb_or_imm,
	output reg [7:0] aluout,
	output reg br);

parameter	ALU_OP_ADD	= 3'b000,
			ALU_OP_SUB	= 3'b001,
			ALU_OP_AND	= 3'b010,
			ALU_OP_OR	= 3'b011,
			ALU_OP_ADDI	= 3'b100,
			ALU_OP_LW	= 3'b101,
			ALU_OP_SW	= 3'b110,
			ALU_OP_BEQ	= 3'b111;

always @(*) 
begin
	case(alufn)
			ALU_OP_ADD 	: aluout = ra + rb_or_imm;
			ALU_OP_SUB 	: aluout = ra - rb_or_imm;
			ALU_OP_AND 	: aluout = ra & rb_or_imm;
			ALU_OP_OR	: aluout = ra | rb_or_imm;
			ALU_OP_ADDI	: aluout = ra + rb_or_imm;
			ALU_OP_LW	: aluout = ra + rb_or_imm;
			ALU_OP_SW	: aluout = ra + rb_or_imm;
			ALU_OP_BEQ	: begin
							br = (ra==rb_or_imm)?1'b1:1'b0; 
						  end
	endcase
end

endmodule