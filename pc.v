module pc(clk, pc, pcload, pcim);
   input clk;
   input pcload;
   input [7:0] pcim;
   output [7:0] pc;

   reg [7:0]     pc;
   wire          clk;
   wire [7:0] pcim;
   wire pcload ;

   initial begin
	   pc = 0;
   end

   always @(posedge clk) begin
      if(pcload) begin
         pc <= pcim;
      end else begin
	   pc <= pc + 1;
      end
   end
endmodule
