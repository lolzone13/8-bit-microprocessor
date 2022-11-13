build:
	iverilog -o alu alu.v alu_tb.v && vvp alu

run:
	build
	vvp alu


.PHONY: build run