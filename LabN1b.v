module labM;
reg [31:0] PCin;
reg clk, RegDst, RegWrite, ALUSrc, Mem2Reg, MemRead, MemWrite;
reg beq, j;
reg [1*8:0] ins_type;
reg [2:0] op;
wire [31:0] wd, rd1, rd2, imm, ins, PCp4, z, memOut, wb;
wire [25:0] jTarget;
wire zero;
reg INT;
reg [31:0]entryPoint;

yPC myPC(PCin, PCp4, INT, entryPoint, imm, jTarget, zero, branch, jump);
yIF myIF(ins, PCp4, PCin, clk);
yID myID(rd1, rd2, imm, jTarget, ins, wd, RegDst, RegWrite, clk);
yEX myEX(z, zero, rd1, rd2, imm, op, ALUSrc);
yDM myDM(memOut, z, rd2, clk, MemRead, MemWrite); 
yWB myWB(wb, z, memOut, Mem2Reg);

assign wd = wb; 

initial
begin
	// entry point
	// PCin = 'h80;
	// run program

	entryPoint = 128; INT = 1; #1;
	
	repeat (43)
	begin
		// fetch an ins
		//clk = 1; #1
		clk = 1; #1; INT = 0;
		// set control signals
		RegDst = 0; RegWrite = 0; ALUSrc = 1; MemRead = 0; MemWrite = 0; Mem2Reg = 0; op = 3'b010;
		beq = 0; j = 0;
		ins_type = "_";



		if (ins[31:26] == 6'h0)
		begin
			// R
			RegDst = 1; RegWrite = 1; ALUSrc = 0;
			MemRead = 0; MemWrite = 0; Mem2Reg = 0;
			ins_type = "R";

			if (ins[5:0] == 6'h25)
				op = 3'b001;
		end
		else if (ins[31:26] == 6'h2)
		begin
			// J
			RegDst = 0; RegWrite = 0; ALUSrc = 1;
			MemRead = 0; MemWrite = 0; Mem2Reg = 0;
			j = 1;
			ins_type = "J";
		end
		else
		begin
			// I
			ins_type = "I";
			if (ins[31:26] === 6'h23) // load word
			begin
				RegDst = 0; RegWrite = 1; ALUSrc = 1;
				MemRead = 1; MemWrite = 0; Mem2Reg = 1;
			end
			else if (ins[31:26] === 6'h2b) // store word
			begin
				RegDst = 0; RegWrite = 0; ALUSrc = 1;
				MemRead = 0; MemWrite = 1; Mem2Reg = 0;
			end
			else if (ins[31:26] === 6'h4) // beq
			begin
				RegDst = 0; RegWrite = 0; ALUSrc = 0;
				MemRead = 0; MemWrite = 0; Mem2Reg = 0;
				beq = 1;
			end
			else if (ins[31:26] === 6'h8) // addi
			begin
				RegDst = 0; RegWrite = 1; ALUSrc = 1;
				MemRead = 0; MemWrite = 0; Mem2Reg = 0;
			end
		end

		// execute the ins
		clk = 0; #1
		// view results
		$display("%h: rd1=%2d rd2=%2d z=%3d zero=%b wb=%2d\t%s\t%h", ins, rd1, rd2, z, zero, wb, ins_type, PCin);
		// prepare for the next instruction
		if (INT == 1)
			PCin = entryPoint;
		else if (beq && zero == 1)
			PCin = PCp4 + imm shifted left twice;
		else if (j)
			PCin = jTarget shifted left twice;
		else
			PCin = PCp4;
		
	end

	$finish;
end

endmodule
