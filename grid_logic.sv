module grid_logic (
    input  logic        clk,
    input  logic        rst_n,           // Active-low reset
    input  logic        drop_en,         // 1-cycle drop pulse
    input  logic [2:0]  column_select,   // From input controller
    input  logic [1:0]  player,          // 01 = Player 1, 10 = Player 2
    output logic        column_full,     // Indicates full column
    output logic [1:0]  grid_out [0:5][0:6]
);

    // Internal 6x7 grid
    logic [1:0] grid [0:5][0:6];  // [row][col]

    // Column full detection
    always_comb begin
        column_full = (grid[0][column_select] != 2'b00);
    end

    // Reset and drop logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (int r = 0; r < 6; r++)
                for (int c = 0; c < 7; c++)
                    grid[r][c] <= 2'b00;
        end else if (drop_en && !column_full) begin
            // Drop piece from bottom row up
            for (int r = 5; r >= 0; r--) begin
                if (grid[r][column_select] == 2'b00) begin
                    grid[r][column_select] <= player;
                    break;
                end
            end
        end
    end

    // Output the grid
    always_comb begin
        for (int r = 0; r < 6; r++)
            for (int c = 0; c < 7; c++)
                grid_out[r][c] = grid[r][c];
    end

endmodule
