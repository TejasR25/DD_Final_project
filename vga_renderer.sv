module vga_renderer #(
    parameter int CELL_SIZE = 80  // default: 80x80 pixel cells
) (
    input  logic       clk,
    input  logic       video_on,
    input  logic [9:0] pixel_x,
    input  logic [9:0] pixel_y,
    input  logic [1:0] grid [0:5][0:6], // 6 rows × 7 cols
    output logic [7:0] r,
    output logic [7:0] g,
    output logic [7:0] b
);

    localparam COLS = 7;
    localparam ROWS = 6;

    // Map pixel coordinates to cell indices
    logic [2:0] cell_col;
    logic [2:0] cell_row;

    assign cell_col = pixel_x / CELL_SIZE;
    assign cell_row = pixel_y / CELL_SIZE;

    logic [1:0] cell_value;

    // Select the appropriate cell value from grid
    assign cell_value = (cell_col < COLS && cell_row < ROWS) ? grid[cell_row][cell_col] : 2'b00;

    // RGB Output logic
    always_ff @(posedge clk) begin
        if (!video_on) begin
            r <= 8'd0;
            g <= 8'd0;
            b <= 8'd0;
        end else begin
            case (cell_value)
                2'b01: begin // Player 1 (Red)
                    r <= 8'hFF;
                    g <= 8'h00;
                    b <= 8'h00;
                end
                2'b10: begin // Player 2 (Yellow)
                    r <= 8'hFF;
                    g <= 8'hFF;
                    b <= 8'h00;
                end
                default: begin // Empty
                    r <= 8'h00;
                    g <= 8'h00;
                    b <= 8'hFF;
                end
            endcase
        end
    end

endmodule
