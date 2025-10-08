// Converts the PWM current value into something that can be driven to an LED at a given time.

module pwm_loop #(
    parameter c_PWM_INTERVAL = 1200 // Amount of loops, in clock cycles, spent at HIGH. Accounts to around 100us.
)(
    input logic clk,
    input logic [$clog2(c_PWM_INTERVAL) - 1:0] l_pwm_value, // The current value of the PWM, whether its increasing, decreasing or flat HIGH or LOW.
    output logic l_pwm_signal // The output 1 or 0 for the PWM signal. If it is 1, the LED will be off, and if it is 0, the LED will be on.
);

    logic [$clog2(c_PWM_INTERVAL) - 1:0] l_pwm_count = 0; // Counter for PWM loop.

    // Counts over time to determine if you have reached the PWM interval.
    always_ff @(posedge clk) begin
        if (l_pwm_count == c_PWM_INTERVAL - 1) begin
            l_pwm_count <= 0;
        end else begin
            l_pwm_count <= l_pwm_count + 1;
        end
    end

    // If you have reached the PWM interval, the signal should no longer be HIGH. If you haven't yet, you should be at HIGH.
    assign l_pwm_signal = (l_pwm_count > l_pwm_value) ? 1'b1 : 1'b0;

endmodule
