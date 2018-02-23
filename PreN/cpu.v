module yMux1(z, a, b, c);
output z;
input a, b, c;
wire notC, upper, lower;

not my_not(notC, c);
and upperAnd(upper, a, notC);
and lowerAnd(lower, c, b);
or my_or(z, upper, lower);

endmodule
module yMux(z, a, b, c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a, b;
input c;

// usage:
// yMux #(64) my_mux(z,a,b,c);
// or
// yMux #(.SIZE(64) my_mux(z,a,b,c);
// or
// defparam my_mux.SIZE = 64;
// yMux my_mux(z,a,b,c);

yMux1 mine[SIZE-1:0](z, a, b, c);

endmodule
module yMux4to1(z,a0,a1,a2,a3,c);
parameter SIZE = 2;
output [SIZE-1:0] z;
input [SIZE-1:0] a0, a1, a2, a3;
input [1:0] c;
wire [SIZE-1:0] zLo, zHi;

yMux #(SIZE) lo(zLo, a0, a1, c[0]);
yMux #(SIZE) hi(zHi, a2, a3, c[0]);
yMux #(SIZE) final(z, zLo, zHi, c[1]);

endmodule
module yAdder1(z, cout, a, b, cin);
output z, cout;
input a, b, cin;

xor left_xor (tmp, a, b);
xor right_xor (z, cin, tmp);
and left_and(outL, a, b);
and right_and(outR, tmp, cin);
or my_or(cout, outR, outL);

endmodule
module yAdder(z, cout, a, b, cin);
output [31:0] z;
output cout;
input [31:0] a, b;
input cin;
wire [31:0] in, out;

yAdder1 mine[31:0](z, out, a, b, in);

assign in[0] = cin;
assign in[31:1] = out[30:0];
assign cout = out[31];

endmodule
module yArith(z, cout, a, b, ctrl);
output [31:0] z;
output cout;
input [31:0] a, b;
input ctrl;
wire [31:0] notB, tmp;
wire cin;

yAdder mine(z, out, a, notB, cin);

assign cin = ctrl ? 1 : 0;
assign notB = ctrl ? ~b : b;

endmodule
module yAlu(z, ex, a, b, op);
input [31:0] a, b;
input [2:0] op;
output [31:0] z;
output ex;
wire [31:0] arith_z, and_z, or_z, slt_z;
wire [15:0] or16;
wire [7:0] or8;
wire [3:0] or4;
wire [1:0] or2;
wire cout;

//assign slt_z[31:1] = 0;
assign slt_z = (a[31] ^ b[31]) ? a[31] : arith_z[31];
and my_and[31:0] (and_z, a, b);
or my_or[31:0] (or_z, a, b);
//not my_nor[31:0] (nor_z, or_z, 32'b11111111111111111111111111111111);

or or_16[15:0]	(or16,	z[31:16],	z[15:0]);
or or_8[7:0]	(or8,	or16[15:8],	or16[7:0]);
or or_4[3:0]	(or4,	or8[7:4],	or8[3:0]);
or or_2[1:0]	(or2,	or4[3:2],	or4[1:0]);
nor nor_1		(ex,	or2[1],		or2[0]);

//assign ex = ~(|z);

yArith my_arith(arith_z, cout, a, b, op[2]);
yMux4to1 #(32) my_mux(z, and_z, or_z, arith_z, slt_z, op[1:0]);

endmodule

/*module yMux2(z, a, b, c);
output [1:0] z;
input [1:0] a, b;
input c;

yMux1 upper(z[0], a[0], b[0], c);
yMux1 lower(z[1], a[1], b[1], c);

endmodule*/

module yIF(ins, PCp4, PCin, clk);
output [31:0] ins, PCp4;
input [31:0] PCin;
input clk;
reg [31:0] memIn;
wire [31:0] mem_addr;

yAlu my_alu(PCp4, ex, mem_addr, 32'd4, 3'b010);
register #(32) my_reg(mem_addr, PCin, clk, 1'b1);
mem my_mem(ins, mem_addr, memIn, clk, 1'b1, 1'b0);

endmodule

module yID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
output [31:0] rd1, rd2, imm;
output [25:0] jTarget;
input [31:0] ins, wd;
input RegDst, RegWrite, clk;
wire [4:0] wn, rn1, rn2;

assign rn1 = ins[25:21];
assign rn2 = ins[20:16];
assign imm[15:0] = ins[15:0];
yMux #(16) se(imm[31:16], 16'b0000000000000000, 16'b1111111111111111, ins[15]);
assign jTarget = ins[25:0];

yMux #(5) my_mux(wn, rn2, ins[15:11], RegDst);

rf myRF(rd1, rd2, rn1, rn2, wn, wd, clk, RegWrite);

endmodule
module yEX(z, zero, rd1, rd2, imm, op, ALUSrc);
output [31:0] z;
output zero;
input [31:0] rd1, rd2, imm;
input [2:0] op;
input ALUSrc;
wire [31:0] b;

yMux #(32) my_mux(b, rd2, imm, ALUSrc);
yAlu my_alu(z, zero, rd1, b, op);

endmodule
// data memory
module yDM(memOut, exeOut, rd2, clk, MemRead, MemWrite);
output [31:0] memOut;
input [31:0] exeOut, rd2;
input clk, MemRead, MemWrite;

mem my_mem(memOut, exeOut, rd2, clk, MemRead, MemWrite);

endmodule
// write back
module yWB(wb, exeOut, memOut, Mem2Reg);
output [31:0] wb;
input [31:0] exeOut, memOut;
input Mem2Reg;

yMux #(32) my_mux (wb, exeOut, memOut, Mem2Reg);

endmodule
// program counter
module yPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);
output [31:0] PCin;
input [31:0] PCp4, entryPoint, imm;
input [25:0] jTarget;
input INT, zero, branch, jump;
wire [31:0] immX4, bTarget, choiceA, choiceB;
wire doBranch, zf;

assign immX4[31:2] = imm[29:0];
assign immX4[1:0] = 2'b00;

yAlu myALU(bTarget, zf, PCp4, immX4, 3'b010);
and (doBranch, branch, zero);
yMux #(32) mux1(choiceA, PCp4, bTarget, doBranch);

yMux #(32) mux2(choiceB, choiceA, {PCp4[31:28], jTarget, 2'b00}, jump);

yMux #(32) mux3(PCin, choiceB, entryPoint, INT);

endmodule
// control unit part 1
module yC1(rtype, lw, sw, jump, branch, opCode);
output rtype, lw, sw, jump, branch;
input [5:0] opCode;
wire [5:0] not_op;

not notty[5:0] (not_op[5:0], opCode[5:0]);

// lw 100011
and (lw, opCode[5], not_op[4], not_op[3], not_op[2], opCode[1], opCode[0]);

// sw 101011
and (sw, opCode[5], not_op[4], opCode[3], not_op[2], opCode[1], opCode[0]);

// beq 000100
and (branch, not_op[5], not_op[4], not_op[3], opCode[2], not_op[1], not_op[0]);

// j 000010
and (jump, not_op[5], not_op[4], not_op[3], not_op[2], opCode[1], not_op[0]);

// R instruction 000000
and (rtype, not_op[5], not_op[4], not_op[3], not_op[2], not_op[1], not_op[0]);

endmodule
// control unit part 2
module yC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch, jump);
output RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite;
input rtype, lw, sw, branch, jump;

assign RegDst = rtype;
nor (ALUSrc, rtype, branch);
nor (RegWrite, branch, sw, jump);
assign Mem2Reg = lw;
assign MemRead = lw;
assign MemWrite = sw;

endmodule
module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;
 
assign ALUop[1] = rtype;
assign ALUop[0] = branch;
 
endmodule
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
module yChip(ins, rd2, wb, entryPoint, INT, clk);
output [31:0] ins, rd2, wb;
input [31:0] entryPoint;
input INT, clk;

wire zero, RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite, branch, jump, rtype;
reg [1*8:0] ins_type;
wire [5:0] opCode, fnCode;
wire [2:0] op;
wire [31:0] wd, rd1, imm, ins, PCp4, z, memOut, PCin;
wire [25:0] jTarget;
wire [1:0] ALUop;

yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEX(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite); 
yWB myWB(wb, z, memOut, Mem2Reg);
assign wd = wb; 
yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);

assign opCode = ins[31:26];
yC1 myC1(rtype, lw, sw, jump, branch, opCode);
yC2 myC2(RegDst, ALUSrc, RegWrite, Mem2Reg, MemRead, MemWrite, rtype, lw, sw, branch, jump);
assign fnCode = ins[5:0];
yC3 myC3(ALUop, rtype, branch);
yC4 myC4(op, ALUop, fnCode);

endmodule
