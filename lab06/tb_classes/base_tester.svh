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
/*virtual class base_tester extends uvm_component;
    `uvm_component_utils(base_tester)

	uvm_put_port #(command_s) command_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
	    command_port = new("command_port", this);
    endfunction : build_phase

    pure virtual function operation_t get_op();
    pure virtual function bit[31:0] get_data();
    pure virtual function bit [3:0] get_crc(bit [67:0] data);
 
    task run_phase(uvm_phase phase);
	    command_s command;
	    
        phase.raise_objection(this);
	    
	    command.op = rst_op;
	    command_port.put(command);
        repeat (5000) begin : random_loop
	        command.op = get_op();
	        command.A = get_data();
	        command.B = get_data();
	        command.crc = get_crc({command.B, command.A, 1'b1, command.op});
	        
	        command_port.put(command);	        
	        
        end : random_loop
        #500;
        phase.drop_objection(this);

    endtask : run_phase


endclass : base_tester


//	        q.delete();
//	        
//	        q.push_back(iB[31:24]);
//	        q.push_back(iB[23:16]);
//	        q.push_back(iB[15:8]);
//	        q.push_back(iB[7:0]);
//	        
//	        q.push_back(iA[31:24]);
//	        q.push_back(iA[23:16]);
//	        q.push_back(iA[15:8]);
//	        q.push_back(iA[7:0]);
//	        //$display("*****TX*****");
//	        //$display("A:%d B:%d ctl:%b", iA, iB, 1'b0, op_set, iCRC);
//	        
//	        
//	        //if(get_del_data_q) q.delete();
//
//	     	q.push_back({1'b0, op_set, iCRC});  
//	       
//	        bfm.tx_packet(q);
//	        
//	        //if(get_reset()) bfm.reset_alu();
*/