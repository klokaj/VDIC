/******************************************************************************
* DVT CODE TEMPLATE: sequence item
* Created by klokaj on Jan 24, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_result_item
`define IFNDEF_GUARD_kl_alu_result_item

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_result_item
//
//------------------------------------------------------------------------------

class  kl_alu_result_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;

	bit [31:0] C;
	bit error;
	bit [2:0] crc;
		
	flags_s flag;
	err_flags_s err_flag;

	// TODO it is a good practice to define a c_default_values_*
	// constraint for each field in which you constrain the field to some
	// default value or range. You can disable these constraints using
	// set_constraint_mode() before you call the randomize() function
//	constraint c_default_values_data {
//		m_data inside {[1:10]};
//	}

	function new (string name = "kl_alu_result_item");
		super.new(name);
	endfunction : new

	`uvm_object_utils_begin(kl_alu_result_item)
        `uvm_field_int(C, UVM_ALL_ON)
        `uvm_field_int(error, UVM_ALL_ON)
        `uvm_field_int(crc, UVM_ALL_ON)
 //       `uvm_field_enum(flags_s, flag, UVM_ALL_ON)
 //       `uvm_field_enum(err_flags_s, err_flag, UVM_ALL_ON)
    `uvm_object_utils_end

virtual function void do_copy(uvm_object rhs);
      kl_alu_result_item copied_transaction_h;

      if(rhs == null) 
        $fatal(1, "Tried to copy null transaction");
      
      super.do_copy(rhs); // copy all parent class data

      if(!$cast(copied_transaction_h,rhs))
        $fatal(1, "Failed cast in do_copy");

      C = copied_transaction_h.C;
      error = copied_transaction_h.error;
      crc = copied_transaction_h.crc;
      flag = copied_transaction_h.flag;
      err_flag = copied_transaction_h.flag;

   endfunction : do_copy

   virtual function kl_alu_result_item clone_me();
      kl_alu_result_item clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      kl_alu_result_item RHS;
      bit   same;
	   
	   
	  assert (rhs != null) else 
	  	$fatal(1, "Tried to compare null transaction");
	  
	  same = super.do_compare(rhs, comparer);
	  $cast(RHS, rhs);
	  
	  same = ( error == RHS.error ) && same;
	  same = (C == RHS.C) && same;
	  same = (crc == RHS.crc) && same;
	  same = (err_flag == RHS.err_flag) && same;
	  same = (flag == RHS.flag) && same;
	  
      return same;
   endfunction : do_compare


   virtual function string convert2string();
      string s;
      s = $sformatf("C: %D  error:%b f:%b: err_f:%b  crc%b \n",
                        C, error, flag, err_flag, crc );
      return s;
   endfunction : convert2string


//	function new (string name = "kl_alu_item");
//		super.new(name);
//	endfunction : new
//
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

endclass :  kl_alu_result_item



      
   



`endif // IFNDEF_GUARD_kl_alu_item
