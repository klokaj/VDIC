

interface mtm_alu_bfm;

import mtm_alu_pkg::*;
	
	
bit      clk;	// mtm_Alu clock
bit      reset_n;// mtm_Alu reset
bit  	 sin;	// mtm_Alu serial in
wire  	 sout;	// mtm_Alu serial out	
	
	
   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end
   
 
   
   task reset_alu();
	    sin = 1;
		reset_n = 1'b0;
    	@(negedge clk);
    	@(negedge clk);
    	reset_n = 1'b1;   
   endtask : reset_alu
   
   
   task tx_frame(input bit [8:0] d);
		int i;
		bit [10:0] frame; 
		frame = {1'b0, d, 1'b1};
		for(i = 10; i >=0; i--) begin
			@(negedge clk);
			sin = frame[i];
		end
		@(negedge clk);  
		@(negedge clk); 
	endtask
	
	task tx_data(input bit [7:0] d);
		tx_frame({1'b0, d});
	endtask
	
	task tx_command(input bit [7:0] d);
		tx_frame({1'b1, d});
	endtask
	
	//send whole packet. last element of queue is treated as an CTL command
	task tx_packet(input bit [7:0] q [$]);
		bit [7:0] byte_to_send;
		bit [10:0] frame_to_send;
		while(q.size() > 1) begin
			tx_data(q.pop_front());
		end
		tx_command(q.pop_front());
		
		repeat (50) 
			 @(negedge clk);
	endtask
	   
	   
		

	function operation_t op2enum(bit[2:0] op);
		operation_t opi;
		if( ! $cast(opi, op) )
			$fatal(1, "Illegal operation on op bus");
		
		return opi;
	endfunction :op2enum

	command_monitor command_monitor_h;
	always  begin : sin_monitor
		bit[8:0] tmp;
		command_s command;
		SerialMonitor inMonitor; 
		operation_t op;
		
		inMonitor = new();
		
		forever begin : sin_monitor_loop
			@(negedge clk);
			inMonitor.sample(sin, reset_n);
			
			if( inMonitor.get_lenght() >= 9 ) begin
				for(int i = 0; i < 4; i++) begin
					tmp = inMonitor.pop_front();
					command.B[31-8*i -:8] = tmp[7:0];
				end
			
				for(int i = 0; i < 4; i++) begin
					tmp = inMonitor.pop_front();
					command.A[31-8*i -:8] = tmp[7:0];
				end
			
				tmp = inMonitor.pop_front();
				
				command.crc = tmp[3:0];
				command.op = op2enum(tmp[6:4]);
				$display("Put command!!!!");
				$display("A:%g, B:%g, crc:%b", command.A, command.B, command.crc);
				command_monitor_h.write_to_monitor(command);
			end
		end	: sin_monitor_loop
	end : sin_monitor
	


	result_monitor result_monitor_h;
	always @(posedge clk) begin :sout_monitor

		bit[8:0] tmp;
		result_s result;
		SerialMonitor outMonitor; 
		
		outMonitor = new();
		
		forever begin : sout_monitor_loop
			@(negedge clk);
			outMonitor.sample(sout, reset_n);
			
			if(outMonitor.get_lenght() >= 4) begin
				for(int i = 0; i < 4; i++) begin
					tmp = outMonitor.pop_front();
					result.C[31-8*i -:8] = tmp[7:0];
				end
				
				tmp = outMonitor.pop_front();
				result.error = 0;
				result.flag.carry = tmp[6];
				result.flag.ovf = tmp[5];				
				result.flag.zero = tmp[4];
				result.flag.neg = tmp[3];		
				result.crc = tmp[2:0];
				result_monitor_h.write_to_monitor(result);
			end
			else if(outMonitor.get_lenght() == 1) begin
				if(outMonitor.is_ctl_frame_inside()) begin
					tmp = outMonitor.pop_front();
					result.error = 1;
					result.err_flag.data = tmp[3];
					result.err_flag.crc = tmp[2];
					result.err_flag.op = tmp[1];
					result_monitor_h.write_to_monitor(result);
				
				end
			
			end
			
			
		end	: sout_monitor_loop	
	end :sout_monitor
	
	
endinterface : mtm_alu_bfm
