`timescale 1ns / 1ps

module top_tb;

    // DUT ports
    logic CLOCK_50;
    logic [3:0] KEY;
    logic [7:0] VGA_R, VGA_G, VGA_B;
    logic VGA_HS, VGA_VS;

    // Instantiate DUT
    top dut (
        .clk(CLOCK_50),
        .KEY(KEY),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS)
    );

    // Clock generation (50 MHz)
    initial begin
	 CLOCK_50 = 0;
	 dut.clk_25 = 0;
	 end
	 
	 always #10 CLOCK_50 = ~CLOCK_50;  // 20ns period = 50 MHz
	 always #20 dut.clk_25 = ~dut.clk_25;

    // Simulation control
    initial begin
        // Dump waveforms
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // Initial reset
        KEY[0] = 0;  // Active-low reset asserted
        #100;
        KEY[0] = 1;  // Release reset

        // Simulate for a short duration
        #1000000;

        $display("Simulation finished.");
        $finish;
    end

endmodule
