module vga_timing_generator (
    input  logic clk,           // 25 MHz pixel clock
    input  logic rst_n,         // Active low reset
    output logic hsync,
    output logic vsync,
    output logic video_on,      // AKA blank_n
    output logic [9:0] pixel_x,
    output logic [9:0] pixel_y
);

    // Horizontal timing parameters
    localparam H_ACTIVE  = 10'd639;
    localparam H_FRONT   = 10'd655;
    localparam H_PULSE   = 10'd751;
    localparam H_BACK    = 10'd799;

    // Vertical timing parameters
    localparam V_ACTIVE  = 10'd479;
    localparam V_FRONT   = 10'd489;
    localparam V_PULSE   = 10'd491;
    localparam V_BACK    = 10'd524;

    // FSM states for horizontal and vertical
    typedef enum logic [2:0] {
        H_ACTIVE_STATE,
        H_FRONT_STATE,
        H_PULSE_STATE,
        H_BACK_STATE
    } HState;

    typedef enum logic [2:0] {
        V_ACTIVE_STATE,
        V_FRONT_STATE,
        V_PULSE_STATE,
        V_BACK_STATE
    } VState;

    // Internal state
    logic [9:0] h_counter = 0;
    logic [9:0] v_counter = 0;
    HState h_state = H_ACTIVE_STATE;
    VState v_state = V_ACTIVE_STATE;
    logic hsync_reg, vsync_reg, line_done;

    // Horizontal FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            h_counter <= 0;
            h_state <= H_ACTIVE_STATE;
            hsync_reg <= 1;
            line_done <= 0;
        end else begin
            case (h_state)
                H_ACTIVE_STATE: begin
                    h_counter <= h_counter + 1;
                    hsync_reg <= 1;
                    line_done <= 0;
                    if (h_counter == H_ACTIVE)
                        h_state <= H_FRONT_STATE;
                end
                H_FRONT_STATE: begin
                    h_counter <= h_counter + 1;
                    if (h_counter == H_FRONT)
                        h_state <= H_PULSE_STATE;
                end
                H_PULSE_STATE: begin
                    h_counter <= h_counter + 1;
                    hsync_reg <= 0;
                    if (h_counter == H_PULSE)
                        h_state <= H_BACK_STATE;
                end
                H_BACK_STATE: begin
                    h_counter <= (h_counter == H_BACK) ? 0 : h_counter + 1;
                    hsync_reg <= 1;
                    line_done <= (h_counter == H_BACK - 1);
                    if (h_counter == H_BACK)
                        h_state <= H_ACTIVE_STATE;
                end
            endcase
        end
    end

    // Vertical FSM
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            v_counter <= 0;
            v_state <= V_ACTIVE_STATE;
            vsync_reg <= 1;
        end else if (line_done) begin
            case (v_state)
                V_ACTIVE_STATE: begin
                    v_counter <= v_counter + 1;
                    vsync_reg <= 1;
                    if (v_counter == V_ACTIVE)
                        v_state <= V_FRONT_STATE;
                end
                V_FRONT_STATE: begin
                    v_counter <= v_counter + 1;
                    if (v_counter == V_FRONT)
                        v_state <= V_PULSE_STATE;
                end
                V_PULSE_STATE: begin
                    v_counter <= v_counter + 1;
                    vsync_reg <= 0;
                    if (v_counter == V_PULSE)
                        v_state <= V_BACK_STATE;
                end
                V_BACK_STATE: begin
                    v_counter <= (v_counter == V_BACK) ? 0 : v_counter + 1;
                    vsync_reg <= 1;
                    if (v_counter == V_BACK)
                        v_state <= V_ACTIVE_STATE;
                end
            endcase
        end
    end

    // Output assignments
    assign pixel_x = h_counter;
    assign pixel_y = v_counter;
    assign hsync = hsync_reg;
    assign vsync = vsync_reg;
    assign video_on = (h_counter <= H_ACTIVE) && (v_counter <= V_ACTIVE);

endmodule
