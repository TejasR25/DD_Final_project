module vga_controller(
	input  logic vga_clock,
	input  logic reset_n,
	output logic sync_n,
	output logic blank_n,
	output logic hsync_n,
	output logic vsync_n,
	output logic [9:0] hcount,
	output logic [9:0] vcount,
	output logic frame_tick
);

	parameter int FRAME_TICK_DIV = 4;
	localparam TOTAL_H = 800;   // total area 
	localparam VISIBLE_H= 640;  // visible area 
	localparam FRONT_H = 16;	 // front porch 
	localparam BACK_H= 48;		 // back_porch
	localparam SYNC_H= 96;  	 // horizontal sync pulse
	
	localparam TOTAL_V = 525;	 // total area 
	localparam VISIBLE_V = 480; // visible area 
	localparam FRONT_V = 10;	 // front porch 
	localparam BACK_V = 33;		 // back porch 
	localparam SYNC_V = 2;		 // vertical sync pulse
	
	always_ff @(posedge vga_clock or negedge reset_n) begin
		if (!reset_n) begin
			hcount <= 0;
         vcount <= 0;
      end 
		else begin
			if (hcount == TOTAL_H - 1) begin
				hcount <= 0;
            if (vcount == TOTAL_V - 1) 
					vcount <= 0;
				else 
					vcount <= vcount + 1;	// vcount
         end 
			else 
				hcount <= hcount + 1;		// hcount
		end
	end
	
    assign hsync_n = ~((hcount >= (VISIBLE_H + FRONT_H)) && (hcount < (VISIBLE_H + FRONT_H + SYNC_H))); // hsync
    assign vsync_n = ~((vcount >= (VISIBLE_V + FRONT_V)) && (vcount < (VISIBLE_V + FRONT_V + SYNC_V))); // vsync
    assign sync_n = 0;																											  // sync_n
    assign blank_n = (hcount < VISIBLE_H) && (vcount < VISIBLE_V);												  // blank_n
	 
	logic vsync_n_d, vsync_rise;
    always_ff @(posedge vga_clock or negedge reset_n) begin
        if (!reset_n) begin
            vsync_n_d <= 1'b1;
        end else begin
            vsync_n_d <= vsync_n;
        end
    end
    assign vsync_rise = vsync_n_d & ~vsync_n;   // 1‑cycle pulse each frame
	 
	 localparam int CNT_W = $clog2(FRAME_TICK_DIV);
    logic [CNT_W-1:0] frame_cnt;

    always_ff @(posedge vga_clock or negedge reset_n) begin
        if (!reset_n) begin
            frame_cnt  <= '0;
            frame_tick <= 1'b0;
        end else begin
            if (vsync_rise) begin
                if (frame_cnt == FRAME_TICK_DIV-1) begin
                    frame_cnt  <= '0;      // wrap
                    frame_tick <= 1'b1;    // 1‑cycle pulse
                end else begin
                    frame_cnt  <= frame_cnt + 1;
                    frame_tick <= 1'b0;
                end
            end else begin
                frame_tick <= 1'b0;        // ensure single‑cycle width
            end
        end
    end
		
endmodule