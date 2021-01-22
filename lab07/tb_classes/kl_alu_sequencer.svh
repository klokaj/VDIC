/******************************************************************************
* DVT CODE TEMPLATE: sequencer
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_sequencer
`define IFNDEF_GUARD_kl_alu_sequencer

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_sequencer
//
//------------------------------------------------------------------------------

class kl_alu_sequencer extends uvm_sequencer #(kl_alu_item);
	
	`uvm_component_utils(kl_alu_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : kl_alu_sequencer

`endif // IFNDEF_GUARD_kl_alu_sequencer
