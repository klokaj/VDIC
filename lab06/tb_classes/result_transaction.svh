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
class result_transaction extends uvm_transaction;
   `uvm_object_utils(result_transaction)
	bit [31:0] C;
	bit error;
	bit [2:0] crc;
		
	flags_s flag;
	err_flags_s err_flag;

   function new (string name = "");
      super.new(name);
   endfunction : new
      
   virtual function void do_copy(uvm_object rhs);
      result_transaction copied_transaction_h;

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

   virtual function result_transaction clone_me();
      result_transaction clone;
      uvm_object tmp;

      tmp = this.clone();
      $cast(clone, tmp);
      return clone;
   endfunction : clone_me
   

   virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      result_transaction RHS;
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



endclass : result_transaction

      
        