module labN;
reg clk, INT;
wire zero, RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite, branch, jump, rtype;
reg [31:0] entryPoint;
reg [1*8:0] ins_type;
wire [5:0] opCode, fnCode;
wire [2:0] op;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb, PCin;
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

initial
begin
	// entry point
	entryPoint = 32'h80; INT = 1; #1;

	// run program
	repeat (43)
	begin
		// fetch an ins
		clk = 1; #1; INT = 0;

		// set control signals
		ins_type = "_";

		if (ins[31:26] == 6'h0)
		begin
			// R
			ins_type = "R";
		end
		else if (ins[31:26] == 6'h2)
		begin
			// J
			ins_type = "J";
		end
		else
		begin
			// I
			ins_type = "I";
		end

		// execute the ins
		clk = 0; #1;

		// view results
		$display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d\t%s\t%h\t%b %b\t%b%b\t%h\t%b", ins, rd1, rd2, z, zero, wb, ins_type, PCin, ALUop, op, rtype, branch, fnCode, rtype);
	end

	$finish;
end

endmodule
