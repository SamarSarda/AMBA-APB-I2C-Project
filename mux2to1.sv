module mux2to1 (
    input [7:0] Data_in_0,
    input [7:0] Data_in_1,
    input sel,
    output [7:0] Data_out
    ); 
    reg [7:0] Data_out;

    always @(Data_in_0,Data_in_1,sel)
    begin
        if(sel == 0) 
            Data_out = Data_in_0; 
        else
            Data_out = Data_in_1;
    end
    
endmodule