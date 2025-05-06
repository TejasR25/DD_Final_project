module button_input (
    input  logic clk,       // vga_clock (25 MHz)
    input  logic reset_n,   // Active-low reset
    input  logic button_n,  // Raw button input (active low)

    output logic pulse      // Single clean pulse when button pressed
);

    // Synchronizer and edge detector
    logic sync_0, sync_1;
    logic button_clean;
    logic last_state;

    // First: double-flop synchronizer
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            sync_0 <= 1'b1;
            sync_1 <= 1'b1;
        end else begin
            sync_0 <= button_n;
            sync_1 <= sync_0;
        end
    end

    // Debounced button: invert because KEYs are active low
    assign button_clean = ~sync_1;

    // Edge detector: rising edge
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            last_state <= 1'b0;
        end else begin
            last_state <= button_clean;
        end
    end

    // Pulse: rising edge
    assign pulse = button_clean & ~last_state;

endmodule
