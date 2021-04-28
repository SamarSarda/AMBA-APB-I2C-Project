module decoder(
	input [15:0]inst,
	output reg [2:0] ra_addr,
	output reg [2:0] rb_addr,
	output reg [2:0] rd_addr,
	output reg [7:0] imm,
	output reg [3:0] opcode,
	output reg [2:0] func,
	output reg [7:0] addr
	);
always @(*) 
begin
  opcode[3:0]	= inst[15:12];
  rd_addr[2:0]	= inst[11:9];
  ra_addr[2:0]	= inst[8:6];
  rb_addr[2:0]	= inst[5:3];
  func[2:0]		= inst[2:0];
  imm[5:3]		= inst[11:9];
  imm[2:0]		= inst[2:0];
  addr[6:0]		= inst[6:0];
  imm[6]=imm[5];
  imm[7]=imm[5];
  addr[7]=addr[6];
end
endmodule