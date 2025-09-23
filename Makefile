src = src
test_folder = tests
filename = top
test_filename = test_$(filename)
pcf_file = iceBlinkPico.pcf
build_folder = build_folder
test_build_folder = test_build_folder

build:
	yosys -g -p "synth_ice40 -top top -json $(build_folder)/$(filename).json" $(src)/$(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(build_folder)/$(filename).json --pcf $(pcf_file) --asc $(build_folder)/$(filename).asc
	icepack $(build_folder)/$(filename).asc $(build_folder)/$(filename).bin

test:
	python -c 'with open("$(test_folder)/setup.v", "w+", encoding="utf-8") as setup: setup.write("module setup (output logic [255*8-1:0] file_name);\n     assign file_name = \"$(test_build_folder)/$(test_filename).vcd\";\nendmodule\n")'
	iverilog -g2012 -o $(test_build_folder)/$(test_filename) $(test_folder)/$(test_filename).sv
	vvp $(test_build_folder)/$(test_filename)
	gtkwave $(test_build_folder)/$(test_filename).vcd

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(build_folder)/$(filename).bin -R

clean:
	rm -rf $(build_folder)/* $(test_build_folder)/* tests/setup.v
