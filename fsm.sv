module fsm(
	input  logic clk,
	input  logic rst,
	
	input logic [1:0] switch,
	
	input  logic left,
	input  logic right,
	input  logic put,

	output logic win_a,
	output logic win_b,
	output logic full_panel,

	output logic which_player,
	output logic invalid_detect,
	output logic [2:0] selected_col,		//Track selected column
	output logic [41:0] winner_tokens,
	output logic [41:0] color_p0,			//red
	output logic [41:0] color_p1,			//yellow	
	
   // new – one‑per‑video‑frame pulse from vga_controller
    input  logic frame_tick,
    // new – drives the overlay in vga_display
    output logic        anim_active,
    output logic [2:0]  anim_col,
    output logic [2:0]  anim_row,
    output logic        anim_player,
	 
	 output logic [1:0] game_mode,   // 00 = START, 01 = PLAY, 10 = END
	 output logic [1:0] victor       // 00 = none/tie, 01 = player‑A, 10 = player‑B
	 /*
    35 36 37 38 39 40 41
    28 29 30 31 32 33 34
    21 22 23 24 25 26 27
    14 15 16 17 18 19 20
    07 08 09 10 11 12 13
    00 01 02 03 04 05 06
    */
	
);

	logic [2:0] counter_0;
	logic [2:0] counter_1;
	logic [2:0] counter_2;
	logic [2:0] counter_3;
	logic [2:0] counter_4;
	logic [2:0] counter_5;
	logic [2:0] counter_6;
	logic [2:0] anim_target_row;
	logic [3:0] k,l;
	
	logic [1:0] game_mode_r, victor_r;
	assign game_mode = game_mode_r;
	assign victor     = victor_r;
		
	logic [41:0] tile0;			
	logic [41:0] tile1;	
	logic [2:0] sel_col;	
	logic [2:0] bot_col;	
	logic bot_0;
	logic bot_1;
	logic [10:0] counter = 1; 
	
	enum logic [3:0] { Start_Screen, Initial, Move_0, Move_1,Drop_Init, Animate, Check_move, Check_board, Next_move, End_Game, End_Screen, bot_move} state;	
	
//	bot bot_inst (
//		.clk(clk), 
//		.counter(counter),		
//		.counter_0(counter_0),
//		.counter_1(counter_1),
//		.counter_2(counter_2),
//		.counter_3(counter_3),
//		.counter_4(counter_4),
//		.counter_5(counter_5),
//		.counter_6(counter_6),
//		.color_p0(tile0),
//		.color_p1(tile1),
//		.invalid_detect(invalid_detect),
//		.sel_col(sel_col)
//	);
	
	//FSM logic
	always_ff @(posedge clk or negedge rst)
	begin
		if(!rst) 
		begin	
			state <= Start_Screen;  					//all squares are empty
			game_mode_r  <= 2'b00;  // START
			victor_r     <= 2'b00;
		end 
		else 
		begin	
			case(state)
				Start_Screen:
				begin
				game_mode_r <= 2'b00;         // START
				if (put) begin                // any button you like
					state       <= Initial;   // jump into normal game flow
					game_mode_r <= 2'b01;     // PLAY
					end
				end
				Initial:
				begin
					which_player <= 0;  			//which_player 0
					invalid_detect <= 0;
					win_a <= 0;
					win_b <= 0;
					selected_col <= 0; 			//Start from 0 column
					full_panel <=0;

					winner_tokens <= {42{1'b0}};	
					color_p0 <= {42{1'b0}};	
					color_p1 <= {42{1'b0}};		

					counter_0 <= 0;
					counter_1 <= 0;
					counter_2 <= 0;
					counter_3 <= 0;
					counter_4 <= 0;
					counter_5 <= 0;
					counter_6 <= 0;
					
					if (switch[0])
					begin
						if (switch[1])
							bot_1 <= 1;
						else
							bot_0 <= 1;
					end
					else
					begin
						bot_0 <= 0;
						bot_1 <= 0;	
					end
					
					bot_col<= 0;

					if (bot_0 == 1)
					begin
						counter <= 1;
						state <= bot_move;
					end
					tile0 <=0; tile1<=0;					
					
					state <= Move_0;
				end		  
				
				Drop_Init: 
				begin
					// ❶ Is the column already full?
					if ( (selected_col==0 && counter_0==6) ||
							(selected_col==1 && counter_1==6) ||
							(selected_col==2 && counter_2==6) ||
							(selected_col==3 && counter_3==6) ||
							(selected_col==4 && counter_4==6) ||
							(selected_col==5 && counter_5==6) ||
							(selected_col==6 && counter_6==6) ) begin
						invalid_detect <= 1;
						state          <= Next_move;          // behave exactly as before
					end
					else begin
						// ❷ Prepare the animation overlay
						anim_active  <= 1'b1;
						anim_player  <= which_player;
						anim_col     <= selected_col;
						anim_row     <= 3'd5;                 // start above the board
				
						// target row is the first empty slot (== current counter)
						unique case (selected_col)
								3'd0: anim_target_row <= counter_0[2:0];
								3'd1: anim_target_row <= counter_1[2:0];
								3'd2: anim_target_row <= counter_2[2:0];
								3'd3: anim_target_row <= counter_3[2:0];
								3'd4: anim_target_row <= counter_4[2:0];
								3'd5: anim_target_row <= counter_5[2:0];
								3'd6: anim_target_row <= counter_6[2:0];
						endcase
				
						state <= Animate;
					end
				end
				
				Animate: 
				begin
					if (frame_tick) begin
						if (anim_row == anim_target_row) begin
								// ❶ Landed – commit the chip exactly like old Check_move
								unique case (selected_col)
									3'd0: begin
										counter_0 <= counter_0 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_0))] <= 1;
										else                 color_p1[(selected_col + (7*counter_0))] <= 1;
									end
									3'd1: begin
										counter_1 <= counter_1 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_1))] <= 1;
										else                 color_p1[(selected_col + (7*counter_1))] <= 1;
									end
									3'd2: begin
										counter_2 <= counter_2 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_2))] <= 1;
										else                 color_p1[(selected_col + (7*counter_2))] <= 1;
									end
									3'd3: begin
										counter_3 <= counter_3 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_3))] <= 1;
										else                 color_p1[(selected_col + (7*counter_3))] <= 1;
									end
									3'd4: begin
										counter_4 <= counter_4 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_4))] <= 1;
										else                 color_p1[(selected_col + (7*counter_4))] <= 1;
									end
									3'd5: begin
										counter_5 <= counter_5 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_5))] <= 1;
										else                 color_p1[(selected_col + (7*counter_5))] <= 1;
									end
									3'd6: begin
										counter_6 <= counter_6 + 1;
										if (which_player==0) color_p0[(selected_col + (7*counter_6))] <= 1;
										else                 color_p1[(selected_col + (7*counter_6))] <= 1;
									end
								endcase
				
								anim_active <= 1'b0;          // overlay off
								state       <= Check_board;   // continue exactly like before
						end
						else begin
								anim_row <= anim_row - 3'd1;  // fall one row each frame
						end
					end
				end
				
				Move_0:
				begin			
					which_player <= 0;
					if(put)
					begin
						state <= Drop_Init;
						invalid_detect <= 0;
					end
					else
					begin
						if(left & !right & (selected_col > 0))
							selected_col <= selected_col - 1;
						else if(right & !left & (selected_col < 6))
							selected_col <= selected_col + 1;
						else if((right & selected_col==6))
							selected_col <= 0; 
						else if (left & selected_col==0)
							selected_col <= 6; 
					end	  
				end
				
				Move_1: begin
				which_player <= 1;
//				if (bot_en) begin
//					state <= bot_move;   // nothing – bot logic outside the case will act
//				end 
//				else begin
					if(put)
					begin
						state <= Drop_Init;
						invalid_detect <= 0;
					end
					else
					begin
						if(left & !right & (selected_col > 0))
							selected_col <= selected_col - 1;
						else if(right & !left & (selected_col < 6))
							selected_col <= selected_col + 1;
						else if((right & selected_col==6))
							selected_col <= 0;   
						else if (left & selected_col==0)
							selected_col <= 6; 
					end	
//					end
				end
				
				Check_move:
				begin
					if ((selected_col == 0 && counter_0 ==6) || 
						 (selected_col == 1 && counter_1 ==6) ||
						 (selected_col == 2 && counter_2 ==6) ||
						 (selected_col == 3 && counter_3 ==6) ||
						 (selected_col == 4 && counter_4 ==6) ||
						 (selected_col == 5 && counter_5 ==6) ||
						 (selected_col == 6 && counter_6 ==6))
						 invalid_detect <= 1;
					else if(selected_col==0 && counter_0 < 6)
					begin
						counter_0 <= counter_0 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_0))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_0))] <= 1;
					end
					else if(selected_col==1 && counter_1 < 6)
					begin
						counter_1 <= counter_1 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_1))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_1))] <= 1;
						end
					else if(selected_col==2 && counter_2 < 6)
						begin
						counter_2 <= counter_2 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_2))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_2))] <= 1;
						end
					else if(selected_col==3 && counter_3 < 6)
					begin
						counter_3 <= counter_3 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_3))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_3))] <= 1;
						end
					else if(selected_col==4 && counter_4 < 6)
					begin
						counter_4 <= counter_4 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_4))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_4))] <= 1;
					end
					else if(selected_col==5 && counter_5 < 6)
					begin
						counter_5 <= counter_5 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_5))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_5))] <= 1;
					end
					else if(selected_col==6 && counter_6 < 6)
					begin
						counter_6 <= counter_6 + 1;
						if(which_player==0)
							color_p0[(selected_col + (7*counter_6))] <= 1;
						else if(which_player==1)
							color_p1[(selected_col + (7*counter_6))] <= 1;
					end
					state <= Check_board;
				end
				
				Check_board:
					begin
					if(counter_0 == 6 && counter_1 == 6 && counter_2 == 6 && counter_3 == 6 && counter_4 == 6 && counter_5 == 6 && counter_6 == 6)
						full_panel <= 1;
					else
						full_panel <= 0;
					for(k=0; k<3; k=k+1) 
					begin 						//for rows
						for(l=0; l<7; l=l+1) 
						begin 					//for columns
							//Check Top 4 are the same color
							if(color_p0[(7*k)+l] && color_p0[(7*(k+1))+l] && color_p0[(7*(k+2))+l] && color_p0[(7*(k+3))+l])
							begin
								win_a <= 1;
								winner_tokens[(7*(k))+l] = 1;
								winner_tokens[(7*(k+1))+l] = 1;
								winner_tokens[(7*(k+2))+l] = 1;
								winner_tokens[(7*(k+3))+l] = 1;
							end
							if(color_p1[(7*k)+l] && color_p1[(7*(k+1))+l] && color_p1[(7*(k+2))+l] && color_p1[(7*(k+3))+l])
							begin
								win_b <= 1;
								winner_tokens[(7*(k))+l] = 1;
								winner_tokens[(7*(k+1))+l] = 1;
								winner_tokens[(7*(k+2))+l] = 1;
								winner_tokens[(7*(k+3))+l] = 1;
							end
						end
					end 
					for(k=0; k<6; k=k+1) 
					begin //for rows
						for(l=0; l<4; l=l+1) begin //for columns
							//Check Horizontal 4 are the same color
							if(color_p0[(7*k)+l] && color_p0[(7*k)+l+1] && color_p0[(7*k)+l+2] && color_p0[(7*k)+l+3])
							begin
								win_a <= 1;
								winner_tokens[(7*k)+l] = 1;
								winner_tokens[(7*k)+l+1] = 1;
								winner_tokens[(7*k)+l+2] = 1;
								winner_tokens[(7*k)+l+3] = 1;
							end
							if(color_p1[(7*k)+l] && color_p1[(7*k)+l+1] && color_p1[(7*k)+l+2] && color_p1[(7*k)+l+3])
							begin
								win_b <= 1;
								winner_tokens[(7*k)+l] = 1;
								winner_tokens[(7*k)+l+1] = 1;
								winner_tokens[(7*k)+l+2] = 1;
								winner_tokens[(7*k)+l+3] = 1;
							end
						end
					end
					for(k=0; k<3; k=k+1) 
					begin //for rows
						for(l=0; l<4; l=l+1) 
						begin //for columns
							// Check / diagonal
							if(color_p0[(7*k)+(l)] && color_p0[(7*(k+1))+(l+1)] && color_p0[(7*(k+2))+(l+2)] && color_p0[(7*(k+3))+(l+3)]) 
							begin
								win_a <= 1;
								winner_tokens[(7*(k))+(l)] = 1;
								winner_tokens[(7*(k+1))+(l+1)] = 1;
								winner_tokens[(7*(k+2))+(l+2)] = 1;
								winner_tokens[(7*(k+3))+(l+3)] = 1;
							end
							if(color_p1[(7*k)+(l)] && color_p1[(7*(k+1))+(l+1)] && color_p1[(7*(k+2))+(l+2)] && color_p1[(7*(k+3))+(l+3)]) 
							begin
								win_b <= 1;
								winner_tokens[(7*(k))+(l)] = 1;
								winner_tokens[(7*(k+1))+(l+1)] = 1;
								winner_tokens[(7*(k+2))+(l+2)] = 1;
								winner_tokens[(7*(k+3))+(l+3)] = 1;
							end
						end
					end
					for(k=0; k<3; k=k+1) 
					begin //for rows
						for(l=3; l<7; l=l+1) 
						begin //for columns
							// Check \ diagonal
							if(color_p0[(7*k)+(l)] && color_p0[(7*(k+1))+(l-1)] && color_p0[(7*(k+2))+(l-2)] && color_p0[(7*(k+3))+(l-3)])  
							begin
								win_a <= 1;
								winner_tokens[(7*(k))+(l)] = 1;
								winner_tokens[(7*(k+1))+(l-1)] = 1;
								winner_tokens[(7*(k+2))+(l-2)] = 1;
								winner_tokens[(7*(k+3))+(l-3)] = 1;
							end
							if(color_p1[(7*k)+(l)] && color_p1[(7*(k+1))+(l-1)] && color_p1[(7*(k+2))+(l-2)] && color_p1[(7*(k+3))+(l-3)])  
							begin
								win_b <= 1;
								winner_tokens[(7*(k))+(l)] = 1;
								winner_tokens[(7*(k+1))+(l-1)] = 1;
								winner_tokens[(7*(k+2))+(l-2)] = 1;
								winner_tokens[(7*(k+3))+(l-3)] = 1;
							end
						end
					end
					state <= Next_move;
				end
				
				Next_move:
				begin
					if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_1 == 0 && bot_0 == 0))			// Go to Player 2 from Player 1 (Bot Disabled)
						state <= Move_1;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_1 == 0 && bot_0 == 0))  	// Go to Player 1 from Player 2 (Bot Disabled)
						state <= Move_0;
					else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_1 == 0 && bot_0 == 0))  	// Invalid Move Go Back to Player 1 (Bot Disabled)
						state <= Move_0;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_1 == 0 && bot_0 == 0))		// Invalid Move Go Back to Player 2 (Bot Disabled)
						state <= Move_1;
						
					if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_0 == 1))			// Go to Player 2 from Player 1 (Bot 1 Enabled)
						state <= Move_1;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_0 == 1))  	// Go to Player 1 from Player 2 (Bot 1 Enabled)
						state <= bot_move;
					else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_0 == 1))  	// Invalid Move Go Back to Player 1 (Bot 1 Enabled)
						state <= bot_move;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_0 == 1))	// Invalid Move Go Back to Player 2 (Bot 1 Enabled)
						state <= Move_1;						
						
					if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_1 == 1))			// Go to Player 2 from Player 1 (Bot 2 Enabled)
						state <= bot_move;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==0 && (bot_1 == 1))  	// Go to Player 1 from Player 2 (Bot 2 Enabled)
						state <= Move_0;
					else if(which_player==0 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_1 == 1))  	// Invalid Move Go Back to Player 1 (Bot 2 Enabled)
						state <= Move_0;
					else if(which_player==1 && win_a==0 && win_b==0 && full_panel==0 && invalid_detect==1 && (bot_1 == 1))	// Invalid Move Go Back to Player 2 (Bot 2 Enabled)
						state <= bot_move;	
						

				end
				
				bot_move:
				begin		
					if (put)
					begin
						if (bot_0==1 )
							which_player <= 0;
						else
							which_player <= 1;	
						state <= Check_move;	
						invalid_detect <= 0;
					end
					
					else
					
					//////////////////////////
	begin
		if(color_p1[3]==0 && color_p0[3]==0) begin
			selected_col <= 3; state <= Check_move; end
		else if(color_p1[4]==0 && color_p0[4]==0) begin
			selected_col <= 4;  state <= Check_move; end	
		else if(color_p1[2]==0 && color_p0[2]==0) begin
			selected_col <= 2; state <= Check_move; end
			
//		else if(counter_3 < 6) begin 
//			selected_col <= 3; //state <= Check_move; end
//		end
			
		// Check for Winning Positions
		for(k=0; k<6; k=k+1) 		// Check Horizontal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*k+(l)]==0 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==1 && color_p1[7*k+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) begin
						selected_col <= l; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==0 && color_p0[7*k+(l+1)]==0 && color_p1[7*k+(l+2)]==1 && color_p1[7*k+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l+1;  state <= Check_move; end
					else if(color_p0[7*(k-1)+(l+1)]==1 || color_p1[7*(k-1)+(l+1)]==1) begin
						selected_col <= l+1;  state <= Check_move; end
				end 
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==0 && color_p0[7*k+(l+2)]==0 && color_p1[7*k+(l+3)]) 
				begin
					if(k==0) begin
						selected_col <= l+2;  state <= Check_move; end
					else if(color_p0[7*(k-1)+(l+2)]==1 || color_p1[7*(k-1)+(l+2)]==1) begin
						selected_col <= l+2;  state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*k+(l+1)]==1 && color_p1[7*k+(l+2)]==1  && color_p1[7*k+(l+3)]==0 && color_p0[7*k+(l+3)]==0)
				begin
					if(k==0) begin
						selected_col <= l+3;  state <= Check_move; end
					else if(color_p0[7*(k-1)+(l+3)]==1 || color_p1[7*(k-1)+(l+3)]==1) begin
						selected_col <= l+3;  state <= Check_move; end
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check Vertical
		begin //Row
			for(l=0; l<7; l=l+1) 
			begin //Column
			if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l)]==1 && color_p1[7*(k+2)+(l)]==1  && color_p1[7*(k+3)+(l)]==0 && color_p0[7*(k+3)+(l)]==0)
			begin	selected_col <= l; state <= Check_move; end
			end
		end	
	
		for(k=0; k<3; k=k+1) 		// Check "/" Diagonal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*(k)+(l)]==0 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==1 && color_p1[7*(k+3)+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) begin
						selected_col <= l; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==0 && color_p0[7*(k+1)+(l+1)]==0 && color_p1[7*(k+2)+(l+2)]==1 && color_p1[7*(k+3)+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l+1; state <= Check_move; end
					else if(color_p0[7*(k)+(l+1)]==1 || color_p1[7*(k)+(l+1)]==1) begin
						selected_col <= l+1; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==0 && color_p0[7*(k+2)+(l+2)]==0 && color_p1[7*(k+3)+(l+3)]) 
				begin
					if(k==0) begin
						selected_col <= l+2; state <= Check_move; end
					else if(color_p0[7*(k+1)+(l+2)]==1 || color_p1[7*(k+1)+(l+2)]==1) begin
						selected_col <= l+2; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l+1)]==1 && color_p1[7*(k+2)+(l+2)]==1  && color_p1[7*(k+3)+(l+3)]==0 && color_p0[7*(k+3)+(l+3)]==0)
				begin
					if(k==0) begin
						selected_col <= l+3; state <= Check_move; end
					else if(color_p0[7*(k+2)+(l+3)]==1 || color_p1[7*(k+2)+(l+3)]==1) begin
						selected_col <= l+3; state <= Check_move; end
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check "\" Diagonal
		begin //Row
			for(l=3; l<7; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==0 && color_p1[7*(k)+(l)]==0 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==1 && color_p1[7*(k+3)+(l-3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p0[7*(k-1)+(l)]==1 || color_p1[7*(k-1)+(l)]==1) begin
						selected_col <= l; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==0 && color_p0[7*(k+1)+(l-1)]==0 && color_p1[7*(k+2)+(l-2)]==1 && color_p1[7*(k+3)+(l-3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l-1; state <= Check_move; end
					else if(color_p0[7*(k)+(l-1)]==1 || color_p1[7*(k)+(l-1)]==1) begin
						selected_col <= l-1; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==0 && color_p0[7*(k+2)+(l-2)]==0 && color_p1[7*(k+3)+(l-3)]) 
				begin
					if(k==0) begin
						selected_col <= l-2; state <= Check_move; end
					else if(color_p0[7*(k+1)+(l-2)]==1 || color_p1[7*(k+1)+(l-2)]==1) begin
						selected_col <= l-2; state <= Check_move; end
				end
				else if(color_p1[7*k+(l)]==1 && color_p1[7*(k+1)+(l-1)]==1 && color_p1[7*(k+2)+(l-2)]==1  && color_p1[7*(k+3)+(l-3)]==0 && color_p0[7*(k+3)+(l-3)]==0)
				begin
					if(k==0) begin
						selected_col <= l-3; state <= Check_move; end
					else if(color_p0[7*(k+2)+(l-3)]==1 || color_p1[7*(k+2)+(l-3)]==1) begin
						selected_col <= l-3; state <= Check_move; end 
				end
			end
		end	

////////////////////////////////////////////////////////////////////////////////	
		// Check for Threats
		for(k=0; k<6; k=k+1) 		// Check Horizontal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*k+(l)]==0 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1 && color_p0[7*k+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) begin
						selected_col <= l;  state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==0 && color_p1[7*k+(l+1)]==0 && color_p0[7*k+(l+2)]==1 && color_p0[7*k+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l+1; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l+1)]==1 || color_p0[7*(k-1)+(l+1)]==1) begin
						selected_col <= l+1; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==0 && color_p1[7*k+(l+2)]==0 && color_p0[7*k+(l+3)]) 
				begin
					if(k==0) begin
						selected_col <= l+2; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l+2)]==1 || color_p0[7*(k-1)+(l+2)]==1) begin
						selected_col <= l+2; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*k+(l+1)]==1 && color_p0[7*k+(l+2)]==1  && color_p0[7*k+(l+3)]==0 && color_p1[7*k+(l+3)]==0)
				begin
					if(k==0) begin
						selected_col <= l+3; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l+3)]==1 || color_p0[7*(k-1)+(l+3)]==1) begin
						selected_col <= l+3; state <= Check_move; end
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check Vertical
		begin //Row
			for(l=0; l<7; l=l+1) 
			begin //Column
				if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l)]==1 && color_p0[7*(k+2)+(l)]==1  && color_p0[7*(k+3)+(l)]==0 && color_p1[7*(k+3)+(l)]==0)
				begin
					selected_col <= l;
					state <= Check_move; 
				end
			end
		end	
	
		for(k=0; k<3; k=k+1) 		// Check "/" Diagonal
		begin //Row
			for(l=0; l<4; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==1 && color_p0[7*(k+3)+(l+3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) begin
						selected_col <= l; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==0 && color_p1[7*(k+1)+(l+1)]==0 && color_p0[7*(k+2)+(l+2)]==1 && color_p0[7*(k+3)+(l+3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l+1; state <= Check_move; end
					else if(color_p1[7*(k)+(l+1)]==1 || color_p0[7*(k)+(l+1)]==1) begin
						selected_col <= l+1; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==0 && color_p1[7*(k+2)+(l+2)]==0 && color_p0[7*(k+3)+(l+3)]) 
				begin
					if(k==0) begin
						selected_col <= l+2; state <= Check_move; end
					else if(color_p1[7*(k+1)+(l+2)]==1 || color_p0[7*(k+1)+(l+2)]==1) begin
						selected_col <= l+2; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l+1)]==1 && color_p0[7*(k+2)+(l+2)]==1  && color_p0[7*(k+3)+(l+3)]==0 && color_p1[7*(k+3)+(l+3)]==0)
				begin
					if(k==0) begin
						selected_col <= l+3; state <= Check_move; end
					else if(color_p1[7*(k+2)+(l+3)]==1 || color_p0[7*(k+2)+(l+3)]==1) begin
						selected_col <= l+3; state <= Check_move; end
				end
			end
		end	
		
		for(k=0; k<3; k=k+1) 		// Check "\" Diagonal
		begin //Row
			for(l=3; l<7; l=l+1) 
			begin //Column
				if(color_p1[7*k+(l)]==0 && color_p0[7*(k)+(l)]==0 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==1 && color_p0[7*(k+3)+(l-3)]==1) 	// 0 X X X Configuration
				begin
					if(k==0) begin
						selected_col <= l; state <= Check_move; end
					else if(color_p1[7*(k-1)+(l)]==1 || color_p0[7*(k-1)+(l)]==1) begin
						selected_col <= l; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==0 && color_p1[7*(k+1)+(l-1)]==0 && color_p0[7*(k+2)+(l-2)]==1 && color_p0[7*(k+3)+(l-3)]==1) // X 0 X X Configuraion
				begin
					if(k==0) begin
						selected_col <= l-1; state <= Check_move; end
					else if(color_p1[7*(k)+(l-1)]==1 || color_p0[7*(k)+(l-1)]==1) begin
						selected_col <= l-1; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==0 && color_p1[7*(k+2)+(l-2)]==0 && color_p0[7*(k+3)+(l-3)]) 
				begin
					if(k==0) begin
						selected_col <= l-2; state <= Check_move; end
					else if(color_p1[7*(k+1)+(l-2)]==1 || color_p0[7*(k+1)+(l-2)]==1) begin
						selected_col <= l-2; state <= Check_move; end
				end
				else if(color_p0[7*k+(l)]==1 && color_p0[7*(k+1)+(l-1)]==1 && color_p0[7*(k+2)+(l-2)]==1  && color_p0[7*(k+3)+(l-3)]==0 && color_p1[7*(k+3)+(l-3)]==0)
				begin
					if(k==0) begin
						selected_col <= l-3; state <= Check_move; end
					else if(color_p1[7*(k+2)+(l-3)]==1 || color_p0[7*(k+2)+(l-3)]==1) begin
						selected_col <= l-3; state <= Check_move; end
				end
			end
		end
		
		if(counter_3 < 6) begin 
			selected_col <= 3; state <= Check_move; end

		
		// If Invalid is detected
		if(invalid_detect==1)
		begin
			if(counter_3 < 6) selected_col<=3;
			else if(counter_2<6) selected_col<=2;
			else if(counter_4<6) selected_col<=4;
			else if(counter_1<6) selected_col<=1;
			else if(counter_5<6) selected_col<=5;
			else if(counter_0<6) selected_col<=0;
			else if(counter_6<6) selected_col<=6;
		end
			
	end
					//////////////////////////
					
					if (bot_0==1) 
						which_player <= 0;
					else 
						which_player <= 1;
end	
				
			endcase
		end
	end
endmodule