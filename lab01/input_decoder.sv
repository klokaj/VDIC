`ifndef INPUT_DECODER
`define INPUT_DECODER

`include "data_types.sv"
`include "crc_calc.sv"
`include "serial_monitor.sv"


class input_data;
	bit [31:0] A;
	bit [31:0] B;
	bit [7:0] ctl;
	operation_t op;
	bit [3:0] crc;
	bit format_ok;
	bit op_ok; 
	bit crc_ok;
	
	s_monitor in_monitor = new;
	
	//function new();
	//	in_monitor = new;
	//endfunction
	
	//samples series in data and stores them in queue
	function sample(bit data);
		in_monitor.sample(data);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();
		//if(in_monitor.q.size() >= 9) return 1;	//min 9 frames recieved
		//return in_monitor.is_ctl_frame_before_index(8);
		return in_monitor.is_ctl_frame_inside();
	endfunction
	

	function decode_data();
		bit [8:0] tmp = 0;
		format_ok = in_monitor.is_first_ctl_frame_at_index(8);
		//reads data from queue
		
		if(format_ok) begin
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
		end
		else begin
			//tmp = in_monitor.q.pop_front();
			while(in_monitor.is_data_frame(0)) begin
				in_monitor.q.pop_front();
			end
			if(in_monitor.is_ctl_frame(0)) begin
				tmp = in_monitor.q.pop_front();
				ctl = tmp[7:0];
			end
			else ctl = 0;
		end
		
		handle_op();
		handle_crc();
		
	endfunction
	
	function handle_op();
		if(ctl[6:4] == 3'b000) op = and_op;
		else if(ctl[6:4] == 3'b001) op = or_op;
		else if(ctl[6:4] == 3'b100) op = add_op;
		else if(ctl[6:4] == 3'b101) op = sub_op;
		else op = rsv_op;
		op_ok = !(op == rsv_op);
	endfunction
	
	function handle_crc();
		bit [3:0] expected_crc;
		crc = ctl[3:0];
		
		expected_crc = nextCRC4_D68({B, A, 1'b1, ctl[6:4]});
		crc_ok = (expected_crc == crc);
	endfunction
endclass


`endif