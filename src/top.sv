// Main file.

`include "src/fade_single_color.sv"
`include "src/pwm_loop.sv"

module top #(
    parameter c_PWM_INTERVAL = 1200
)(
    input logic clk,
    output logic RGB_R,
    output logic RGB_G,
    output logic RGB_B
);
    // Determined red, green and blue constants. Think of them as preprocessor macros.
    localparam RED = 2'b00;
    localparam GREEN = 2'b01;
    localparam BLUE = 2'b10;

    // The pwm values, driven by the fade logic
    logic [$clog2(c_PWM_INTERVAL) - 1:0] l_red_pwm_value;
    logic [$clog2(c_PWM_INTERVAL) - 1:0] l_green_pwm_value;
    logic [$clog2(c_PWM_INTERVAL) - 1:0] l_blue_pwm_value;


    // Output logic driven by the PWM loop
    logic l_red;
    logic l_green;
    logic l_blue;

    fade_single_color #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL),
        .c_COLOR (RED)
    ) red (
        .clk (clk),
        .l_pwm_value (l_red_pwm_value)
    );

    pwm_loop #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL)
    ) red_pwm (
        .clk (clk),
        .l_pwm_value (l_red_pwm_value),
        .l_pwm_signal (l_red)
    );

    fade_single_color #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL),
        .c_COLOR (GREEN)   
    ) green (
        .clk (clk),
        .l_pwm_value (l_green_pwm_value)
    );

    pwm_loop #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL)
    ) green_pwm (
        .clk (clk),
        .l_pwm_value (l_green_pwm_value),
        .l_pwm_signal (l_green)
    );

    fade_single_color #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL),
        .c_COLOR (BLUE)
    ) blue (
        .clk (clk),
        .l_pwm_value (l_blue_pwm_value)
    );

    pwm_loop #(
        .c_PWM_INTERVAL (c_PWM_INTERVAL)
    ) blue_pwm (
        .clk (clk),
        .l_pwm_value (l_blue_pwm_value),
        .l_pwm_signal (l_blue)
    );

    // LEDs on the board are active LOW
    assign RGB_R = ~l_red;
    assign RGB_G = ~l_green;
    assign RGB_B = ~l_blue;

endmodule