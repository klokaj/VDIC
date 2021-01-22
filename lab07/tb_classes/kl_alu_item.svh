/******************************************************************************
* DVT CODE TEMPLATE: sequence item
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_item
`define IFNDEF_GUARD_kl_alu_item

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_item
//
//------------------------------------------------------------------------------

class  kl_alu_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;

	// TODO Declare fields here
	

	rand int m_data;

	// it is a good practice to define a c_default_values_*
	// constraint for each field in which you constrain the field to some
	// default value or range. You can disable these constraints using
	// set_constraint_mode() before you call the randomize() function
	constraint c_default_values_data {
		m_data inside {[1:10]};
	}

	`uvm_object_utils_begin(kl_alu_item)
		`uvm_field_int(m_data, UVM_DEFAULT)
	`uvm_object_utils_end

	function new (string name = "kl_alu_item");
		super.new(name);
	endfunction : new

//	// HINT UVM field macros don't work with unions and structs, you may have to override kl_alu_item.do_copy().
//	virtual function void do_copy(uvm_object rhs);
//		super.do_copy(rhs);
//	endfunction : do_copy
//
//	// HINT UVM field macros don't work with unions and structs, you may have to override kl_alu_item.do_pack().
//	virtual function void do_pack(uvm_packer packer);
//		super.do_pack(packer);
//	endfunction : do_pack
//
//	// HINT UVM field macros don't work with unions and structs, you may have to override kl_alu_item.do_unpack().
//	virtual function void do_unpack(uvm_packer packer);
//		super.do_unpack(packer);
//	endfunction : do_unpack
//
//	// HINT UVM field macros don't work with unions and structs, you may have to override kl_alu_item.do_print().
//	virtual function void do_print(uvm_printer printer);
//		super.do_print(printer);
//	endfunction : do_print

endclass :  kl_alu_item

`endif // IFNDEF_GUARD_kl_alu_item
