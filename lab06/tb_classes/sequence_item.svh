/*
   Copyright 2013 Ray Salemi

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
class sequence_item extends uvm_sequence_item;
   //`uvm_object_utils(sequence_item)
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand operation_t op;



	function new(string name = "sequence_item");
		super.new(name);
	endfunction : new
	
	
	// macros providing copy, compare, pack, record, print functions.
	// Individual functions can be enabled/disabled with the last
	// `uvm_field_*() macro argument.
	`uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_enum(operation_t, op, UVM_ALL_ON)
    `uvm_object_utils_end



/*
   
   virtual function void do_copy(uvm_object rhs);
      command_transaction copied_transaction_h;

      if(rhs == null) 
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")
      
      super.do_copy(rhs); // copy all parent class data

      if(!$cast(copied_transaction_h,rhs))
        `uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

      A = copied_transaction_h.A;
      B = copied_transaction_h.B;
      op = copied_transaction_h.op;


   endfunction : do_copy

   virtual function command_transaction clone_me();
      command_transaction clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      command_transaction compared_transaction_h;
      bit   same;
      
      if (rhs==null) `uvm_fatal("RANDOM TRANSACTION", 
                                "Tried to do comparison to a null pointer");
      
      if (!$cast(compared_transaction_h,rhs))
        same = 0;
      else
        same = super.do_compare(rhs, comparer) && 
               (compared_transaction_h.A == A) &&
               (compared_transaction_h.B == B) &&
               (compared_transaction_h.op == op);
               
      return same;
   endfunction : do_compare

*/
   virtual function string convert2string();
      string s;
      s = $sformatf("A: %2h  B: %2h op: %s  \n",
                        A, B, op.name());
      return s;
   endfunction : convert2string



endclass : sequence_item 

      
        