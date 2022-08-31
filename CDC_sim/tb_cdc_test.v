// Clock domain crossing handshaking from sclk to pclk testbench
// 2022/7/27
// Jorden

`timescale 1ns/1ps
module tb_cdc_test;

parameter CYCLE = 10;

reg pclk, sclk, rst_n;
reg data_ready;
wire [5:0] data_out;


cdc_test U0(
.sclk(sclk),
.pclk(pclk),
.rst_n(rst_n),
.data_ready(data_ready),
.data_out(data_out)
);


`ifdef FAST2SLOW   // sclk faster than pclk
	initial begin
		$fsdbDumpfile("fast_to_slow.fsdb");
		$fsdbDumpvars;

	end

	always #(CYCLE/2 ) sclk = ~sclk;
	always #(2*CYCLE/2 + 50) pclk = ~pclk;

`elsif SLOW2FAST // sclk slower than pclk
	initial begin
		$fsdbDumpfile("slow_to_fast.fsdb");
		$fsdbDumpvars;

	end

	always #(2*CYCLE/2 + 50) sclk = ~sclk;
	always #(CYCLE/2) pclk = ~pclk;

`endif 



initial begin 
	rst_n = 1;
	pclk = 0;
	sclk = 0;
	data_ready = 0;
	

	
	@(negedge sclk)rst_n = 0;
	@(negedge sclk)@(negedge pclk) rst_n = 1;
	
	#(CYCLE*50) data_ready = 1;

	#(CYCLE*10000) 
	
	$display("Congratulation! Simulation is done!");
	$finish;
	
	
end
	




endmodule
