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
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

  // typedef enum bit[2:0] {no_op  = 3'b000,
  //                        add_op = 3'b001, 
  //                        and_op = 3'b010,
  //                        xor_op = 3'b011,
  //                        mul_op = 3'b100,
  //                        rst_op = 3'b111} operation_t;
   
   
    typedef enum bit[2:0] {and_op  = 3'b000,
                          or_op = 3'b001, 
                          add_op = 3'b100,
                          sub_op = 3'b101,
                          rsv_op = 3'b111
    } operation_t;
	
	typedef enum bit[3:0] {
		no_f = 4'b0000,
		carry_f = 4'b0001,
		ovf_f = 4'b0010,
		zero_f = 4'b0100,
		neg_f = 4'b1000
	} flag_t;
	
	typedef enum bit[5:0] {
		data_err = 6'b100100,
		crc_err = 6'b010010,
		op_err = 6'b001001
	} err_flag_t;
	
					
   
   bit  [31:0] A;  //data in  A
   bit  [31:0] B;	// data in B
   bit  [7:0]  ctl_in;// in control byte
   
   bit [31:0]  C;  // Data out
   bit [7:0]   ctl_out; // control out byte 
   
   
   bit      clk;	// mtm_Alu clock
   bit      reset_n;// mtm_Alu reset
   bit  	sin;	// mtm_Alu serial in
   wire  	sout;	// mtm_Alu serial out
   
   bit done;
   bit [3:0] crc;
   wire [2:0]   op;
   bit new_rx;
   bit [10:0] rx;
	
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

   function operation_t get_op();
      bit [5:0] op_choice;
      op_choice = $random;
	   
 
      case (op_choice) inside
        [6'b000000 : 6'b001110] : return and_op; //0-14  / p = 23,43%
        [6'b001111 : 6'b011101] : return or_op;  //15-29 / p = 23,43%
        [6'b011110 : 6'b101100] : return sub_op; //30-44 / p = 23,43%
        [6'b101101 : 6'b111011] : return add_op; //45-59 / p = 23,43%
        default: return rsv_op;				     //60-63 / p = 6,25%
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function bit [31:0] get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00_00_00_00;
      else if (zero_ones == 2'b11)
        return 32'hFF_FF_FF_FF;
      else
        return $random;
   endfunction : get_data

//---------------------------------
// CRC calc function
	function bit[3:0] get_tx_crc(input bit[67:0] data);
		int i = 70;
		bit [3:0] poly = 4'b1011;
		
		bit[70:0] crc_tmp = {data, 3'b000};
		
		while(i >= 3) begin
			crc_tmp[i -: 3] = crc_tmp[i -:3] / poly;
			i -= 1;
		end
		
		return crc_tmp[3:0];
	endfunction


task tx_data(input bit[10:0] data);
	int i = 11;               
	for(i = 10; i >=0; i--) begin
		@(negedge clk);
		sin = data[i];
	end
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
	@(negedge clk); 
endtask


/*task rx_data(output bit[10:0] rx);
	int i = 10;
	bit[10:0] rx;
	@(negedge sout)
	for(i = 8; i >=0; i--) begin
		@(negedge clk);
		rx[i] = sout;
	end
	@(negedge clk); 
	
endtask
*/

always begin
	int i = 0;
	if(!reset_n) begin
		i = 0;
		@(negedge sout);
		for(i = 10; i >=0; i--) begin
			@(negedge clk);
			rx[i] = sout;
		end
		new_rx = 1; //rise flag
	end
	else begin
		rx = 11'b00000000000;
		new_rx = 0;
		@(negedge clk); 
	end
end



initial begin
	sin = 1'b1;	
end

//------------------------
// Tester main
   initial begin : tester
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
	  reset_n = 1'b1;
      
      repeat (1000) begin : tester_main
         @(negedge clk);
	      done = 0;
         op_set = get_op();
         A = get_data();
         B = get_data();
	     A = 32'hFF00FF00;
	     crc = get_tx_crc({B, A, 1'b1, op_set});
	     $display("CRC =  %d", crc);

	      
	      
	     ctl_in = {1'b0, op_set, crc};
	     //send B
         tx_data( {2'b00, B[31:24], 1'b1});
	     tx_data( {2'b00, B[23:16], 1'b1});
	     tx_data( {2'b00, B[15:8], 1'b1});
	     tx_data( {2'b00, B[7:0], 1'b1});
         
         //send A
         tx_data( {2'b00, A[31:24], 1'b1});
	     tx_data( {2'b00, A[23:16], 1'b1});
	     tx_data( {2'b00, A[15:8], 1'b1});
	     tx_data( {2'b00, A[7:0], 1'b1});
	     
	     //send cmd
	     tx_data( {2'b01, ctl_in, 1'b1});
         
         
         @(negedge new_rx);
	     new_rx = 0;
	     C[31:24] = rx[8:1];
         @(negedge new_rx);
	     new_rx = 0;
	     C[23:16] = rx[8:1];
         
         @(negedge new_rx);
	     new_rx = 0;
	     C[15:8] = rx[8:1];
         
         @(negedge new_rx);
	     new_rx = 0;
	     C[7:0] = rx[8:1];
	     
	     @(negedge new_rx);
	     new_rx = 0;
	     ctl_out[7:0] = rx[8:1];
	      done = 1;
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   always @(posedge done) begin : scoreboard
      int predicted_result;
      #1;
      case (op_set)
        and_op: predicted_result = A & B;
        or_op : predicted_result = A | B;
        sub_op: predicted_result = A - B;
        add_op: predicted_result = A + B;
      endcase // case (op_set)

      //if ((op_set != no_op) && (op_set != rst_op))
        if (predicted_result != C)
          $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, op_set.name(), C);

   end : scoreboard
   
endmodule : top
