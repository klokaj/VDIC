/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_seq_lib
`define IFNDEF_GUARD_kl_alu_seq_lib

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_base_sequence
//
//------------------------------------------------------------------------------

virtual class kl_alu_base_sequence extends uvm_sequence#(kl_alu_item);
	
	`uvm_declare_p_sequencer(kl_alu_sequencer)

	function new(string name="kl_alu_base_sequence");
		super.new(name);
	endfunction : new

	virtual task pre_body();
		uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s pre_body() raising %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.raise_objection(this);
		end
	endtask : pre_body

	virtual task post_body();
		uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s post_body() dropping %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.drop_objection(this);
		end
	endtask : post_body

endclass : kl_alu_base_sequence

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_example_sequence
//
//------------------------------------------------------------------------------

class kl_alu_example_sequence extends kl_alu_base_sequence;

	// Add local random fields and constraints here

	`uvm_object_utils(kl_alu_example_sequence)

	function new(string name="kl_alu_example_sequence");
		super.new(name);
	endfunction : new

	virtual task body();
		`uvm_do_with(req,
			{ /* TODO add constraints here*/ } )
		get_response(rsp);
	endtask : body

endclass : kl_alu_example_sequence

`endif // IFNDEF_GUARD_kl_alu_seq_lib
