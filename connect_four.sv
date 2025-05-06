module connect_four(
	input logic clock,        // 50MHz board clock
	input  logic [3:0] KEY,   // Active-low reset
	input logic [1:0] SW,
	output logic [7:0] red,
   output logic [7:0] green,
   output logic [7:0] blue,
   output logic vga_clock,
   output logic blank_n,
   output logic hsync_n,
   output logic vsync_n,
   output logic sync_n
);

   // Internal signals
   logic vga_clk;
   logic [9:0] hcount;
   logic [9:0] vcount;
	logic full_panel_c;
	logic which_player_c;
	logic win_a_c;
	logic win_b_c;
	logic invalid_detect_c;
	logic [41:0] winner_tokens_c;
	logic [41:0] color_p0_c;
	logic [41:0] color_p1_c;
	logic [2:0] selected_col_c;
	logic frame_tick;
	
	    // ***** NEW animation wires *****
    logic        anim_active;
    logic [2:0]  anim_col, anim_row;
    logic        anim_player;
	 logic [1:0] game_mode, victor;
	 logic bot_en;
	 
   // PLL instance for VGA clock generation (pll_2 is for 25.2MHz and pll_175 is for 25.175MHz)
	pll25 vga_pll_inst (
		.refclk(clock),
      .rst(~reset_n),       // PLL reset is active-high
      .outclk_0(vga_clk)    // 25.175MHz VGA clock
	);
    
	assign reset_n = KEY[0];
	assign vga_clock = vga_clk; 		// Assign VGA Clock to output
	
//	logic [1:0] sw_meta, sw_sync;
//	always_ff @(posedge vga_clk) begin
//		sw_meta <= SW;
//		sw_sync <= sw_meta;           // 1‑FF synchroniser
//	end
//	assign bot_en = (sw_sync == 2'b01);   // 1 when bot should play yellow
	
   button_input left_button (
		.clk(vga_clock), 
		.reset_n (reset_n),
		.button_n (KEY[3]), 
		.pulse(left)
	);
	
   button_input right_button (
		.clk(vga_clock), 
		.reset_n (reset_n), 
		.button_n (KEY[2]), 
		.pulse(right)
	);
	
   button_input put_button (
		.clk(vga_clock), 
		.reset_n(reset_n), 
		.button_n (KEY[1]), 
		.pulse(put)
	);

   vga_controller vga_controller_inst (
		.vga_clock(vga_clk),
      .reset_n(reset_n), 				// Use combined reset
      .hsync_n(hsync_n),
      .vsync_n(vsync_n),
      .sync_n(sync_n),
      .blank_n(blank_n),
      .hcount(hcount),
      .vcount(vcount),
		.frame_tick(frame_tick)
	);
    
   vga_display vga_display_inst (
		.vga_clock(vga_clk),
		.game_mode(game_mode),
		.victor(victor),
		.frame_tick(frame_tick),
		.hcount(hcount),
      .vcount(vcount),
		.red(red),
      .green(green),
      .blue(blue),
		.anim_active    (anim_active),
        .anim_col       (anim_col),
        .anim_row       (anim_row),
        .anim_player    (anim_player),
		.which_player(which_player_c),
		.invalid_detect(invalid_detect_c),
		.win_a(win_a_c),
		.win_b(win_b_c),
		.winner_tokens(winner_tokens_c),
		.selected_col(selected_col_c),
		.color_p0(color_p0_c),
		.color_p1(color_p1_c),
		.panel(full_panel_c)
	);
	
	fsm fsm_inst(
		.switch(SW),
		.clk(vga_clk),
		.rst(reset_n),
		.game_mode(game_mode),
		.victor(victor),
		.frame_tick(frame_tick),
		.which_player(which_player_c),
		.invalid_detect(invalid_detect_c),
		.full_panel(full_panel_c),
		.left(left),
		.right(right),
		.put(put),
		.win_a(win_a_c), 
		.win_b(win_b_c), 
		.winner_tokens(winner_tokens_c),
		.selected_col(selected_col_c),
		.color_p0(color_p0_c),
		.color_p1(color_p1_c),
		.anim_active    (anim_active),
        .anim_col       (anim_col),
        .anim_row       (anim_row),
        .anim_player    (anim_player)
	);
	
endmodule
