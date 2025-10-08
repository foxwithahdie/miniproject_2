`timescale 10ns/10ns
`include "src/top.sv"
`include "tests/setup.v"

module test_top;
    // Determined by compilation process. Read Makefile for more.
    output logic [255 * 8 - 1 : 0] file_name;

    setup u0(
        .file_name (file_name)
    );

    // Set PWM interval.
    parameter PWM_INTERVAL = 1200;

    // Give fake values of all of these, instead of them going to the iceBlinkPico.
    logic clk = 0;
    logic RGB_R;
    logic RGB_G;
    logic RGB_B;

    // Run top
    top #(
        .c_PWM_INTERVAL (PWM_INTERVAL)
    ) test_u0 (
        .clk (clk),
        .RGB_R (RGB_R),
        .RGB_G (RGB_G),
        .RGB_B (RGB_B)
    );

    // Dump file and variables into a program
   initial begin
        $dumpfile(file_name);
        $dumpvars(0, test_top);
        #100000000
        $finish;
    end

    // Automatically run clock
    always begin
        // The simulation is run at 12.5MHz instead of 12MHz, 
        // but it should theoretically run with the same behavior.
        #4
        clk = ~clk;
    end
endmodule