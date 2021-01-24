/******************************************************************************
* DVT CODE TEMPLATE: testbench top module
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/
`timescale 1ns/1ps;

module alu_tb_top;

	// Import the UVM package
	import uvm_pkg::*;
	// Import the UVC that we have implemented
	import kl_alu_pkg::*;

	// Import all the needed packages
	

	// Clock and reset signals
	reg clock;
	reg reset;

	// The interface
	kl_alu_if    	vif(clock, reset); 
	

	// add other interfaces if needed

	// TODO instantiate the DUT

	mtm_Alu DUT( .clk(vif.clk), .rst_n(vif.reset_n), .sin(vif.sin), .sout(vif.sout));

	initial begin
		$display("Check if create a driver");
		// Propagate the interface to all the components that need it
		uvm_config_db#(virtual kl_alu_if)::set(uvm_root::get(), "*", "m_kl_alu_vif", vif);
		// Start the test
		run_test();
	end

	// Generate clock
	always
		#5 clock=~clock;

	// Generate reset
	initial begin
		reset <= 1'b1;
		clock <= 1'b1;
		#21 reset <= 1'b0;
		#51 reset <= 1'b1;
	end
endmodule

//
//
//module top;
//	
//import uvm_pkg::*;
//import kl_alu_pkg::*;		
//	
//`include "uvm_macros.svh"
//
//
//kl_alu_if    	vif(); 
//mtm_Alu DUT( .clk(vif.clk), .rst_n(vif.reset_n), .sin(vif.sin), .sout(vif.sout));
// 
//
//
//initial begin
////		// Propagate the interface to all the components that need it
//		uvm_config_db#(virtual kl_alu_if)::set(uvm_root::get(), "*", "m_kl_alu_vif", vif);
////		// Start the test
//		run_test();
//end
//
//endmodule : top




//module alu_tb_top;
//
//	// Import the UVM package
//	import uvm_pkg::*;
//	// Import the UVC that we have implemented
//	import kl_alu_pkg::*;
//
//	// Import all the needed packages
//	
//
//	// Clock and reset signals
//	reg clock;
//	reg reset;
//
//	// The interface
//	kl_alu_if vif(clock,reset);
//
//	// add other interfaces if needed
//
//	// TODO instantiate the DUT
//	dummy_dut dut(
//		clock,
//		reset,
//		vif.valid,
//		vif.data
//	);
//
//	initial begin
//		// Propagate the interface to all the components that need it
//		uvm_config_db#(virtual kl_alu_if)::set(uvm_root::get(), "*", "m_kl_alu_vif", vif);
//		// Start the test
//		run_test();
//	end
//
//	// Generate clock
//	always
//		#5 clock=~clock;
//
//	// Generate reset
//	initial begin
//		reset <= 1'b1;
//		clock <= 1'b1;
//		#21 reset <= 1'b0;
//		#51 reset <= 1'b1;
//	end
//endmodule


