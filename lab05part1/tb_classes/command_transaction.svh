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
class command_transaction extends uvm_transaction;
   `uvm_object_utils(command_transaction)
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand operation_t op;
	rand bit [3:0] crc; 

   constraint data { A dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};
                     B dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1}; 			
   }
   //constraint operation {
	//   op dist{and_op := 10, or_op := 10, sub_op := 10, add_op := 10, rsv_op := 1, rst_op := 1};
   //}
   
   
   //constraint crc_sum {
	//   crc dist{nextCRC4_D68({A, B, 1'b1, op}):=99, [4'b0000 : 4'b1111]:= 1};
   //}
   
   //constraint crc_sum{
//	   crc <= nextCRC4_D68({B, A, 1'b1, op});
//   }
   
   
   

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
      crc = copied_transaction_h.crc;

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
               (compared_transaction_h.op == op) && 
               (compared_transaction_h.crc == crc);
               
      return same;
   endfunction : do_compare


   virtual function string convert2string();
      string s;
      s = $sformatf("A: %2h  B: %2h op: %s  crc:%b \n",
                        A, B, op.name(), crc );
      return s;
   endfunction : convert2string

   function new (string name = "");
      super.new(name);
   endfunction : new

endclass : command_transaction

      
        