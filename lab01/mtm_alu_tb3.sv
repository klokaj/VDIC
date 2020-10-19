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

`include "data_types.sv"
`include "input_decoder.sv"
`include "output_decoder.sv"
`include "crc_calc.sv"
`include "coverage_block.sv"
`include "random_data_gen.sv"


module top;

//------------------------------------------------------------------------------
// variable definitions
//------------------------------------------------------------------------------
   bit  [31:0] A;  //data in  A
   bit  [31:0] B;	// data in B

   bit      clk;	// mtm_Alu clock
   bit      reset_n;// mtm_Alu reset
   bit  	sin;	// mtm_Alu serial in
   wire  	sout;	// mtm_Alu serial out
   
   wire [2:0]   op;
   bit [3:0] crc;	
   integer framectr = 0;
   operation_t  op_set;
   assign op = op_set;
   

   

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
   mtm_Alu DUT( .clk, .rst_n(reset_n), .sin, .sout);
 
//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------
   covergroup op_cov;
      option.name = "cg_op_cov";
      coverpoint op_set {
         // #A1 test all operations
         bins A1_single_cycle[] = {[and_op : sub_op]};

	     // #A2 test all 
	     //bins A2_op_aft_and[] = {and_op => [or_op:sub_op]};
	      
	     // #A2 test all 
	     //bins A3_op_aft_or[] = {or_op => and_op, [add_op:sub_op]};	   
	    	     // #A2 test all 
	    // bins A4_op_aft_sub[] = {sub_op => [and_op:or_op], add_op};
	      
	      	     // #A2 test all 
	    // bins A5_op_aft_add[] = {add_op => [and_op:sub_op]};	
         // #A6 two operations in row
         bins A6_twoops[] = ([and_op:sub_op] [* 2]);

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
        //ignore_bins null_ops = {rst_op, no_op};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00_00_00_00};
         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
         bins ones  = {'hFF_FF_FF_FF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00_00_00_00};
         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
         bins ones  = {'hFF_FF_FF_FF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         //bins B2_mul_max = binsof (all_ops) intersect {mul_op} &&
         //               (binsof (a_leg.ones) && binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup




//------------------------------------------------------------------------------
// coverage block instantion
//------------------------------------------------------------------------------
   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

task tx_frame(input bit [8:0] d);
	int i;
	bit [10:0] frame; 
	frame = {1'b0, d, 1'b1};
	//$display("frame, %b", frame);
	for(i = 10; i >=0; i--) begin
		@(negedge clk);
		
		sin = frame[i];
	end
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
endtask

task tx_data(input bit [7:0] d);
	tx_frame({1'b0, d});
endtask;

task tx_command(input bit [7:0] d);
	tx_frame({1'b1, d});
endtask;

 
task tx_packet(input bit [7:0] q [$]);
	bit [7:0] byte_to_send;
	bit [10:0] frame_to_send;
	
	while(q.size() > 1) begin
		tx_data(q.pop_front());
	end
	tx_command(q.pop_front());
	
	repeat (50) 
		 @(negedge clk);
		 
endtask

//------------------------
// Tester main
   initial begin : tester
	  bit [7:0] q [$];
   	  bit  [7:0]  ctl_in;// in control byte
	  sin = 1'b1;	
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
	  reset_n = 1'b1;
      
      repeat (10000) begin : tester_main
         @(negedge clk);
         op_set = get_op();
         
         get_data_(A, B, q);
	     crc = get_crc_(B, A, op_set);
	     ctl_in = {1'b0, op_set, crc};
	     q.push_back(ctl_in);
	     tx_packet(q);   
      end
      $finish;
   end : tester


//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

//---------------------------
//Monitore mtm_Alu inputs / outputs. Capture, deserialize and push data into a queues
//---------------------------


bit [31:0] expected;
bit [7:0]  expected_ctl;


class expected_result;
	input_data din; 
	bit [31:0] res;
	bit [7:0] ctl;
	function new(input_data d);
		din = d;
	endfunction


	function calc_expected(); 
		bit[2:0] crc_tmp;
		ctl = 0;
		
		if(din.format_ok == 0) begin
			ctl = 8'b11001001;
		end
		else if(din.crc_ok == 0) begin
			ctl = 8'b10100101;
		end
		else if(din.op_ok == 0) begin
			ctl = 8'b10010011;
		end
		else begin 
			ctl[7] = 0;
			case(din.op)
					and_op: begin
						res = din.A & din.B;
         			end
         			or_op : begin 
	         			res = din.A | din.B;
         			end
         			sub_op: begin 
		         		res = din.B - din.A;
	         			if(din.A > din.B) begin 
		         			ctl[6] = 1; //overflow
		         			ctl[5] = ((res[31] != din.B[31]) & (din.B[31] == 1 | din.A[31] == 1)) ;
	         			end
	         			else begin
		         			ctl[5] = ((res[31] != din.B[31]) & din.B[31] == 1 & din.A[31] == 0);
		         		end
	         	
	         			
					end
					add_op: begin
						res = din.B + din.A;
						ctl[6] = (res < din.B | res < din.A);
						ctl[5] = (res[31] != din.B[31] &  res[31] != din.A[31]);
					end
			endcase
			
			if(res == 0) ctl[4] = 1;
			if(res[31] == 1) ctl[3] = 1;
			crc_tmp = nextCRC3_D37({res, 1'b0, ctl[6:3]});
			ctl[2:0] = crc_tmp;
		end
	endfunction
endclass	


function print_error_data(input_data DIN, output_data DOUT, expected_result exp);
   case (DIN.op)
	   	and_op : $display("operation AND");
	   	or_op : $display("operation OR");
	   	sub_op : $display("operation SUB");
	   	add_op : $display("operation ADD");
	   	default : $display("operation UKN");
   	endcase
   	$display("A = %d, B = %d, C = %d", DIN.A, DIN.B, DOUT.C);
	$display("CTL = %b, CTL_exp = %b, frame %d", DOUT.ctl, exp.ctl, framectr);
   	$display(" A > B = %b", DIN.A > DIN.B);
   	$display("A[31:28] = %b", DIN.A[31:28]);
   	$display("B[31:28] = %b", DIN.B[31:28]);
   	$display("C[31:28] = %b", DOUT.C[31:28]);
endfunction


initial begin
	input_data DIN = new;
	output_data DOUT = new;
	bit [31:0] A_monitor, B_monitor, C_monitor;
	bit[3:0] flag;
	bit [5:0] err;
	expected_result exp = new(DIN);
	
   	while(1) begin
	
	   	@(negedge clk);
	   	DIN.sample(sin);
	    DOUT.sample(sout);
	   	@(posedge clk);
	   	
	   	if(DIN.rdy() & DOUT.rdy()) begin
		   	DIN.decode_data();
		   	DOUT.decode_data();
		   	
		   	A_monitor = DIN.A;
		   	B_monitor = DIN.B;
		   	C_monitor = DOUT.C;
		   	
		 
		   	exp.calc_expected();

		
		   	if(framectr % 100 == 0) 
		   		$display(framectr);
		   	framectr++;
		   	if(exp.ctl[7] == 1) begin
			   if(exp.ctl != DOUT.ctl)begin
				   $display("--------------EXP_CTL_FRAME_BAD------------------");
			   end
		   	end
		   	else begin
			   	if(exp.res != DOUT.C) begin
				   	$display("--------------DATA_CTL_FRAME_OK-------------------");
				   	print_error_data(DIN, DOUT, exp);
		   		end
			   	else if(exp.ctl != DOUT.ctl) begin
					$display("--------------EXP_CTL_FRAME_OK-------------------");
				   	print_error_data(DIN, DOUT, exp);
			   	end
		   	end
	   	end
   	end	
end
endmodule : top
