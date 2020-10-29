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
`include "mtm_alu_model.sv"

module top;

//------------------------------------------------------------------------------
// variable definitions
//------------------------------------------------------------------------------
   bit  [31:0] A;   //data in  A
   bit  [31:0] B;	// data in B
   int  payload_len; 



   bit      clk;	// mtm_Alu clock
   bit      reset_n;// mtm_Alu reset
   bit  	sin;	// mtm_Alu serial in
   wire  	sout;	// mtm_Alu serial out
   
   
  	
   integer framectr = 0;
   operation_t  op_set;
   
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
	  
         bins A2_twoops[] = ([and_op:sub_op] [* 2]);
	      
	     bins A3_rsv[] = {rsv_op}; 

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
        ignore_bins null_ops = {rsv_op};
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
   
 bit[3:0] expected_flag; 
 bit[5:0] expected_err_flag;
 bit		expected_err;
   
 covergroup flags_cov;
      option.name = "mtm alu flags cov";

      err_cov : coverpoint  expected_err {
        bins no_err = {1'b0};
      	ignore_bins err = {1'b1};
      }
      
      flags : coverpoint expected_flag {
	    wildcard bins carry = {4'b1xxx};
	    wildcard bins overflow = {4'bx1xx};
	    wildcard bins zero = {4'bxx1x};
	    wildcard bins negative = {4'bxxx1};
	    bins no_flag = {4'b0000};
	
	      
      }

      no_err_flags:  cross err_cov, flags{
         bins no_err_carry = binsof (err_cov) intersect {no_err} &&
                       (binsof (flags.carry));
         bins no_err_ovf = binsof (err_cov) intersect {no_err} &&
                       (binsof (flags.overflow));
	     bins no_err_zero = binsof (err_cov) intersect {no_err} &&
	           (binsof (flags.zero));
         bins no_err_neg = binsof (err_cov) intersect {no_err} &&
                       (binsof (flags.negative));
	     bins no_err_no_flag = binsof (err_cov) intersect {no_err} &&
                   (binsof (flags.no_flag));
      }
   endgroup


covergroup err_flags_cov;
      option.name = "mtm alu error flags cov";
	
      err_cov : coverpoint  expected_err {
        ignore_bins no_err = {1'b0};
      	bins err = {1'b1};
      }
      
      flags : coverpoint expected_err_flag {
	    wildcard bins err_data = {6'b100100};
	    wildcard bins err_crc = {6'b010010};
	    wildcard bins err_op = {6'b001001};
	    bins no_err = {6'b000000};    
      }
      
//      payload: coverpoint payload_len{
//	      
//	      
//      }
      
 
      
   endgroup




//------------------------------------------------------------------------------
// coverage block instantion
//------------------------------------------------------------------------------
   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;
   flags_cov c_flags;
   err_flags_cov c_err_flags;



   initial begin : coverage
	  input_data DIN = new;
	  mtm_alu_model ALU_model = new;
	  

      oc = new();
      c_00_FF = new();
	  c_flags = new();
	  c_err_flags = new();
	   
      forever begin : sample_cov
         @(negedge clk);
	     DIN.sample(sin, reset_n);
	      
	      
	     if(DIN.rdy()) begin
		    payload_len = DIN.packet_lenght;
		    DIN.decode_data();

		    A = DIN.A;
		    B = DIN.B;
		    op_set = DIN.op;
		    
		
		    ALU_model.calculate_response(DIN);  
		    expected_flag = ALU_model.flags;
		    expected_err_flag = ALU_model.err_flags;
		    expected_err = ALU_model.err;
    
		 	oc.sample();
         	c_00_FF.sample();
		    c_flags.sample();
		    c_err_flags.sample();     
	     end	     
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

//send frame
task tx_frame(input bit [8:0] d);
	int i;
	bit [10:0] frame; 
	
	bit[4:0] rr = $random;
	if(rr == 0) begin
		frame = {1'b0, d, 1'b0};
	end
	else begin
		frame = {1'b0, d, 1'b1};
	end
	//$display("tx_frame, %b", frame);
	for(i = 10; i >=0; i--) begin
		@(negedge clk);
		sin = frame[i];

		//$display("sin = %b", sin);
	end
	@(negedge clk); 
	@(negedge clk); 
	//@(negedge clk); 
	//@(negedge clk); 
endtask

task tx_data(input bit [7:0] d);
	//$display("Sending frame data = %b", d);
	tx_frame({1'b0, d});
endtask;

task tx_command(input bit [7:0] d);
	//$display("Sending frame command = %b", d);
	tx_frame({1'b1, d});
endtask;

//send whole packet. last element of queue is threated as an CTL command
task tx_packet(input bit [7:0] q [$]);
	bit [7:0] byte_to_send;
	bit [10:0] frame_to_send;
	
	//$display("Sending frame size = %d", q.size());
	
	while(q.size() > 1) begin
		tx_data(q.pop_front());
	end
	tx_command(q.pop_front());
	
	repeat (50) 
		 @(negedge clk);
endtask


int crc_inccorect, crc_correct;
//------------------------
// Tester main
   initial begin : tester
	  bit [9:0] DUT_reset; 
	  bit [31:0] A_in, B_in;
	  bit [3:0] crc_in;
	  bit [2:0] op_in;
	  operation_t  op_set_in;
	  bit [7:0] q [$];
   	  bit  [7:0]  ctl_in;// in control byte
   	  
	  sin = 1'b1;	
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
	  @(negedge clk);
      @(negedge clk);
	   
	  reset_n = 1'b1;
      
      repeat (1000) begin : tester_main
         @(negedge clk);
         op_set_in = get_op();
         
         get_data_(A_in, B_in, q);
	     crc_in = get_crc_(A_in, B_in, op_set_in);
	     ctl_in = {1'b0, op_set_in, crc_in};
	     q.push_back(ctl_in);    
	     tx_packet(q); 
	      
	      
	     DUT_reset = $random;
	      
	      if(DUT_reset == 0) begin
		    reset_n = 1'b0;
		    repeat(10) @(negedge clk);
	  		reset_n = 1'b1;
		    repeat(10) @(negedge clk);
	     end
      end
      
      //$display("percentage of correct crc =%f", (crc_correct*100)/(crc_correct+crc_inccorect));
      $finish;
   end : tester


//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------
bit [31:0] expected;
bit [7:0]  expected_ctl;

function print_error_data(input_data DIN, output_data DOUT, mtm_alu_model exp);
   case (DIN.op)
	   	and_op : $display("operation AND");
	   	or_op : $display("operation OR");
	   	sub_op : $display("operation SUB");
	   	add_op : $display("operation ADD");
	   	default : $display("operation UKN");
   endcase
   
   case (DIN.format)
   	cmd_ok: $display("CMD ok, len = %d", DIN.packet_lenght);
	cmd_short: $display("CMD short, len = %d", DIN.packet_lenght);
	cmd_long: $display("CMD long, len = %d", DIN.packet_lenght);   
   endcase
   
   	$display("A = %d, B = %d, C = %d", DIN.A, DIN.B, DOUT.C);
	$display("CTL = %b, CTL_exp = %b, frame %d", DOUT.ctl, exp.ctl, framectr);
   
//   	$display(" A > B = %b", DIN.A > DIN.B);
//   	$display("A[31:28] = %b", DIN.A[31:28]);
//   	$display("B[31:28] = %b", DIN.B[31:28]);
//   	$display("C[31:28] = %b", DOUT.C[31:28]);
//    $display("DOUT format: %b", DOUT.format_ok);
//    $display("DOUT format: %b", DOUT.format_ok);
//   
endfunction








initial begin
	input_data DIN = new;
	output_data DOUT = new;
	mtm_alu_model ALU_model = new;
	bit [31:0] A_monitor, B_monitor, C_monitor;
	bit[3:0] flag;
	bit [5:0] err;
	
	
   	while(1) begin
	
	   	@(negedge clk);
	   	DIN.sample(sin, reset_n);
	    DOUT.sample(sout, reset_n);
	   	
	   	//if(framectr  >=  562 && framectr <= 563) begin 
		//   	$display("sout=%b", sout);
		//end
	    // if(framectr  >=  563 && framectr <= 566) begin 
		//   $display("sout=%b", sout);
		//   end
	   

	   	
	   	
	   	if(DIN.rdy() & DOUT.rdy()) begin
//		if(framectr  >=  560 && framectr <= 566) begin 
//		   	foreach(DIN.in_monitor.q[i]) $display("DIN[i%d]=%b", i, DIN.in_monitor.q[i]);
//		end
//		
//		if(framectr  >=  560 && framectr <= 566) begin 
//		   	foreach(DOUT.out_monitor.q[i]) $display("DOUT[i%d]=%b", i, DOUT.out_monitor.q[i]);
//		end
//		   	
		   	DIN.decode_data();
		   	DOUT.decode_data();
		   	
		   	A_monitor = DIN.A;
		   	B_monitor = DIN.B;
		   	C_monitor = DOUT.C;
		   	
		 
		   	ALU_model.calculate_response(DIN);

		
		   	if(framectr % 100 == 0) 
		   		$display(framectr);
		   	framectr++;
		   	
	
		   	
		   	//$display("C = %b,", DOUT.C);


		   
		   	if(ALU_model.ctl[7] == 1) begin
			   if(ALU_model.ctl != DOUT.ctl)begin
				   $display("--------------EXP_CTL_FRAME_BAD------------------");
				   print_error_data(DIN, DOUT, ALU_model);
			   end
		   	end
		   	else begin
			   	if(ALU_model.res != DOUT.C) begin
				   	$display("--------------DATA_CTL_FRAME_OK-------------------");
				   	print_error_data(DIN, DOUT, ALU_model);
		   		end
			   	else if(ALU_model.ctl != DOUT.ctl) begin
					$display("--------------EXP_CTL_FRAME_OK-------------------");
				   	print_error_data(DIN, DOUT, ALU_model);
			   	end
		   	end
	   	end
   	end	
end
endmodule : top
