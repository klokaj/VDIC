`include "mtm_alu_pkg.sv"

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
	endtask;
	
	task tx_command(input bit [7:0] d);
		tx_frame({1'b1, d});
	endtask;
	
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
	   
   
   
   
   
	
endinterface : mtm_alu_bfm