module datamemory(datain, clk, address, wren, out);
   input clk;
   input wren;
   input [7:0] datain, address;
   output [7:0] out;
   wire [7:0] out;
   
   reg [7:0]    mem [0:255];
   assign out = mem[address];
   always @(posedge clk) begin
	   if (wren) begin
		   mem[address] <= datain; // Cada vez que wren = 1, entonces se guarda datain en la memoria
       end 
   end
endmodule