module labM;
wire [31:0] PCin;
reg clk, RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite;
reg beq, j;
reg [1*8:0] ins_type;
reg [2:0] op;

reg INT;
reg [31:0]entryPoint;

wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
wire [25:0] jTarget;
wire zero;

yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);


initial
begin
	//------------------------------------Entry point
	entryPoint = 128; INT = 1; #1;
	//------------------------------------Run program
	//repeat (43)
	//begin
	//---------------------------------Fetch an ins
	clk = 1; #1; INT = 0;
	//---------------------------------Set control signals, as before but add branch and jump
		
		if (INT == 1)
			PCin = entryPoint;
		else if (beq && zero == 1)
			PCin = PCp4 + imm shifted left twice;
		else if (j)
			PCin = jTarget shifted left twice;
		else
			PCin = PCp4;
	//---------------------------------Execute the ins
	clk = 0; #1;
	//---------------------------------View results, as before
	//---------------------------------Prepare for the next ins, do nothing!
	end

		// view results
		$display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d\t%s\t%h", ins, rd1, rd2, z, zero, wb);
		// prepare for the next instruction


	


$finish;
end
	
		

endmodule
