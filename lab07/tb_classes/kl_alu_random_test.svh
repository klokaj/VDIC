/******************************************************************************
* DVT CODE TEMPLATE: example test
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_random_test
`define IFNDEF_GUARD_kl_alu_random_test

class  kl_alu_random_test extends kl_alu_base_test;

	`uvm_component_utils(kl_alu_random_test)

	function new(string name = "kl_alu_random_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_db#(uvm_object_wrapper)::set(this,
			"m_env.m_kl_alu_agent.m_sequencer.run_phase",
			"default_sequence",
			kl_alu_random_sequence::type_id::get());

       	// Create the env
		super.build_phase(phase);
	endfunction

endclass

//// Define the default sequence
//class default_sequence_class extends kl_alu_base_sequence;
//
//	// Declare fields for this sequence
//	
//
//	`uvm_object_utils(default_sequence_class)
//
//	function new(string name = "default_sequence_class");
//		super.new(name);
//	endfunction : new
//
//	virtual task body();
//		// implement sequence body
//	endtask : body
//
//endclass : default_sequence_class

`endif // IFNDEF_GUARD_kl_alu_example_test
