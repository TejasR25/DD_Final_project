module vga_display(
    //-------------------------------------------------------------
    // clocks / counters
    //-------------------------------------------------------------
    input  logic        vga_clock,
    input  logic [9:0]  hcount,
    input  logic [9:0]  vcount,
    input  logic        frame_tick,

    //-------------------------------------------------------------
    // NEW  –  falling‑chip overlay from the FSM
    //-------------------------------------------------------------
    input  logic        anim_active,
    input  logic [2:0]  anim_col,
    input  logic [2:0]  anim_row,
    input  logic        anim_player,   // 0 = red , 1 = yellow

    //-------------------------------------------------------------
    // RGB pixel outputs
    //-------------------------------------------------------------
    output logic [7:0]  red,
    output logic [7:0]  green,
    output logic [7:0]  blue,

    //-------------------------------------------------------------
    // game‑state inputs (unchanged)
    //-------------------------------------------------------------
    input  logic [41:0] winner_tokens,
    input  logic [2:0]  selected_col,
    input  logic [41:0] color_p0,
    input  logic [41:0] color_p1,
    input  logic        which_player,
    input  logic        invalid_detect,
    input  logic        win_a,
    input  logic        win_b,
    input  logic        panel,
	 
	 //Start and End screen
	 input  logic [1:0] game_mode,   // 00 START, 01 PLAY, 10 END
	 input  logic [1:0] victor
);

    //-------------------------------------------------------------
    // internal signals
    //-------------------------------------------------------------
    logic [10:0] row;
    logic [10:0] col;

    logic [13:0] addr;
	 logic [15:0] addr_start;
	 logic [13:0] addr_player;
	 logic [13:0] addr_result;
    logic [23:0] q;
	 logic [23:0] q_start;
	 logic [23:0] q_player;
	 logic [23:0] q_won;

    logic [1:0]  color;          // from color_decider (00‑empty, 01‑red, 10‑yellow, 11‑win)
    logic [1:0]  pixel_color;    // *** final colour after overlay selection ***
    logic        is_anim_cell;

    int local_h;
    int local_v;
    int circle_center_x;
    int circle_center_y;
    int radius;
    int dx, dy;
    int col_start;
    int col_end;

    //-------------------------------------------------------------
    // helper blocks
    //-------------------------------------------------------------
    color_decider coldec (
        .row            (row),
        .col            (col),
        .winner_tokens  (winner_tokens),
        .color_p0       (color_p0),
        .color_p1       (color_p1),
        .color          (color)
    );

    rom rom_connect (
        .address(addr),
        .clock  (vga_clock),
        .q      (q)
    );
	 
	 start_rom start_Screen(
			.address(addr_start),
			.clock(vga_clock),
			.q(q_start));
			
	player_select (
	.address(addr_player),
	.clock(vga_clock),
	.q(q_player));
	
	won_draw result(
	.address(addr_result),
	.clock(vga_clock),
	.q(q_won));
	
	logic [7:0] cnt;
	logic blink;
	
	always@(posedge frame_tick)
	begin
	cnt <= cnt + 1'b1;
	if(cnt == 8'h07)
	begin
		blink <= ~blink;
		cnt <= 8'h0;
	end
	end
    //-------------------------------------------------------------
    // main combinational pixel generator
    //-------------------------------------------------------------
    always_comb begin
        //---------------------------------------------------------
        // defaults
        //---------------------------------------------------------
        red   = 8'd0;
        green = 8'd0;
        blue  = 8'd0;
		  pixel_color   = 2'b00;  // <‑‑ added
		  is_anim_cell  = 1'b0;   // <‑‑ added
		  addr_start = 16'd0;
		  addr          = 14'd0;
		  addr_player = 13'd0;
		  addr_result = 13'd0;
        //---------------------------------------------------------
        // constant geometry parameters
        //---------------------------------------------------------
        circle_center_x = 70/2;
        circle_center_y = 70/2;
        radius          = 70/2 - 8;

        //---------------------------------------------------------
        // derive board row/column indices and local co‑ords
        //---------------------------------------------------------
        dx = 0; dy = 0; local_h = 0; local_v = 0; row = 0; col = 0;
        col_start = 0; col_end = 0;
		  
		  if (game_mode == 2'b00) begin  // START
        red   = 8'h00;  green = 8'h00;  blue = 8'h00;   // Black background
        // you can draw a logo or text with the existing rom_connect here
		  if (hcount >= 64 && hcount < 576 && vcount >= 176 && vcount < 304) begin
            local_h = (hcount - 64);
            local_v = (vcount - 176);
            addr_start    = (512*local_v) + local_h;
            red   = q_start[23:16];
				green = q_start[15:8];
				blue  = q_start[7:0];
				
        end else begin
            addr_start = 16'd0;
        end
		  end
		  /*else if (game_mode == 2'b10) begin
		  unique case (victor) 
            2'b01: begin red=8'hFF; green=8'h00; blue=8'h00; // red wins
				if (hcount >= 64 && hcount < 576 && vcount >= 176 && vcount < 304) begin
            local_h = (hcount - 64);
            local_v = (vcount - 176);
            addr_start    = (512*local_v) + local_h;
            red   = q_start[23:16];  // Zero-extend to 8 bits
				green = q_start[15:8];
				blue  = q_start[7:0];
        end else begin
            addr_start = 16'd0;
        end
		  end   
            2'b10: begin red=8'hFF; green=8'hFF; blue=8'h00; // yellow wins
				if (hcount >= 64 && hcount < 576 && vcount >= 176 && vcount < 304) begin
            local_h = (hcount - 64);
            local_v = (vcount - 176);
            addr_start    = (512*local_v) + local_h;
            red   = q_start[23:16]; // Zero-extend to 8 bits
				green = q_start[15:8];
				blue  = q_start[7:0];
        end else begin
            addr_start = 16'd0;
        end
		  end
            default: begin red=8'hFF; green=8'hFF; blue=8'hFF; end // tie
        endcase
        addr_start = 16'd0;
        end*/
		  else if (game_mode == 2'b01) begin
        //---------------------------------------------------------
        // **** Border (black) ****
        //---------------------------------------------------------
        if (hcount < 10 || hcount > (20 + 7*70 + 10) ||
            vcount < 10 || vcount > (20 + 6*70 + 20)) begin
            red   = 8'd0; green = 8'd0; blue = 8'd0;
        end

        //---------------------------------------------------------
        // **** Grid cells area ****
        //---------------------------------------------------------
        else if (hcount > 10 && hcount < (10 + 7*70) &&
                 vcount > 30 && vcount < (20 + 6*70 + 10)) begin

            // map pixel to cell
            col      = (hcount - 10) / 70;
            row      = 5 - ((vcount - 30) / 70);   // bottom row = 0
            local_h  = (hcount - 10)  % 70;
            local_v  = (vcount - 30)  % 70;

            //-----------------------------------------------------
            // circle distance test
            //-----------------------------------------------------
            dx = local_h - circle_center_x;
            dy = local_v - circle_center_y;

            //-----------------------------------------------------
            // choose colour for THIS cell (with overlay override)
            //-----------------------------------------------------
            is_anim_cell = anim_active && (row == anim_row) && (col == anim_col);
            if (is_anim_cell) begin
                pixel_color = (anim_player == 1'b0) ? 2'b01 : 2'b10;  // 01 = red, 10 = yellow
            end 
				else begin
                pixel_color = color;   // from board contents / winner logic
            end

            //-----------------------------------------------------
            // inside‑circle shading
            //-----------------------------------------------------
            if ((dx*dx + dy*dy) <= (radius*radius)) begin
                case (pixel_color)
                    2'b01: begin // red chip
                        red   = 8'hFF; green = 8'h00; blue  = 8'h00;
                    end
                    2'b10: begin // yellow chip
                        red   = 8'hFF; green = 8'hFF; blue  = 8'h00;
                    end
                    2'b11: begin // green winner highlight
                        red   = 8'h00; green = 8'hFF; blue  = 8'h00;
                    end
                    default: begin // empty hole
                        red   = 8'h00; green = 8'h00; blue  = 8'h00;
                    end
                endcase
            end else begin // grid background (blue panel)
                red   = 8'd0;
                green = 8'd0;
                blue  = 8'hFF;
            end
        end

        //---------------------------------------------------------
        // **** Top slider bar (unchanged) ****
        //---------------------------------------------------------
        else if (vcount > 12 && vcount < 28) begin
            red   = 8'd0; green = 8'd0; blue = 8'd0;
            if (selected_col != 3'd7) begin // guard against -1 signed compare
                col_start = 10 + selected_col * 70;
                col_end   = col_start + 70;
                if (hcount > col_start && hcount < col_end) begin
                    if (which_player == 1'b0) begin
                        red = 8'hFF; green = 8'h00; blue = 8'h00; // red slider
                    end else begin
                        red = 8'hFF; green = 8'hFF; blue = 8'h00; // yellow slider
                    end
                end
            end
        end
		  
        //---------------------------------------------------------
        // **** Logo / text / status areas (unchanged) ****
        //---------------------------------------------------------
        if (hcount >= 500 && hcount < 630 && vcount >= 30 && vcount < 90) begin
            local_h = ((hcount - 500)*100)/130;
            local_v = ((vcount - 30)*100)/130;
            addr    = (100*local_v) + local_h;
            red     = q[23:16];
            green   = q[15:8];
            blue    = q[7:0];
        end else begin
            addr = 14'd0;
        end

        //---------------------------------------------------------
        // Current player indication
        //---------------------------------------------------------
        if (hcount > 500 && hcount < 625 && vcount > 100 && vcount < 140) begin
				if (which_player == 1'b0) begin
				// Player 1 red
				local_h = (hcount - 500);
				local_v = (vcount - 100);
				addr_player    = (120*local_v) + local_h;
				red   = q_player[23:16];
				green = q_player[15:8];
				blue  = q_player[7:0];
				end else begin
				// Player 2 yellow
				local_h = (hcount - 500);
				local_v = (vcount - 100) + 40;
				addr_player    = (120*local_v) + local_h;
				red   = q_player[23:16];
				green = q_player[15:8];
				blue  = q_player[7:0];
				end
        end

        if (hcount > 500 && hcount < 620 && vcount > 160 && vcount < 200) begin
            if (win_a || win_b) begin
					if(blink)
					begin
					local_h = (hcount - 500);
					local_v = (vcount - 160);
					addr_result = (120*local_v) + local_h;
					red   = (q_won[23:16])? 8'hff : 8'h00;
					green = (q_won[15:8] && win_b)? 8'hff : 8'h0;
					blue  = 8'h0;
					end
					else begin
					red   = 8'b0;
					green = 8'b0;
					blue  = 8'b0;
					end
				end
				else if (panel)
				begin
					if(blink)
					begin
					local_h = (hcount - 500);
					local_v = (vcount - 160) + 40;
					addr_result = (120*local_v) + local_h;
					red   = q_won[23:16];
					green = q_won[15:8];
					blue  = q_won[7:0];
					end
					else begin
					red   = 8'b0;
					green = 8'b0;
					blue  = 8'b0;
					end
				end
        end
		 end
    end // always_comb
endmodule