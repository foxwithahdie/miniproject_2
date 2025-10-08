// Describes the behavior of a single RGB LED, and its pattern over time.

module fade_single_color #(
    parameter c_PWM_INTERVAL = 1200, // Amount of loops, in clock cycles, spent at HIGH during a PWM state. Set to 1200Hz, representing 100us.
    parameter c_CHANGE_INTERVAL = 12000, // Amount of loops, in clock cycles, at a current state.
    parameter c_CHANGE_TRIGGER = 167, // How many increments/decrements happen before you change states. Adds up to 0.16 seconds.
    parameter c_CHANGE_AMOUNT = c_PWM_INTERVAL / c_CHANGE_TRIGGER, // The amount that you increment/decrement by, for increasing or decreasing state.
    parameter c_COLOR = 2'b00 // Either red, green or blue. Meant to signify initial color value.
)(
    input logic clk,
    output logic [$clog2(c_PWM_INTERVAL) - 1:0] l_pwm_value
);

    // Treat these more as preprocessor macros. Meant to be constants meant to make things easier to read.

    // Boolean logic
    localparam true = 1'b1;
    localparam false = 1'b0;

    // Different colors. 2'b11 is not a color state
    localparam RED = 2'b00;
    localparam GREEN = 2'b01;
    localparam BLUE = 2'b10;

    // All possible states of the LEDs. 1 and 2 describe two cycles instead of 1 for being at a flat HIGH or LOW.
    localparam INCREASING_STATE = 3'b000;
    localparam DECREASING_STATE = 3'b001;
    localparam FLAT_HIGH_1 = 3'b010;
    localparam FLAT_HIGH_2 = 3'b011;
    localparam FLAT_LOW_1 = 3'b100;
    localparam FLAT_LOW_2 = 3'b101;



    logic [$clog2(c_CHANGE_INTERVAL) - 1:0] l_count = 0; // Keeps track of the amount of loops in a current state
    logic [$clog2(c_CHANGE_TRIGGER) - 1:0] l_change_count = 0; // Keeps track of the amount of loops that have been a certain state

    // Boolean logic for if a change needs to happen, either an uptick in PWM state or a switch in PWM state entirely (HIGH, LOW, increasing, decreasing)
    logic l_change_switch = false;
    logic l_transition_switch = false;

    // Current LED state and next LED state for a specific RGB LED. One of the 6 possible LED states.
    logic [2:0] l_led_state;
    logic [2:0] l_next_led_state = 3'bxxx;

    initial begin
        // Multilayered ternary operator, so it is assignable. Determines the initial state based on the color parameter passed in.
        l_led_state = (c_COLOR == RED) ? 
                            FLAT_HIGH_2  :
                        (c_COLOR == GREEN) ?
                        INCREASING_STATE :
                        (c_COLOR == BLUE) ?
                            FLAT_LOW_1   :
                                    3'bxxx;
        // Drives initial PWM state.
        l_pwm_value = 0;
    end

    // Transitions LED state.
    always_ff @(posedge l_transition_switch) begin
        l_led_state <= l_next_led_state;
    end

    // Determines the next state of the LED, based on its current state.
    always_comb begin
        l_next_led_state = 2'bx;
        case (l_led_state)
            INCREASING_STATE:
                l_next_led_state = FLAT_HIGH_1;
            DECREASING_STATE:
                l_next_led_state = FLAT_LOW_1;
            FLAT_HIGH_1:
                l_next_led_state = FLAT_HIGH_2;
            FLAT_HIGH_2:
                l_next_led_state = DECREASING_STATE;
            FLAT_LOW_1:
                l_next_led_state = FLAT_LOW_2;
            FLAT_LOW_2:
                l_next_led_state = INCREASING_STATE;
            default:
                l_next_led_state = 3'bxxx;
        endcase
    end

    // Counter for whether an increasing or decreasing state needs to increase in value.
    always_ff @(posedge clk) begin
        if (l_count == c_CHANGE_INTERVAL - 1) begin
            l_count <= 0;
            l_change_switch <= true;
        end else begin
            l_count <= l_count + 1;
            if (l_change_switch == true)
                l_change_switch <= false;
        end
    end

    // When an increase does need to happen, you hit this block.
    // If it's at a flat HIGH or LOW, it will just be set to the maximum value.
    // Otherwise, in increasing or decreasing state, it is slowly increasing or decreasing by a given change amount.
    always_ff @(posedge l_change_switch) begin
        case (l_led_state)
            INCREASING_STATE:
                l_pwm_value <= l_pwm_value + c_CHANGE_AMOUNT;
            DECREASING_STATE:
                l_pwm_value <= l_pwm_value - c_CHANGE_AMOUNT;
            FLAT_HIGH_1:
                l_pwm_value <= c_PWM_INTERVAL - 1;
            FLAT_HIGH_2:
                l_pwm_value <= c_PWM_INTERVAL - 1;
            FLAT_LOW_1:
                l_pwm_value <= 0;
            FLAT_LOW_2:
                l_pwm_value <= 0;
            default:
                l_pwm_value <= 0;
        endcase
    end

    // Counter block for whether the state of the LED needs to change entirely.
    always_ff @(posedge l_change_switch) begin
        if (l_change_count == c_CHANGE_TRIGGER) begin
            l_change_count <= 0;
            l_transition_switch <= true;
        end else begin
            l_change_count <= l_change_count + 1;
            if (l_transition_switch == true)
                l_transition_switch <= false;
        end 
    end

endmodule