
module bit_cpu(input clk,input clk2, input ready, output apb_write, output apb_addr, inout apb_data,output apb_device);

wire [7:0] addr;
wire [2:0] func;
wire [23:0] inst;
wire [7:0] imm;
wire [3:0] opcode;

wire br;
wire nia;                                  

wire [2:0] ra_addr;
wire [2:0] rb_addr;
wire [2:0] rd_addr;

wire [7:0] ra;
wire [7:0] rb;
wire [7:0] rd;
wire [7:0] rb_or_imm;

wire reg_dst;
wire reg_write;
wire alusrc;
wire [2:0] alufn;
wire [7:0] aluout;
wire mem_read;
wire mem_write;
wire mem_to_reg;
wire [7:0] mem_out;
wire continue_flag;
wire apb_op;

reg [7:0] pc_current; // was reg 
wire [2:0] rd_or_rb_addr;

 initial 
 begin
  pc_current <= 8'd0;
 end

imem imem(.addr(pc_current),.inst(inst));

decoder decoder(.inst(inst),
		.ra_addr(ra_addr),
		.rb_addr(rb_addr),
		.rd_addr(rd_addr),
		.imm(imm),
		.opcode(opcode),
		.func(func),
		.addr(addr),
		.apb_addr(apb_addr),
		.apb_data(apb_data),
		.apb_device(apb_device)
		);


control_unit  control(
		 .opcode(opcode),
		 .func(func),
		 .ready(ready),
		 .reg_dst(reg_dst),
		 .reg_write(reg_write),
		 .alusrc(alusrc),
		 .alufn(alufn),
		 .apb_op(apb_op),
		 .mem_write(mem_write),
		 .mem_read(mem_read),
		 .apb_write(apb_write),
		 .mem_to_reg(mem_to_reg),
		 .continue_flag(continue_flag),
		 .nia(nia)
		 );

mux2to1_3bit bitter(
			.rb_addr(rb_addr),
			.rd_addr(rd_addr),
			.sel(reg_dst),
			.final_addr(rd_or_rb_addr)
			);

regfile  regfile(
		.clk(clk),
		.reg1_read_addr(ra_addr),
		.reg1_read_data(ra),
		.reg2_read_addr(rb_addr),
		.reg2_read_data(rb),
		.reg_write_addr(rd_or_rb_addr),
	    .apb_op(apb_op),
		.reg_write_data(rd),
		.apb_data(apb_data),
		.reg_write_en(reg_write)
		);

mux2to1 mux2to1(
	    .Data_in_0(rb),
		.Data_in_1(imm),
		.sel(alusrc),
		.Data_out(rb_or_imm)
		);

alu  alu (
	.alufn(alufn),
	.ra(ra),
	.rb_or_imm(rb_or_imm),
	.apb_op(apb_op),
	.aluout(aluout),
	.br(br)
	);

datamem datamem(
		.read_addr(aluout),
		.write_addr(aluout),
		.write_data(rd),
		.mem_write(mem_write),
		.mem_read(mem_read),
		.read_data(mem_out)
		);

mux2to1 mux2to11(
		.Data_in_0(mem_out),
		.Data_in_1(aluout),
		.sel(mem_to_reg),
		.Data_out(rd)	
		);

always @(posedge clk2) 
begin
    if(continue_flag == 1'b1) begin
    //check flag
        #5
        if(nia == 1'b0)
            pc_current = pc_current + addr;
        else if (br == 1'b1)
            pc_current = pc_current + imm;
        else 
            pc_current = pc_current + 8'd1;
    end
end

always@(posedge clk2) 
begin
	$display ("inst=%b",inst);	
end

endmodule