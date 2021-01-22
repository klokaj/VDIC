/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

package kl_alu_pkg;

	

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	// Configuration object
	`include "kl_alu_config_obj.svh"
	// Sequence item
	`include "kl_alu_item.svh"
	// Monitor
	`include "kl_alu_monitor.svh"
	// Coverage Collector
	`include "kl_alu_coverage_collector.svh"
	// Driver
	`include "kl_alu_driver.svh"
	// Sequencer
	`include "kl_alu_sequencer.svh"
	// Agent
	`include "kl_alu_agent.svh"
	// Environment
	`include "kl_alu_env.svh"
	// Sequence library
	`include "kl_alu_seq_lib.svh"
	
	// Tests
	`include "kl_alu_base_test.svh"
	`include "kl_alu_example_test.svh"

endpackage : kl_alu_pkg
