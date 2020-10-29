`ifndef OUTPUT_DECODER
`define OUTPUT_DECODER

`include "data_types.sv"
`include "crc_calc.sv"
`include "serial_monitor.sv"





class output_data;
	bit [31:0] C;
	bit [7:0] ctl;
	bit [3:0] flags;
	err_flag_t err_flags;
	bit err;
	
	s_monitor out_monitor = new;
	
	function sample(bit data, bit rst_n);
		out_monitor.sample(data, rst_n);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();

		return out_monitor.is_ctl_frame_inside();
	endfunction
	

	function decode_data();
		bit [8:0] tmp = 0;
		//reads data from queue
		if(out_monitor.is_first_ctl_frame_at_index(4) == 1) begin
			for(int i = 0; i < 4; i++) begin
				tmp = out_monitor.q.pop_front();
				C[31-8*i -:8] = tmp[7:0];
			end
			tmp = out_monitor.q.pop_front();
			ctl = tmp[7:0];
		end
		else begin
			//tmp = out_monitor.q.pop_front();
			while(out_monitor.is_data_frame(0)) begin
				out_monitor.q.pop_front();
			end
			if(out_monitor.is_ctl_frame(0)) begin
				tmp = out_monitor.q.pop_front();
				ctl = tmp[7:0];
			end
			else ctl = 0;
		end
		
		
		handle_error();
		handle_flag();
	endfunction
	
	function handle_error();
		err = ctl[7];
		err_flags = no_err;
		if(err) begin
			if(ctl[6] == 1) err_flags = data_err;
			else if(ctl[5] == 1) err_flags = crc_err;
			else if(ctl[4] == 1) err_flags = op_err;
			else if(ctl[3] == 1) err_flags = data_err;
			else if(ctl[2] == 1) err_flags = crc_err;
			else if(ctl[1] == 1) err_flags = op_err;
		end
	endfunction
	
	function handle_flag();
		flags = no_f;
		if(!err) begin
			flags = ctl[6:3];
		end
	endfunction
endclass





class output_dataa;
	bit [31:0] C;
	bit [7:0] ctl;
	bit format_ok;
	bit [3:0] flag;
	err_flag_t error_f;
	bit error;
	
	s_monitor out_monitor = new;
	
	function sample(bit data, bit rst_n);
		out_monitor.sample(data, rst_n);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();

		return out_monitor.is_ctl_frame_inside();
	endfunction
	

	function decode_data();
		bit [8:0] tmp = 0;
		format_ok = out_monitor.is_first_ctl_frame_at_index(4);
		//reads data from queue
		if(format_ok == 1) begin
			for(int i = 0; i < 4; i++) begin
				tmp = out_monitor.q.pop_front();
				C[31-8*i -:8] = tmp[7:0];
			end
			tmp = out_monitor.q.pop_front();
			ctl = tmp[7:0];
		end
		else begin
			//tmp = out_monitor.q.pop_front();
			while(out_monitor.is_data_frame(0)) begin
				out_monitor.q.pop_front();
			end
			if(out_monitor.is_ctl_frame(0)) begin
				tmp = out_monitor.q.pop_front();
				ctl = tmp[7:0];
			end
			else ctl = 0;
		end
		
		
		handle_error();
		handle_flag();
	endfunction
	
	function handle_error();
		error = ctl[7];
		error_f = no_err;
		if(error) begin
			if(ctl[6] == 1) error_f = data_err;
			else if(ctl[5] == 1) error_f = crc_err;
			else if(ctl[4] == 1) error_f = op_err;
			else if(ctl[3] == 1) error_f = data_err;
			else if(ctl[2] == 1) error_f = crc_err;
			else if(ctl[1] == 1) error_f = op_err;
		end
	endfunction
	
	function handle_flag();
		flag = no_f;
		if(!error) begin
			flag = ctl[6:3];
		end
	endfunction
endclass
`endif