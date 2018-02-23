module yC3(ALUop, rtype, branch);
output [1:0] ALUop;
input rtype, branch;
 
assign ALUop[1] = rtype;
assign ALUop[0] = branch;
 
endmodule
