module test;
reg[31:0] rd1, rd2, imm;
reg[2:0] op;
reg ALUSrc;
wire zero;
wire[31:0] z;

yEX testEX(z, zero, rd1, rd2, imm, op, ALUSrc);

initial
begin 
	rd1 = 32'd20;
	rd2 = 32'd21;
	imm = 32'd90;

	ALUSrc = 1'b1;
	op = 3'b010;
	
	$display("zero=%b, z=%b", zero, z);

end
endmodule 
	
