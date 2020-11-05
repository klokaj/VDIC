`ifndef INPUT_DECODER
`define INPUT_DECODER




import mtm_alu_pkg::*;
//
//	Klasa dekoduje dane wejsciowe. Wyciga z kolejki danych wyslana komede oraz informacje o tym czy format danych, operacje
// 	oraz CRC sa poprawne
//


class input_data;
	bit [31:0] A;
	bit [31:0] B;
	bit [7:0] ctl;
	operation_t op;
	bit [3:0] crc;
	
	bit format_ok;
	bit op_ok; 
	bit crc_ok;
	
	
	int packet_lenght;
	cmd_format_t format; 
	s_monitor in_monitor = new;
	

	function void sample(bit data, bit rst_n);
		in_monitor.sample(data, rst_n);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();
		//if(in_monitor.q.size() >= 9) return 1;	//min 9 frames recieved
		//return in_monitor.is_ctl_frame_before_index(8);
		return (in_monitor.is_ctl_frame_inside()) || (in_monitor.q.size() >= 9);
	endfunction
	
	function void decode_data();
		bit [8:0] tmp = 0;

		if(in_monitor.is_first_ctl_frame_at_index(8)) format = cmd_ok;
		else if(in_monitor.is_ctl_frame_before_index(8)) format = cmd_short;
		else format = cmd_long;
		
		//reads data from queue
		
	
		if(format == cmd_ok) begin
			for(int i = 0; i < 4; i++) begin
				tmp = in_monitor.q.pop_front();
				B[31-8*i -:8] = tmp[7:0];
			end
			
			for(int i = 0; i < 4; i++) begin
				tmp = in_monitor.q.pop_front();
				A[31-8*i -:8] = tmp[7:0];
			end
			
			tmp = in_monitor.q.pop_front();
			ctl = tmp[7:0];
			format_ok = 1;
			packet_lenght = 8;
		end
		else if(format == cmd_short) begin
			packet_lenght = 0;
			//tmp = in_monitor.q.pop_front();
			while(in_monitor.is_data_frame(0)) begin
				in_monitor.q.pop_front();
				packet_lenght += 1;
			end
			tmp = in_monitor.q.pop_front();
			ctl = tmp[7:0];
			format_ok = 0;
			
		end
		else begin 
			repeat (9) begin
				in_monitor.q.pop_front();
			end
			format_ok = 0;
			packet_lenght = 9;
		end
				
		handle_op();
		handle_crc();
		
		
		//if(format == cmd_ok) $display("CMD OK, %b", crc_ok);
		//else if(format == cmd_short) $display("CMD SHORT, %b", crc_ok);
		//else $display("CMD_LONG, %b", crc_ok);
		
		
	endfunction
	
	function void handle_op();
		if(ctl[6:4] == 3'b000) op = and_op;
		else if(ctl[6:4] == 3'b001) op = or_op;
		else if(ctl[6:4] == 3'b100) op = add_op;
		else if(ctl[6:4] == 3'b101) op = sub_op;
		else op = rsv_op;
		op_ok = !(op == rsv_op);
	endfunction
	
	function void handle_crc();
		bit [3:0] expected_crc;
		crc = ctl[3:0];
		
		expected_crc = nextCRC4_D68({B, A, 1'b1, op});
		crc_ok = (expected_crc == crc);
	endfunction
endclass


`endif
