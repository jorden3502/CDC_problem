// Clock domain crossing handshaking from sclk to pclk
// 2022/7/27
// Jorden

module cdc_test(             
	input sclk, pclk,          // two different clock domain
	input rst_n,
	input data_ready,       // the input of data_sclk 
	output reg [5:0] data_out // the output of data_pclk
);
reg [2:0] state, n_state;
reg [5:0] data_sclk , n_data_sclk; // send data
reg [5:0] data_pclk , n_data_pclk; // receive data

reg data_transfer_pclk , n_data_transfer_pclk; // 2022/8/8

reg req_sclk, n_req_sclk, req_sample_1_pclk, req_sample_2_pclk; // request from sclk domain to pclk domain
reg ack_pclk, n_ack_pclk, ack_sample_1_sclk, ack_sample_2_sclk; // acknowledge from pclk domain to sclk domain
 



parameter IDLE = 3'd0, TRANSFER = 3'd1;
//***************************************
//*               FSM                   *  
//***************************************
always@(*) begin
	n_req_sclk = 0;
	n_ack_pclk = 0;
	
	n_data_sclk = 0;
	n_data_pclk = 0;
	n_data_transfer_pclk = 0;
	
	case (state)
		IDLE: begin
			n_req_sclk = req_sclk;
			n_ack_pclk = ack_pclk;
			
			if (data_ready) begin
				n_state = TRANSFER;
				n_data_sclk = data_sclk;
				n_data_pclk = data_pclk;
				n_req_sclk = 1;
			end
			else begin
				n_state = IDLE;
				n_data_sclk = data_sclk;
				n_data_pclk = data_pclk;
				n_req_sclk = 0;
			end
			
			
			
		end
		
		TRANSFER: begin
			n_req_sclk = req_sclk;
			n_ack_pclk = ack_pclk;
			
			n_data_pclk = data_pclk;
		

			
			if (req_sclk == 1) begin
				n_data_sclk = data_sclk;
			end
			else if (req_sclk == 0 && ack_sample_2_sclk == 0) begin
				n_data_sclk = data_sclk;
			end
			else begin 
				n_data_sclk = data_sclk + 1;
			end
			

			if (ack_pclk == 0 && req_sample_2_pclk) begin
				n_data_transfer_pclk = 1;
				n_data_pclk = data_sclk;
			end
			
			if (data_transfer_pclk == 1) begin
				n_data_transfer_pclk = 0;
				n_ack_pclk = 1;
			end
			
			
			
			if (req_sclk == 1 && ack_sample_2_sclk) 
				n_req_sclk = 0;
			
			if (ack_pclk == 1 && ~req_sample_2_pclk) 
				n_ack_pclk = 0;
				

			if (req_sclk == 0 && ack_sample_2_sclk == 0) begin
				n_req_sclk = 1;
				n_data_sclk = data_sclk;
			end
		
		end
		

	
	endcase 
end

always@(posedge sclk) begin
	if (~rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= n_state;
	end

end







always@(posedge sclk) begin
	if (~rst_n) begin
	
		data_sclk <= 0;
		req_sclk <= 0;
	
		ack_sample_1_sclk <= 0;	
		ack_sample_2_sclk <= 0;
	end
	else begin
		data_sclk <= n_data_sclk;
	
		req_sclk <= n_req_sclk;
	
		ack_sample_1_sclk <= ack_pclk;
		ack_sample_2_sclk <= ack_sample_1_sclk;
	end

end



always@(posedge pclk) begin
	if (~rst_n) begin
		data_pclk <= 0;
		ack_pclk <= 0;
	
		req_sample_1_pclk <= 0;	
		req_sample_2_pclk <= 0;
		data_transfer_pclk <= 0;
		
	end
	else begin
		data_pclk <= n_data_pclk;
		ack_pclk <= n_ack_pclk;
	
		req_sample_1_pclk <= req_sclk;
		req_sample_2_pclk <= req_sample_1_pclk;
		data_transfer_pclk <= n_data_transfer_pclk;
	end

end

endmodule
