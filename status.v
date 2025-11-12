module status(flags, clk, out);
   input clk;
   input [3:0] flags;
   output [3:0] out;

   wire         clk;
   wire [3:0]   flags;
   reg [3:0]    out;

   always@(posedge clk) begin
        out <= flags;
   end


endmodule