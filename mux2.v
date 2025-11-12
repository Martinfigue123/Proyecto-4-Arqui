module mux2(e0, e1, e2, e3, s, out);
   input [7:0] e0, e1, e2, e3;
   input [1:0] s;
   output [7:0] out;
   
   wire [7:0]   e0, e1, e2, e3;
   wire [1:0]      s;
   reg [7:0]    out;
   
   always @(e0, e1, e2, e3, s) begin
     case(s)
		   2'b00: out = e0; //Registro B
		   2'b01: out = e1; //Data memory output
         2'b10: out = e2; //Literal
         2'b11: out = e3; //Cte 0
	   endcase
   end
endmodule