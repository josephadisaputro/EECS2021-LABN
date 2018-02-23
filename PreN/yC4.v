// ALU control unit
module yC4(op, ALUop, fnCode);
output [2:0] op;
input [5:0] fnCode;
input [1:0] ALUop;
wire f1_and_aluop1, f3_or_f0;
 
or (f3_or_f0, fnCode[3], fnCode[0]);
and (f1_and_aluop1, fnCode[1], ALUop[1]);
and (op[0], f3_or_f0, ALUop[1]);
nand (op[1], fnCode[2], ALUop[1]);
or (op[2], f1_and_aluop1, ALUop[0]);

endmodule
