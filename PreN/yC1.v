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
