module labN;
reg [31:0] entryPoint;
reg clk, INT;
wire [31:0] ins, rd2, wb;
 
yChip myChip(ins, rd2, wb, entryPoint, INT, clk);

initial
begin
	// entry point
	entryPoint = 32'h80; INT = 1; #1;

	// run program
	repeat (43)
	begin
		// fetch an ins
		clk = 1; #1; INT = 0;

		// execute the ins
		clk = 0; #1;

		// view results
		$display("%h: rd2=%2d wb=%2d", ins, rd2, wb);
	end

	$finish;
end

endmodule
