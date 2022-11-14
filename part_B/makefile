build:
	iverilog -o main registers\registers.v alu\alu.v main.v
run:
	build
	vvp main


.PHONY: build run