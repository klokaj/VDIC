/******************************************************************************
* DVT CODE TEMPLATE: interface
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

//------------------------------------------------------------------------------
//
// INTERFACE: kl_alu_if
//
//------------------------------------------------------------------------------

// Just in case you need them
`include "uvm_macros.svh"

interface kl_alu_if(clock,reset);

	// Just in case you need it
	import uvm_pkg::*;

	// Clock and reset signals
	input clock;
	input reset;

	// Flags to enable/disable assertions and coverage
	bit checks_enable=1;
	bit coverage_enable=1;

	// TODO Declare interface signals here
	
	logic valid;
	logic[7:0] data;

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
