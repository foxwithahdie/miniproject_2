`timescale 10ns/10ns
`include "../src/top.sv"
`include "setup.v"

module test_top;
    output logic [255 * 8 - 1 : 0] file_name;

    setup u0(
        .file_name (file_name)
    );

   initial begin
        $dumpfile(file_name);
        $dumpvars(0, test_top);
        #60000000
        $finish;
    end
endmodule