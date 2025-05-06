module bot(
	input logic clk,
	input logic counter,
	input logic [2:0] counter_0,
	input logic [2:0] counter_1,
	input logic [2:0] counter_2,
	input logic [2:0] counter_3,
	input	logic [2:0] counter_4,
	input logic [2:0] counter_5,
	input logic [2:0] counter_6,
	input logic [41:0] color_p0,
	input logic [41:0] color_p1,
	input logic invalid_detect,
	output logic [2:0] sel_col
);
	logic [3:0] k,l;
	
	always @ (posedge clk)
	begin
		if(counter_3 < 6 && counter!=2) sel_col <= 3; 
		if(counter==2 && color_p0[2]==0 && color_p1[2]==0) sel_col <= 2;
		else if(counter==2 && color_p0[4]==0 && color_p1[4]==0) sel_col <= 4; 	
	
		for (k=0; k<6; k = k +1)		// Checks horizontal 3 combinations
		begin
			for (l = 0; l< 5; l = l+1)
			begin
				if(color_p1[7*k+(l)]==0 && color_p0[7*k+(l)]==0 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1)  			// 0 X X Checks this configuration
				begin
					if (k == 0)			// If it is row 0 if that column first
						sel_col <= l;
					else if (color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1)			// Selects this only when the bottom is filled
						sel_col <= l;								
				end
				else if(color_p0[7*k+(l)]==1 && color_p1[7*k+(l+1)]==0 && color_p0[7*k+(l+1)]==0 && color_p0[7*k+(l+2)]==1) 	// X 0 X Checks this configuration
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l+1;						
					else if (color_p0[7*(k-1)+(l+1)]==1 || color_p1[7*(k-1)+(l+1)]==1)	// Selects this only when the bottom is filled
						sel_col <= l+1;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1 && color_p1[7*k+(l+2)]==0) 	// X X 0 Checks this configuration
				begin
					if (k == 0) 		// If it is row 0 if that column first			
						sel_col <= l+2;
					else if (color_p0[7*(k-1)+(l+2)]==1 || color_p1[7*(k-1)+(l+2)]==1)	// Selects this only when the bottom is filled
						sel_col <= l+2;
				end								
			end	
		end		
		
		for ( k = 0; k<4; k = k+1) 		// Check Vertical 3 combinations
		begin
			for (l = 0; l<7; l= l+1)																													//  0
			begin																																				//  X
				if(color_p0[7*(k)+l]==1 && color_p0[7*(k+1)+l]==1 && color_p1[7*(k+2)+l]==0 && color_p0[7*(k+2)+l]==0)		//  X Check this configuration	
					sel_col <= l;
			end
		end
						
		for(k=0; k<4; k=k+1)					// Check "/" 3 Combinations 
		begin
			for(l = 0; l<5; l= l+1)
			begin
				if(color_p1[7*(k)+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==1) 
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l;
					else if (color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1)	// Selects this only when the bottom is filled
						sel_col <= l;
				end
				if( color_p0[7*(k)+(l)]==1 && color_p0[7*(k+1)+(l+1)]==0 && color_p1[7*(k+1)+(l+1)]==0 && color_p0[7*(k+2)+(l+2)]==1) 
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l+1;
					else if (color_p0[7*(k)+(l+1)]==1 || color_p1[7*(k)+(l+1)]==1)	// Selects this only when the bottom is filled
						sel_col <= l+1;
				end
				if( color_p0[7*(k)+(l)]==1 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==0 && color_p1[7*(k+2)+(l+2)]==0) 
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l+2;
					else if (color_p0[7*(k+1)+(l+2)]==1 || color_p1[7*(k+1)+(l+2)]==1)	// Selects this only when the bottom is filled
						sel_col <= l+2;
				end	
			end
		end				
								
		for(k=0; k<4; k=k+1)					// Check "\" 3 Combinations 
		begin
			for(l = 2; l<7; l= l+1)
			begin
				if(color_p1[7*(k)+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==1) 
				begin
					if (k == 0) 		// If it is row 0 X X '\' Diagonally 
						sel_col <= l;						
					else if (color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1)	// Selects this only when the bottom is filled
						sel_col <= l;
				end
				if( color_p0[7*(k)+(l)]==1 && color_p0[7*(k+1)+(l-1)]==0 && color_p1[7*(k+1)+(l-1)]==0 && color_p0[7*(k+2)+(l-2)]==1) 
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l-1;						// X 0 X '\' Diagonally						
					else if (color_p0[7*(k)+(l-1)]==1 || color_p1[7*(k)+(l-1)]==1)	// Selects this only when the bottom is filled
						sel_col <= l-1;
				end
				if( color_p0[7*(k)+(l)]==1 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==0 && color_p1[7*(k+2)+(l-2)]==0) 
				begin
					if (k == 0) 		// If it is row 0 if that column first
						sel_col <= l-2;						// X X 0 '\' Diagonally
					else if (color_p0[7*(k+1)+(l-2)]==1 || color_p1[7*(k+1)+(l-2)]==1)	// Selects this only when the bottom is filled
						sel_col <= l-2;
				end		
			end			
		end
	
	
		// Check for Threats
		for(k=0; k<6; k=k+1) 		// Check Horizontal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*k+(l)]==0 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==1 && color_p1[7*k+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==0 && color_p0[7*k+(l+1)]==0 && color_p1[7*k+(l+2)]==1 && color_p1[7*k+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l+1;
					else if(color_p0[7*(k-1)+(l+1)]==1 || color_p1[7*(k-1)+(l+1)]==1) 
						sel_col <= l+1;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==0 && color_p0[7*k+(l+2)]==0 && color_p1[7*k+(l+3)]) 
				begin
					if(k==0) 
						sel_col <= l+2;
					else if(color_p0[7*(k-1)+(l+2)]==1 || color_p1[7*(k-1)+(l+2)]==1) 
						sel_col <= l+2;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==1  && color_p1[7*k+(l+3)]==0 && color_p0[7*k+(l+3)]==0)
				begin
					if(k==0) 
						sel_col <= l+3;
					else if(color_p0[7*(k-1)+(l+3)]==1 || color_p1[7*(k-1)+(l+3)]==1) 
						sel_col <= l+3;
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check Vertical
		begin //Row
			for(l=0; l<7; l=l+1) 
			begin //Column
			if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l)]==1 && color_p1[7*(k+2)+(l)]==1  && color_p1[7*(k+3)+(l)]==0 && color_p0[7*(k+3)+(l)]==0)
				sel_col <= l;
			end
		end	
	
		for(k=0; k<3; k=k+1) 		// Check "/" Diagonal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*(k)+(l)]==0 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==1 && color_p1[7*(k+3)+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==0 && color_p0[7*(k+1)+(l+1)]==0 && color_p1[7*(k+2)+(l+2)]==1 && color_p1[7*(k+3)+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l+1;
					else if(color_p0[7*(k)+(l+1)]==1 || color_p1[7*(k)+(l+1)]==1) 
						sel_col <= l+1;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==0 && color_p0[7*(k+2)+(l+2)]==0 && color_p1[7*(k+3)+(l+3)]) 
				begin
					if(k==0) 
						sel_col <= l+2;
					else if(color_p0[7*(k+1)+(l+2)]==1 || color_p1[7*(k+1)+(l+2)]==1) 
						sel_col <= l+2;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==1  && color_p1[7*(k+3)+(l+3)]==0 && color_p0[7*(k+3)+(l+3)]==0)
				begin
					if(k==0) 
						sel_col <= l+3;
					else if(color_p0[7*(k+2)+(l+3)]==1 || color_p1[7*(k+2)+(l+3)]==1) 
						sel_col <= l+3;
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check "\" Diagonal
		begin //Row
			for(l=3; l<7; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*(k)+(l)]==0 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==1 && color_p1[7*(k+3)+(l-3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==0 && color_p0[7*(k+1)+(l-1)]==0 && color_p1[7*(k+2)+(l-2)]==1 && color_p1[7*(k+3)+(l-3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l-1;
					else if(color_p0[7*(k)+(l-1)]==1 || color_p1[7*(k)+(l-1)]==1) 
						sel_col <= l-1;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==0 && color_p0[7*(k+2)+(l-2)]==0 && color_p1[7*(k+3)+(l-3)]) 
				begin
					if(k==0) 
						sel_col <= l-2;
					else if(color_p0[7*(k+1)+(l-2)]==1 || color_p1[7*(k+1)+(l-2)]==1) 
						sel_col <= l-2;
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==1  && color_p1[7*(k+3)+(l-3)]==0 && color_p0[7*(k+3)+(l-3)]==0)
				begin
					if(k==0) 
						sel_col <= l-3;
					else if(color_p0[7*(k+2)+(l-3)]==1 || color_p1[7*(k+2)+(l-3)]==1) 
						sel_col <= l-3;
				end
			end
		end	
		
		// Check for Winning Positions
		for(k=0; k<6; k=k+1) 		// Check Horizontal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*k+(l)]==0 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1 && color_p0[7*k+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==0 && color_p1[7*k+(l+1)]==0 && color_p0[7*k+(l+2)]==1 && color_p0[7*k+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l+1;
					else if(color_p1[7*(k-1)+(l+1)]==1 || color_p0[7*(k-1)+(l+1)]==1) 
						sel_col <= l+1;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==0 && color_p1[7*k+(l+2)]==0 && color_p0[7*k+(l+3)]) 
				begin
					if(k==0) 
						sel_col <= l+2;
					else if(color_p1[7*(k-1)+(l+2)]==1 || color_p0[7*(k-1)+(l+2)]==1) 
						sel_col <= l+2;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1  && color_p0[7*k+(l+3)]==0 && color_p1[7*k+(l+3)]==0)
				begin
					if(k==0) 
						sel_col <= l+3;
					else if(color_p1[7*(k-1)+(l+3)]==1 || color_p0[7*(k-1)+(l+3)]==1) 
						sel_col <= l+3;
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check Vertical
		begin //Row
			for(l=0; l<7; l=l+1) 
			begin //Column
			if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l)]==1 && color_p0[7*(k+2)+(l)]==1  && color_p0[7*(k+3)+(l)]==0 && color_p1[7*(k+3)+(l)]==0)
				sel_col <= l;
			end
		end	
	
		for(k=0; k<3; k=k+1) 		// Check "/" Diagonal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==1 && color_p0[7*(k+3)+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==0 && color_p1[7*(k+1)+(l+1)]==0 && color_p0[7*(k+2)+(l+2)]==1 && color_p0[7*(k+3)+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l+1;
					else if(color_p1[7*(k)+(l+1)]==1 || color_p0[7*(k)+(l+1)]==1) 
						sel_col <= l+1;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==0 && color_p1[7*(k+2)+(l+2)]==0 && color_p0[7*(k+3)+(l+3)]) 
				begin
					if(k==0) 
						sel_col <= l+2;
					else if(color_p1[7*(k+1)+(l+2)]==1 || color_p0[7*(k+1)+(l+2)]==1) 
						sel_col <= l+2;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==1  && color_p0[7*(k+3)+(l+3)]==0 && color_p1[7*(k+3)+(l+3)]==0)
				begin
					if(k==0) 
						sel_col <= l+3;
					else if(color_p1[7*(k+2)+(l+3)]==1 || color_p0[7*(k+2)+(l+3)]==1) 
						sel_col <= l+3;
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check "\" Diagonal
		begin //Row
			for(l=3; l<7; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==1 && color_p0[7*(k+3)+(l-3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) 
						sel_col <= l;
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) 
						sel_col <= l;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==0 && color_p1[7*(k+1)+(l-1)]==0 && color_p0[7*(k+2)+(l-2)]==1 && color_p0[7*(k+3)+(l-3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) 
						sel_col <= l-1;
					else if(color_p1[7*(k)+(l-1)]==1 || color_p0[7*(k)+(l-1)]==1) 
						sel_col <= l-1;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==0 && color_p1[7*(k+2)+(l-2)]==0 && color_p0[7*(k+3)+(l-3)]) 
				begin
					if(k==0) 
						sel_col <= l-2;
					else if(color_p1[7*(k+1)+(l-2)]==1 || color_p0[7*(k+1)+(l-2)]==1) 
						sel_col <= l-2;
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==1  && color_p0[7*(k+3)+(l-3)]==0 && color_p1[7*(k+3)+(l-3)]==0)
				begin
					if(k==0) 
						sel_col <= l-3;
					else if(color_p1[7*(k+2)+(l-3)]==1 || color_p0[7*(k+2)+(l-3)]==1) 
						sel_col <= l-3;
				end
			end
		end	
		
		// If Invalid is detected
		if(invalid_detect==1)
		begin
			if(counter_3 < 6) sel_col<=3;
			else if(counter_2<6) sel_col<=2;
			else if(counter_4<6) sel_col<=4;
			else if(counter_1<6) sel_col<=1;
			else if(counter_5<6) sel_col<=5;
			else if(counter_0<6) sel_col<=0;
			else if(counter_6<6) sel_col<=6;
		end
			
	end
					
endmodule

