module color_decider (
	input logic [10:0] row,
	input logic [10:0] col,	
	input logic [41:0] winner_tokens,
	input logic [41:0] color_p0,
	input logic [41:0] color_p1,
	output logic [1:0] color
	);
	
	int r;
	int c;

	always_comb
	begin
		r = row;
		c = col;
		if (winner_tokens[r*7 + c] == 1) 
			color = 2'b11;
		else if (color_p0[r*7 + c] == 1)
			color = 2'b01;
		else if (color_p1[r*7 + c] == 1)
			color = 2'b10;
		else
			color = 2'b00;
	end
endmodule