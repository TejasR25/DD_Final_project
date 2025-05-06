module top (
    input  logic clk,
	 input logic[2:0] SW,
    input  logic [3:0] KEY,
    output logic [7:0] VGA_R,
    output logic [7:0] VGA_G,
    output logic [7:0] VGA_B,
	 output logic LED,
    output logic VGA_HS,
    output logic VGA_VS
);

	 // Reset active high (KEY[0] is active low)
    logic rst_n;
    assign rst_n = ~KEY[0];
	 logic clk_25;
	 logic [1:0] player_turn;  // You can initialize manually for now
	 logic [1:0] grid_output [0:5][0:6];
	 //PLL of 25.175 MHz
	 pll_25 vga_clock(
		.refclk(clk),   //  refclk.clk
		.rst(rst_n),      //   reset.reset
		.outclk_0(clk_25)  // outclk0.clk
	);
	 
    logic [9:0] x, y;
    logic hsync, vsync, video_on;

    vga_timing_generator timing_gen (
        .clk(clk_25),
        .rst_n(rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(x),
        .pixel_y(y)
    );

    logic [7:0] r, g, b;

    vga_renderer renderer (
        .clk(clk_25),
        .video_on(video_on),
        .pixel_x(x),
        .pixel_y(y),
        .grid(grid_output), // Not used yet
        .r(r),
        .g(g),
        .b(b)
    );
	 
	 // Input controller outputs
	logic drop_en;
	logic [2:0] column_select;
	
	input_controller in_ctrl (
		.clk(clk_25),
		.rst_n(rst_n),
		.switches(SW[2:0]),
		.drop_button_n(KEY[1]),
		.column_select(column_select),
		.drop_en(drop_en)
	);
	
	grid_logic grid_unit (
		.clk(clk_25),
		.rst_n(rst_n),
		.drop_en(drop_en),
		.column_select(column_select),
		.player(player_turn),
		.column_full(LED),         // You can wire to an LED later
		.grid_out(grid_output)
	);
	
	always_ff @(posedge clk_25) begin
    if (!rst_n)
        player_turn <= 2'b01;  // Start with Player 1
    else if (drop_en)
        player_turn <= (player_turn == 2'b01) ? 2'b10 : 2'b01;
end

	
    assign VGA_HS = hsync;
    assign VGA_VS = vsync;
    assign VGA_R  = r;
    assign VGA_G  = g;
    assign VGA_B  = b;

endmodule