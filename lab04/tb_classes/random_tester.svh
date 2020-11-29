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
class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function bit[31:0] get_data();
      	bit [8:0] zero_ones;
      	zero_ones = $random; 
      	if (zero_ones == 8'b00000000)
        	return 32'h00_00_00_00;
      	else if (zero_ones == 8'b11111111)
        	return 32'hFF_FF_FF_FF;
      	else
        	return $random;
    endfunction : get_data

    function operation_t get_op();
      	bit [5:0] op_choice;
	  
      	op_choice = $random;
      	case (op_choice) inside
        	[6'b000000 : 6'b001110] : return and_op; //0-14  / p = 23,43%
        	[6'b001111 : 6'b011101] : return or_op;  //15-29 / p = 23,43%
        	[6'b011110 : 6'b101100] : return sub_op; //30-44 / p = 23,43%
        	[6'b101101 : 6'b111011] : return add_op; //45-59 / p = 23,43%
        	default: return rsv_op;//$random;				     //60-63 / p = 6,25%
      	endcase // case (op_choice)
    endfunction : get_op
    
    
    function bit[3:0] get_crc(bit [67:0] data);
		bit [3:0] crc;            

	    if($urandom_range(250, 0) != 0) crc = nextCRC4_D68(data);
	    else crc = $random;
  
	   	return crc; 
    endfunction : get_crc
    
    


endclass : random_tester






