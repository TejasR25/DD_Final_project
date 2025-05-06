module input_controller (
    input  logic        clk,
    input  logic        rst_n,          // Active-low reset
    input  logic [2:0]  switches,       // SW[2:0] for column select
    input  logic        drop_button_n,  // KEY[1] (active-low)
    output logic [2:0]  column_select,
    output logic        drop_en         // 1-cycle pulse on button press
);

    // Debounced and edge-detected button press
    logic drop_sync_0, drop_sync_1, drop_sync_2;
    logic drop_pressed;

    // Synchronize drop button (2-stage)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            drop_sync_0 <= 1;
            drop_sync_1 <= 1;
            drop_sync_2 <= 1;
        end else begin
            drop_sync_0 <= drop_button_n;
            drop_sync_1 <= drop_sync_0;
            drop_sync_2 <= drop_sync_1;
        end
    end

    // Detect rising edge of button (i.e., button released → goes high)
    assign drop_pressed = (drop_sync_1 && !drop_sync_2);

    // Generate 1-cycle pulse
    logic drop_pulse;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            drop_pulse <= 0;
        else
            drop_pulse <= drop_pressed;
    end

    assign drop_en = drop_pulse;
    assign column_select = switches;

endmodule
