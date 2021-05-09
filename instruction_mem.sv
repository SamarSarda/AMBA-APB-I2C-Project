module imem ( 
			input [7:0] addr, 
			output [23:0] inst); 
// Addr is the address of instruction to fetch 
// for our purpose can be taken from ProgramCounter[7:0] 
logic [23:0] RAM [255:0]; 
initial $readmemb ("test_write_apb3.dat",RAM,0,5); 


assign inst = RAM[addr]; // word aligned 
endmodule