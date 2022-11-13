build:
	iverilog -o registers registers.v registers_tb.v && vvp registers

run:
	build
	vvp registers


.PHONY: build run