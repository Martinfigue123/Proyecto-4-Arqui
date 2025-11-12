module alu(a, b, s, out, ZNCV);
   input [7:0] a, b;
   input [2:0] s;
   output [7:0] out; 
   output [3:0] ZNCV; // Zero, Negative, Carry, Overflow flags

   wire [7:0]   a, b;
   wire [2:0]   s;
   reg [7:0]    out;
   reg [3:0]    ZNCV;

   always @(a, b, s) begin
	   case(s)
		   3'b000: out = a + b; // SUMA
		   3'b001: out = a - b; // RESTA
		   3'b010: out = a & b; // AND
		   3'b011: out = a | b; // OR
         3'b100: out = ~a; //NOT
         3'b101: out = a ^ b; //XOR
         3'b110: out = a << 1; //Shift left
         3'b111: out = a >> 1; //Shift right
	   endcase
      if ((s == 3'b000 && ((a[7] == b[7]) && (out[7] != a[7]))) || (s == 3'b001 && ((a[7] != b[7]) && (out[7] != a[7])))) begin
         ZNCV[0] = 1; // Overflow
      end else begin
         ZNCV[0] = 0;
      end

      if ((a+b<a && s==3'b000) || (a-b>b && s==3'b001)) begin
         ZNCV[1] = 1; // Carry
      end else begin
         ZNCV[1] = 0;
      end

      if ((a<b) && s==3'b001) begin
         ZNCV[2] = 1;
      end else begin
         ZNCV[2] = 0;
      end

      if ((out == 8'b00000000) && (!(a+b<a && s==3'b000) || (a-b>b && s==3'b001))) begin
         ZNCV[3] = 1; // Cero
      end else begin
         ZNCV[3] = 0;    
      end  


   end
endmodule
