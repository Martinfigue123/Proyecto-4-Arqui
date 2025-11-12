module ctrlunit(opcode, status, sa, sb, la, lb, S, sd, Dw, lpc);
    input [6:0] opcode; // opcode 7 bits 
    input [3:0] status; // status 4 bits
    output la, lb, sd, Dw, lpc; // 1 bit // la y lb = Load Reg A y B, Sd = Mux data entrada S, Dw = Data memory entrada W, lpc = Load pc
    output [1:0] sb, sa; // 2 bits // sb y sa = entrada S de Mux A y B
    output [2:0] S; // 3 bits // Salida S ALU

    wire [6:0] opcode;
    wire [3:0] status; 
    reg la, lb, Dw, sd, lpc;
    reg [1:0] sa, sb;
    reg [2:0] S;

    always @(opcode) begin
      case (opcode[6:2]) // lee los ultimos 5 bites del opcode para determinar el tipo de operacion

        5'b00000: begin // MOV
        la = ~opcode[0]; // si el primer bit es 0, el load del registro A es 1 y viceversa
        lb = opcode[0]; // si el primer bit es 0, el load del registro B es 0 y viceversa
        S = 3'b000; // indica que es la operación SUMA al ALU (definido en ALU)
        sa = (opcode[1:0]==2'b01) ? 2'b00 : 2'b10; // b00 significa que MUX A deja pasar la señal de A, en otro caso pasa la señal 0
        case (opcode[1:0])
            2'b00: sb <= 2'b00; // <= PAra hcer la igualdad en el siguiente tick del clk
            2'b01: sb <= 2'b11; 
            2'b10: sb = 2'b10;
            2'b11: sb = 2'b10;
        endcase
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end MOV
        
        5'b00001: begin // ADD
        la = ~opcode[0]; 
        lb = opcode[0]; 
        S = 3'b000; 
        sa = (opcode[1:0]==2'b11) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b00 : 2'b10;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end ADD
        
        5'b00010: begin // SUB
        la = ~opcode[0]; 
        lb = opcode[0]; 
        S = 3'b001; 
        sa = (opcode[1:0]==2'b11) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b00 : 2'b10;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end SUB

        5'b00011: begin // AND
        la = ~opcode[0]; 
        lb = opcode[0]; 
        S = 3'b010; 
        sa = (opcode[1:0]==2'b11) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b00 : 2'b10;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end AND

        5'b00100: begin // OR
        la = ~opcode[0]; 
        lb = opcode[0]; 
        S = 3'b011; 
        sa = (opcode[1:0]==2'b11) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b00 : 2'b10;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end OR

        5'b00101: begin // NOT
        la = ~opcode[1]; 
        lb = opcode[1]; 
        S = 3'b100; 
        sa = (opcode[0]==0) ? 2'b00 : 2'b11;
        sb = 2'b00;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end NOT

        5'b00110: begin // XOR
        la = ~opcode[0]; 
        lb = opcode[0]; 
        S = 3'b101; 
        sa = (opcode[1:0]==2'b11) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b00 : 2'b10;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end XOR

        5'b00111: begin // SHL
        la = ~opcode[1]; // Ahora el load cambia
        lb = opcode[1]; 
        S = 3'b110; 
        sa = (opcode[0]==0) ? 2'b00 : 2'b11;
        sb = 2'b00;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end SHL  

        5'b01000: begin // SHR
        la = ~opcode[1]; 
        lb = opcode[1]; 
        S = 3'b111; 
        sa = (opcode[0]==0) ? 2'b00 : 2'b11;
        sb = 2'b00;
        sd = 0;
        Dw = 0;
        lpc = 0;
        end // end SHR

        5'b01001: begin // INC y 3 primeros MOV
            if (opcode[1:0]==2'b00) begin // INC
                la = 0; 
                lb = 1; 
                S = 3'b000; 
                sa = 2'b01;
                sb = 2'b00;
                sd = 0;
                Dw = 0;
                lpc = 0;
            end else if (opcode[1:0]==2'b11) begin // Mem[Lit]=A
                la = 0; 
                lb = 0; 
                S = 3'b000; 
                sa = 2'b00;
                sb = 2'b11;
                sd = 0; // Literal??
                Dw = 1;
                lpc = 0;
            end else begin
                la = opcode[0]; 
                lb = ~opcode[0]; 
                S = 3'b000; 
                sa = 2'b10;
                sb = 2'b01;
                sd = 0; // Literal??
                Dw = 0;
                lpc = 0;
        end // end if
        end // end INC y MOV

        5'b01010: begin // MOV continuación
        la = (opcode[1:0]==2'b01) ? 1 : 0; 
        lb = (opcode[1:0]==2'b10) ? 1 : 0;
        S = 3'b000; 
        sa = (opcode[1:0]==2'b11) ? 2'b00 : 2'b10;
        if (opcode[1:0]==2'b00) begin
            sb = 2'b00;
        end else if (opcode[1:0]==2'b11) begin
            sb = 2'b11;
        end else begin
            sb = 2'b01;
        end
        sd = (opcode[1:0]==2'b00) ? 0 : 1;
        Dw = (opcode[1]==opcode[0]) ? 1 : 0;
        lpc = 0; 
        end // end MOV continuación

        5'b01011: begin // ADD
        la = ~opcode[0]; 
        lb = (opcode[1:0]==2'b01) ? 1 : 0; 
        S = 3'b000; 
        sa = (opcode[1:0]==2'b01) ? 2'b11 : 2'b00; 
        sb = (opcode[1:0]==2'b11) ? 2'b00 : 2'b01; 
        sd = (opcode[1:0]==2'b10) ? 1'b1 : 1'b0; 
        Dw = (opcode[1:0]==2'b11) ? 1'b1 : 1'b0;
        lpc = 0;
        end // end ADD

        5'b01100: begin // SUB
        la = ~opcode[0]; 
        lb = (opcode[1:0]==2'b01) ? 1 : 0; // ok
        S = 3'b001; // ok 
        sa = (opcode[1:0]==2'b01) ? 2'b11 : 2'b00; // ok
        sb = (opcode[1:0]==2'b11) ? 2'b00 : 2'b01; // ok
        sd = (opcode[1:0]==2'b10) ? 1 : 0; // ok
        Dw = (opcode[1:0]==2'b11) ? 1 : 0; // ok
        lpc = 0; // ok
        end // end SUB

        5'b01101: begin // AND
        la = ~opcode[0]; 
        lb = (opcode[1:0]==2'b01) ? 1 : 0; 
        S = 3'b010; 
        sa = (opcode[1:0]==2'b01) ? 2'b11 : 2'b00; 
        sb = (opcode[1:0]==2'b11) ? 2'b00 : 2'b01; 
        sd = (opcode[1:0]==2'b10) ? 1 : 0; 
        Dw = (opcode[1:0]==2'b11) ? 1 : 0;
        lpc = 0; 
        end // end AND

        5'b01110: begin // OR
        la = ~opcode[0]; 
        lb = (opcode[1:0]==2'b01) ? 1 : 0; 
        S = 3'b011; 
        sa = (opcode[1:0]==2'b01) ? 2'b11 : 2'b00; 
        sb = (opcode[1:0]==2'b11) ? 2'b00 : 2'b01; 
        sd = (opcode[1:0]==2'b10) ? 1 : 0; 
        Dw = (opcode[1:0]==2'b11) ? 1 : 0;
        lpc = 0; 
        end // end OR

        5'b01111: begin // NOT Y 1ER XOR
        la = (opcode[1:0]==2'b11) ? 1 : 0; // OK 
        lb = 0; 
        S = (opcode[1:0]==2'b11) ? 3'b101 : 3'b100; // si es 2'b11 es XOR, sino NOT
        sa = (opcode[1:0]==2'b01) ? 2'b11 : 2'b00; 
        sb = (opcode[1:0]==2'b11) ? 2'b01 : 2'b00;  
        sd = (opcode[1:0]==2'b10) ? 1 : 0; // OK
        Dw = (opcode[1:0]==2'b11) ? 0 : 1; // OK
        lpc = 0; 
        end // end NOT Y 1ER XOR

        5'b10000: begin // XOR Y 1ER SHL
        la = (opcode[1:0]==2'b01) ? 1 : 0;
        lb = (opcode[1:0]==2'b00) ? 1 : 0; 
        S = (opcode[1:0]==2'b11) ? 3'b110 : 3'b101; // si es 2'b11 es SHL, sino XOR
        sa = (opcode[1:0]==2'b00) ? 2'b11 : 2'b00;
        sb = (opcode[1]==0) ? 2'b01 : 2'b00; 
        sd = (opcode[1:0]==2'b01) ? 1 : 0;
        Dw = opcode[1];
        lpc = 0; 
        end // end XOR Y SHL

        5'b10001: begin // SHL Y 2DO SHR
        la = 0;
        lb = 0; 
        S = (opcode[1]==0) ? 3'b110 : 3'b111; // si es 2'b11 es SHL, sino SHR
        sa = (opcode[1]==opcode[0]) ? 2'b11 : 2'b00; // OK
        sb = 2'b00; 
        sd = (opcode[1:0]==2'b01) ? 1 : 0; // OK
        Dw = 1;
        lpc = 0; 
        end // end SHL Y 2DO SHR

        5'b10010: begin // SHR INC Y 1ER RST
        la = 0; // OK
        lb = 0; // OK
        S = (opcode[1:0]==2'b00) ? 3'b111 : 3'b000; // SHR SINO SUMA
        if (opcode[1:0]==2'b00) begin
            sa = 2'b00;
            sb = 2'b00;
        end else if (opcode[1:0]==2'b11) begin
            sa = 2'b10;
            sb = 2'b11;
        end else begin
            sa = 2'b01;
            sb = 2'b01;
        end
        sd = ~opcode[0]; // ok
        Dw = 1; // OK
        lpc = 0; // OK
        end // end INC Y 1ER RST

        5'b10011: begin // RST Y 3ER CMP
        la = 0; 
        lb = 0; 
        S =  (opcode[1:0]==2'b00) ? 3'b000 : 3'b001;
        if (opcode[1:0]==2'b00) begin
            sa = 2'b10;
            sb = 2'b11;
        end else if (opcode[1:0]==2'b01) begin
            sa = 2'b00;
            sb = 2'b00;
        end else if (opcode[1:0]==2'b10) begin
            sa = 2'b00;
            sb = 2'b10;
        end else begin
            sa = 2'b11;
            sb = 2'b10;
        end
        sd = (opcode[1:0]==2'b00) ? 1 : 0; 
        Dw = (opcode[1:0]==2'b00) ? 1 : 0; 
        lpc = 0;
        end // end RST Y 3ER CMP

        5'b10100: begin // CMP JMP
        la = 0; 
        lb = 0; 
        S =  (opcode[1:0]==2'b11) ? 3'b000 : 3'b001;
        if (opcode[1:0]==2'b00) begin
            sa = 2'b00;
            sb = 2'b01;
        end else if (opcode[1:0]==2'b01) begin
            sa = 2'b11;
            sb = 2'b01;
        end else if (opcode[1:0]==2'b10) begin
            sa = 2'b00;
            sb = 2'b01;
        end else begin
            sa = 2'b00;
            sb = 2'b00;
        end
        sd = (opcode[1:0]==2'b10) ? 1 : 0; 
        Dw = 0; 
        lpc = (opcode[1:0]==2'b11) ? 1 : 0;
        end // end CMP JMP

        5'b10101: begin // JEQ JNE JGT JLT
        la = 0; 
        lb = 0; 
        S = 3'b000;
        sa = 0;
        sb = 0;
        sd = 0; 
        Dw = 0; 
        case(opcode[1:0])
            2'b00: lpc = status[3]; // JEQ PC = Lit (Z=1)
            2'b01: lpc = ~status[3]; // JNE PC = Lit (Z=0)
            2'b10: lpc = ~status[2] && ~status[3]; // JGT PC = Lit (N=0 y Z=0)
            2'b11: lpc = status[2]; // JLT PC = Lit (N=1)
        endcase
        end // end JEQ JNE JGT JLT

        5'b10110: begin // JGE JLE JCR JOV
        la = 0; 
        lb = 0; 
        S = 3'b000;
        sa = 0;
        sb = 0;
        sd = 0; 
        Dw = 0; 
        case(opcode[1:0])
            2'b00: lpc = ~status[2]; // JGE PC = Lit (N=0)
            2'b01: lpc = status[2] || status[3]; // JLE PC = Lit (N=1 o Z=1)
            2'b10: lpc = status[1]; // JCR PC = Lit (C=1)
            2'b11: lpc = status[0]; // JOV PC = Lit (V=1)
        endcase
        end // end JGE JLE JCR JOV

        default: begin
        la = 0; 
        lb = 0; 
        S = 3'b000;
        sa = 0;
        sb = 0;
        sd = 0; 
        Dw = 0;
        lpc = 0; 
        end

    endcase // end primeros 5 bits        
    end // end funcion always
endmodule