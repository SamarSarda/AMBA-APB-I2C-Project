module imem ( 
			input [7:0] addr, 
			output [15:0] inst); 
// Addr is the address of instruction to fetch 
// for our purpose can be taken from ProgramCounter[7:0] 
reg [15:0] RAM [255:0]; 
initial $readmemb ("memfile.dat",RAM,0,2); 
assign inst = RAM[addr]; // word aligned 
endmodule