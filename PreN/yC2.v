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
