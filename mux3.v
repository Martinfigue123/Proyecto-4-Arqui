module mux3(e0, e1, s, out);
   input [7:0] e0, e1;
   input s;
   output [7:0] out;
   
   wire [7:0]   e0, e1;
   wire      s;
   reg [7:0]    out;
   
   always @(e0, e1, s) begin
     case(s)
		   'b0: out = e0; //Literal
		   'b1: out = e1; //Registro B
	   endcase
   end
endmodule