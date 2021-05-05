module decoder(
	input [23:0]inst,
	output logic [2:0] ra_addr,
	output logic [2:0] rb_addr,
	output logic [2:0] rd_addr,
	output logic [7:0] imm,
	output logic [3:0] opcode,
	output logic [2:0] func,
	output logic [7:0] addr,
	output logic [7:0] apb_addr,
	output logic [7:0] apb_data,
	output logic [3:0] apb_device
	);
always @(*) 
begin
  opcode[3:0]	= inst[23:20];
  rd_addr[2:0]	= inst[11:9];
  ra_addr[2:0]	= inst[8:6];
  rb_addr[2:0]	= inst[5:3];
  func[2:0]		= inst[2:0];
  imm[5:3]		= inst[11:9];
  imm[2:0]		= inst[2:0];
  addr[6:0]		= inst[6:0];
  apb_addr[7:0] = inst[19:12];
  apb_data[7:0] = inst[11:4];
  apb_device[3:0] = inst[3:0] ;
  imm[6]=imm[5];
  imm[7]=imm[5];
  addr[7]=addr[6];
end
endmodule