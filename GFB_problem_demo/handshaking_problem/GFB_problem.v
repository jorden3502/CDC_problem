// GFB handshaking problem
// 2022/8/17
// Jorden

module  Master_pclk(
    input  PCLK,
    input  RESETn_pclk, 
    input  [2:0]CMD,
    input  [9:0]ADDR,
    input  [9:0]WDATA,
    input  ABORT,

    input  [9:0]RDATA_sclk,

    output reg READY_pclk,
    output reg [9:0]RDATA_pclk,     // only valid at READY high
    output reg RESP_pclk,

    output reg [2:0]CMD_REG_pclk,
    output reg [9:0]ADDR_REG_pclk,
    output reg [9:0]WDATA_REG_pclk,
    output reg ABORT_REG_pclk,

    output reg req_pclk, ack_pclk,  // signal for multiple bit data handshaking
    input  req_sclk, ack_sclk
);

parameter IDLE = 3'd0, READ = 3'd1, WRITE = 3'd2, ROW_WRITE = 3'd3, 
          ERASE = 3'd4, MASS_ERASE = 3'd5;

            
reg [2:0]CMD_pclk;  

reg data_transfer_pclk;         // one cycle for data_transfer (to meet hold time)
reg [2:0]state, n_state;


reg ack_sample1_pclk, ack_sample2_pclk, ack_sample3_pclk;



// **** solution **** //

reg ack_sample_pulse_pclk;
always @(*) begin
	ack_sample_pulse_pclk = ack_sample2_pclk && ~ack_sample3_pclk;



end



always @(posedge PCLK) begin
    if (~RESETn_pclk) begin
        CMD_REG_pclk <= IDLE;  // receive new command
        READY_pclk <= 1'b1;
        req_pclk <= 1'b0;
        ack_pclk <= 1'b0;
    
    end
    else begin

          
        if (READY_pclk) begin
            
            if (CMD_pclk != IDLE) begin
            	req_pclk <= 1'b1;
            	READY_pclk <= 1'b0;
            	CMD_REG_pclk <= CMD_pclk;  // receive new command
            end
            else begin
            	req_pclk <= 1'b0;
            	READY_pclk <= 1'b1;
            	CMD_REG_pclk <= CMD_REG_pclk;  // receive new command
            end
           		
        end
        else if (ack_sample_pulse_pclk && ~READY_pclk) begin
 						READY_pclk <= 1'b1;
        end
        else begin
            CMD_REG_pclk <= CMD_REG_pclk; 
            READY_pclk <= READY_pclk;
        end
        
        
        if (req_pclk && ack_sample2_pclk) begin
        	req_pclk <= 1'b0;
        end


			
				
        
       	
    end


end


always @(posedge PCLK) begin   // sample
	if (~RESETn_pclk) begin
		CMD_pclk <= 0;
    
    ack_sample1_pclk <= 0;
    ack_sample2_pclk <= 0;
    
	end
	else begin
		CMD_pclk <= CMD;
   
    ack_sample1_pclk <= ack_sclk;
    ack_sample2_pclk <= ack_sample1_pclk;
    ack_sample3_pclk <= ack_sample2_pclk;
	
	end


    
end

    
endmodule


module  Slave_sclk(
    input  SCLK,
    input RESETn_sclk,
    input  [2:0]CMD_REG_pclk,
    input  [9:0]ADDR_REG_pclk,
    input  [9:0]WDATA_REG_pclk,
    input  ABORT_REG_pclk,

    output reg [9:0]RDATA_sclk,

    output reg req_sclk, ack_sclk,   // signal for multiple bit data handshaking
    input  req_pclk, ack_pclk // one cycle for data_transfer (to meet hold time)

);

parameter IDLE = 3'd0, READ = 3'd1, WRITE = 3'd2, ROW_WRITE = 3'd3, 
          ERASE = 3'd4, MASS_ERASE = 3'd5;


reg req_sample1_sclk, req_sample2_sclk , req_sample3_sclk;
reg data_transfer_sclk;

reg busy_sclk;
reg [3:0]busy_cnt_sclk;


reg req_sample_pulse_sclk;

// **** original problem 2 **** // direct sample CMD_pclk

reg [2:0] CMD_REG_sample1_sclk, CMD_REG_sample2_sclk;
reg [2 :0] CMD_REG_sclk, ADDR_REG_sclk, WDATA_REG_sclk;


always @(*) begin
	req_sample_pulse_sclk = req_sample2_sclk && ~req_sample3_sclk;
	CMD_REG_sclk = CMD_REG_sample2_sclk;
end


always @(posedge SCLK) begin   // sample

	if (~RESETn_sclk) begin
		ack_sclk <= 0;

		busy_sclk <= 0;
		busy_cnt_sclk <= 0;
	end
	else begin		
			if (req_sample_pulse_sclk) begin
				busy_sclk <= 1'b1;
			end
			
			if (busy_cnt_sclk == 2) begin   // busy end
				busy_cnt_sclk <= 0;
				busy_sclk <= 1'b0;
				ack_sclk <= 1'b1;
			end
			else if (busy_sclk) begin
				busy_cnt_sclk <= busy_cnt_sclk + 1;
				busy_sclk <= 1'b1;
				ack_sclk <= 1'b0;
			end
			
			if (ack_sclk == 1 && ~req_sample2_sclk) begin
				ack_sclk <= 1'b0;
			end
	end

end

always @(posedge SCLK) begin
	if (~RESETn_sclk) begin
		req_sample1_sclk <= 0;
		req_sample2_sclk <= 0;
		req_sample3_sclk <= 0;
		CMD_REG_sample1_sclk <= 0;
		CMD_REG_sample2_sclk <= 0;
	end
	else begin
		req_sample1_sclk <= req_pclk;
		req_sample2_sclk <= req_sample1_sclk;
		req_sample3_sclk <= req_sample2_sclk;   // to generate pulse
		
		CMD_REG_sample1_sclk <= CMD_REG_pclk;
		CMD_REG_sample2_sclk <= CMD_REG_sample1_sclk;
		
	
	
	end

end
    
endmodule
