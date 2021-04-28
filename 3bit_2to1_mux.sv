module mux2to1_3bit (
    input [2:0] rd_addr,
    input [2:0] rb_addr,
    input sel,
    output [2:0] final_addr
    ); 
    reg [2:0] final_addr;

    always @(rd_addr,rb_addr,final_addr)
    begin
        if(sel == 0) 
            final_addr = rb_addr; 
        else
            final_addr = rd_addr;
    end
    
endmodule