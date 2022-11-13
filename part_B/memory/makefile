build:
	iverilog -o memory memory.v memory_tb.v && vvp memory

run:
	build
	vvp memory


.PHONY: build run