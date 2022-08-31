// GFB handshaking problem testbench
// 2022/8/17
// Jorden

`timescale 1ns/1ps
module tb_GFB_handshaking_problem;

parameter CYCLE = 10;

parameter IDLE = 3'd0, READ = 3'd1, WRITE = 3'd2, ROW_WRITE = 3'd3, 
          ERASE = 3'd4, MASS_ERASE = 3'd5;

reg PCLK, SCLK;
reg RESETn_pclk, RESETn_sclk;

reg [2:0]CMD;
reg [9:0]ADDR;
reg [9:0]WDATA;
reg ABORT;


wire [9:0]RDATA_sclk;

wire READY_pclk;
wire [9:0]RDATA_pclk;  
wire RESP_pclk;

wire  [2:0]CMD_REG_pclk;
wire  [9:0]ADDR_REG_pclk;
wire  [9:0]WDATA_REG_pclk;
wire  ABORT_REG_pclk;


wire req_pclk, ack_pclk;
wire req_sclk, ack_sclk;

reg temp_READY_sclk;


reg command;
reg [9:0] cmd_time_cnt;


Master_pclk Master_pclk (
    // with user
    .PCLK(PCLK),
    .RESETn_pclk(RESETn_pclk),
    .CMD(CMD),
    .ADDR(ADDR),
    .WDATA(WDATA),
    .ABORT(ABORT),
    .READY_pclk(READY_pclk),
    .RDATA_pclk(RDATA_pclk), 
    .RESP_pclk(RESP_pclk),
    // with slave
    .RDATA_sclk(RDATA_sclk),

    
    .CMD_REG_pclk(CMD_REG_pclk),
    .ADDR_REG_pclk(ADDR_REG_pclk),
    .WDATA_REG_pclk(WDATA_REG_pclk),
    .ABORT_REG_pclk(ABORT_REG_pclk),

    .req_pclk(req_pclk),
    .ack_pclk(ack_pclk),
    .req_sclk(req_sclk),
    .ack_sclk(ack_sclk)
);


Slave_sclk Slave_sclk(
    .SCLK(SCLK),
    .RESETn_sclk(RESETn_sclk),
    .CMD_REG_pclk(CMD_REG_pclk),
    .ADDR_REG_pclk(ADDR_REG_pclk),
    .WDATA_REG_pclk(WDATA_REG_pclk),
    .ABORT_REG_pclk(ABORT_REG_pclk),
    .RDATA_sclk(RDATA_sclk),

    .req_sclk(req_sclk),
    .ack_sclk(ack_sclk),
    .req_pclk(req_pclk),
    .ack_pclk(ack_pclk)

);


`ifdef FAST2SLOW   // SCLK faster than PCLK
	initial begin
		$fsdbDumpfile("GFB_fast_to_slow.fsdb");
		$fsdbDumpvars;

	end

	always #(CYCLE/2 ) SCLK = ~SCLK;
	always #(3*CYCLE/2 + 5) PCLK = ~PCLK;

`elsif SLOW2FAST // SCLK slower than PCLK
	initial begin
		$fsdbDumpfile("GFB_slow_to_fast.fsdb");
		$fsdbDumpvars;

	end

	always #(CYCLE/2 ) PCLK = ~PCLK;
	always #(5*CYCLE/2 + 1) SCLK = ~SCLK;


`endif 

initial begin
		PCLK = 1;
		SCLK = 1;
		command = 0;
		cmd_time_cnt = 0;
    
    temp_READY_sclk = 0;
    CMD = IDLE;
    
    
    #(10000*CYCLE) $finish;
end


 // case 1
 
always begin

    
    wait(READY_pclk)
 		

    #(10 * CYCLE)
    @(negedge PCLK)
    
    CMD = WRITE + command;
    @(negedge PCLK)
    CMD = IDLE;
  	
 	
		command = ~command;
		if (cmd_time_cnt < 10)
			cmd_time_cnt = cmd_time_cnt + 1;
		else
			cmd_time_cnt = 0;
		#(15 * CYCLE) CMD = IDLE;
		
		
end




/*
 // case2
always begin


    @(posedge READY_pclk)

    @(negedge PCLK)
    
    
    @(negedge PCLK)
    CMD = 2;
    @(negedge PCLK)
    CMD = 4;
    
    #(10 * CYCLE)
    CMD = WRITE + command;
  
 	
		command = ~command;
		if (cmd_time_cnt < 10)
			cmd_time_cnt = cmd_time_cnt + 1;
		else
			cmd_time_cnt = 0;
		
		
		
end

*/



initial begin
    RESETn_pclk = 1;   
    @(posedge PCLK) RESETn_pclk = 0;
    @(posedge PCLK) RESETn_pclk = 1;   

end

initial begin
    RESETn_sclk = 1;
    @(posedge SCLK) RESETn_sclk = 0;
    @(posedge SCLK) RESETn_sclk = 1;   
end



endmodule
