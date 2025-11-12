module computer(clk, alu_out_bus);
   input clk;
   output [7:0] alu_out_bus;
   // Recominedo pasar todas estas señales para afuera para poder ser vistas en el waveform
   wire [7:0]   pc_out_bus;
   wire [14:0]  im_out_bus;
   wire [7:0]   regA_out_bus;
   wire [7:0]   regB_out_bus;
   wire [7:0]   muxB_out_bus;
   wire [7:0]   muxA_out_bus;
   wire         cu_loadA_out;
   wire         cu_loadB_out;
   wire         cu_pcload_out;
   wire [2:0]   cu_s_out;
   wire [1:0]   cu_sa_out;
   wire [1:0]   cu_sb_out;
   wire         cu_wren_out;
   wire [7:0]   datmem_out_bus;
   wire [7:0]   mux_data_out_bus;
   wire [3:0]   stat_out_bus;
   wire [3:0]   alu_flags_bus;


   //wire [3:0] alu_out_bus;

   pc PC(.clk(clk),
         .pc(pc_out_bus),
         .pcload(cu_pcload_out),
         .pcim(im_out_bus[7:0])); // Conexión para cargar el PC desde la IM
   instruction_memory IM(.address(pc_out_bus),
                         .out(im_out_bus));
   register regA(.clk(clk),
                 .data(alu_out_bus),
                 .load(cu_loadA_out),
                 .out(regA_out_bus));
   register regB(.clk(clk),
                 .data(alu_out_bus),
                 .load(cu_loadB_out),
                 .out(regB_out_bus));
   mux2 muxB(.e0(regB_out_bus), 
             .e1(datmem_out_bus),
//             .e1(8'b00000000),  //valor para primera entrega
             .e2(im_out_bus[7:0]),
             .e3(8'b00000000), // constante 0
             .s(cu_sb_out),
             .out(muxB_out_bus));
   mux1 muxA(.e0(regA_out_bus), 
             .e1(8'b00000001), // Constante 1
             .e2(8'b00000000), // Constante 0
             .e3(regB_out_bus),
             .s(cu_sa_out),
             .out(muxA_out_bus));
   alu ALU(.a(muxA_out_bus),
           .b(muxB_out_bus),
           .s(cu_s_out),
           .out(alu_out_bus),
           .ZNCV(alu_flags_bus));
   ctrlunit CU(.opcode(im_out_bus[14:8]),
           .status(stat_out_bus),
           .sa(cu_sa_out),
           .sb(cu_sb_out),
           .la(cu_loadA_out),
           .lb(cu_loadB_out),
           .S(cu_s_out),
           .sd(cu_sdata_out),
           .lpc(cu_pcload_out), //ARREGLAR
           .Dw(cu_wren_out));  //ARREGLAR
   mux3 muxdata(.e0(im_out_bus[7:0]),
           .e1(regB_out_bus),
           .s(cu_sdata_out),
           .out(mux_data_out_bus)); 
   status stat(.flags(alu_flags_bus),
           .clk(clk),
           .out(stat_out_bus)); 
   datamemory DM(.datain(alu_out_bus),
           .clk(clk),
           .address(mux_data_out_bus),
           .wren(cu_wren_out),
           .out(datmem_out_bus));   
             
endmodule
