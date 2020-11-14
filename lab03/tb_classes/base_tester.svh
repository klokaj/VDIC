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
//`ifdef QUESTA
//virtual class base_tester extends uvm_component;
//`else
//`ifdef INCA
// irun requires abstract class when using virtual functions
// note: irun warns about the virtual class instantiation, this will be an
// error in future releases.
virtual class base_tester extends uvm_component;
//`else
//class base_tester extends uvm_component;
//`endif
//`endif

    `uvm_component_utils(base_tester)

    virtual mtm_alu_bfm bfm;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

    pure virtual function operation_t get_op();
    pure virtual function bit[31:0] get_data();
    pure virtual function bit [3:0] get_crc(bit [67:0] data);

   
    task run_phase(uvm_phase phase);
        bit[31:0] iA;
        bit[31:0] iB;
	    bit[3:0]  iCRC;
	    bit [7:0] q [$];
        operation_t op_set;
   

        phase.raise_objection(this);

        bfm.reset_alu();

        repeat (1000) begin : random_loop
            op_set = get_op();
            iA     = get_data();
            iB     = get_data();
            iCRC = get_crc({iB, iA, 1'b1, op_set});

	        q.delete();
	        
	        q.push_back(iB[31:24]);
	        q.push_back(iB[23:16]);
	        q.push_back(iB[15:8]);
	        q.push_back(iB[7:0]);
	        
	        q.push_back(iA[31:24]);
	        q.push_back(iA[23:16]);
	        q.push_back(iA[15:8]);
	        q.push_back(iA[7:0]);
	        
	        
	     	q.push_back({1'b0, op_set, iCRC});  
	        
	        
	        bfm.tx_packet(q);
	        
        end : random_loop

//      #500;

        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tester
