/******************************************************************************
* DVT CODE TEMPLATE: interface
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/
`timescale 1ns/1ps;
//------------------------------------------------------------------------------
//
// INTERFACE: kl_alu_if
//
//------------------------------------------------------------------------------

// Just in case you need them
`include "uvm_macros.svh"

interface kl_alu_if(clock, reset);
//interface kl_alu_if;
	// Just in case you need it
	import uvm_pkg::*;
	import kl_alu_pkg::*;

	// Clock and reset signals
	input clock;
	input reset;

	// Flags to enable/disable assertions and coverage
	bit checks_enable=1;
	bit coverage_enable=1;

	// TODO Declare interface signals here
	bit  	 sin;	// mtm_Alu serial in
	wire  	 sout;	// mtm_Alu serial out	
	//bit 	 clk;
	wire	 reset_n;
	

	
	wire clk;
	
	assign clk = clock;
	//assign clock = clk;
	assign reset_n = reset;
	
	


//   initial begin : clk_gen
//      clk = 0;
//      forever begin : clk_frv
//         #10;
//         clk = ~clk;
//      end
//   end
   
   task reset_alu();
	    //sin = 1;
//		reset_n = 1'b0;
//    	@(negedge clk);
//    	@(negedge clk);
//    	reset_n = 1'b1;  
//	   	repeat (50) 
//			@(negedge clk);
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
		$display("sending packet");
		repeat (100) 
			 @(negedge clk);
	endtask




//	//You can add covergroups in interfaces
//	covergroup signal_coverage@(posedge clock);
//		//add coverpoints here
//	endgroup
//	// You must instantiate the covergroup to collect coverage
//	signal_coverage sc=new;
//
//	// You can add SV assertions in interfaces
//	my_assertion:assert property (
//			@(posedge clock) disable iff (reset === 1'b0 || !checks_enable)
//			valid |-> (data!==8'bXXXX_XXXX)
//		)
//	else
//		`uvm_error("ERR_TAG","Error")

endinterface : kl_alu_if


/*

interface mtm_alu_bfm;

import mtm_alu_pkg::*;
	
	

	   
	   
		



	command_monitor command_monitor_h;
	always  begin : sin_monitor
		bit [3:0] crc, expected_crc; 
		
		bit[8:0] tmp;
		sequence_item command;
		SerialMonitor inMonitor; 
		operation_t op;
		
		inMonitor = new();
		command = new("command");
		
		forever begin : sin_monitor_loop
			@(negedge clk);
			inMonitor.sample(sin, reset_n);
			
			
			
			if( inMonitor.is_ctl_frame_inside()) begin
				if(inMonitor.is_first_ctl_frame_at_index(8)) begin
					for(int i = 0; i < 4; i++) begin
						tmp = inMonitor.pop_front();
						command.B[31-8*i -:8] = tmp[7:0];
					end
			
					for(int i = 0; i < 4; i++) begin
						tmp = inMonitor.pop_front();
						command.A[31-8*i -:8] = tmp[7:0];
					end
					tmp = inMonitor.pop_front();
					crc = tmp[3:0];
					expected_crc = nextCRC4_D68({command.B, command.A, 1'b1, tmp[6:4]});
				
					if(crc == expected_crc)
						command.op = op2enum(tmp[6:4]);
					else 
						command.op = crc_err_op;
					
					command_monitor_h.write_to_monitor(command);
				end
				else begin 
					
					while(! inMonitor.is_ctl_frame(0)) begin
						tmp = inMonitor.pop_front();
					end
					
					tmp = inMonitor.pop_front();
					command.op = data_err_op;
					command_monitor_h.write_to_monitor(command);
					
					
				end
			end
		end	: sin_monitor_loop
	end : sin_monitor
	
	
	always  begin : rst_monitor
    	sequence_item command;
		command = new("command");
    	command.op = rst_op;
		@(posedge clk);
		forever begin
			@(negedge reset_n);
        	command_monitor_h.write_to_monitor(command);	
		end
	end : rst_monitor
	
	


	result_monitor result_monitor_h;
	always begin :sout_monitor

		bit[8:0] tmp;
		result_transaction result;
		SerialMonitor outMonitor; 
		
		outMonitor = new();
		
		
		forever begin : sout_monitor_loop
			result = new();
			@(negedge clk);
			outMonitor.sample(sout, reset_n);
			
			if(outMonitor.get_lenght() >= 5) begin
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
*/


//interface kl_alu_if(clock,reset);
//
//	// Just in case you need it
//	import uvm_pkg::*;
//
//	// Clock and reset signals
//	input clock;
//	input reset;
//
//	// Flags to enable/disable assertions and coverage
//	bit checks_enable=1;
//	bit coverage_enable=1;
//
//	// TODO Declare interface signals here
//	
//	logic valid;
//	logic[7:0] data;
//
////	//You can add covergroups in interfaces
////	covergroup signal_coverage@(posedge clock);
////		//add coverpoints here
////	endgroup
////	// You must instantiate the covergroup to collect coverage
////	signal_coverage sc=new;
////
////	// You can add SV assertions in interfaces
////	my_assertion:assert property (
////			@(posedge clock) disable iff (reset === 1'b0 || !checks_enable)
////			valid |-> (data!==8'bXXXX_XXXX)
////		)
////	else
////		`uvm_error("ERR_TAG","Error")
//
//endinterface : kl_alu_if
