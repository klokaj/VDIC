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
   bit [10:0] rx, rx_shadow;
	
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

  function bit [3:0] crc_calc (input [67:0] data);

    bit [3:0] cr = 0;
    reg [67:0] d;
    reg [3:0] c;
    reg [3:0] newcrc;
  begin
    d = data;
    c = cr;

    newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
    return newcrc;
  end
  endfunction

always begin
	int i = 0;
	if(reset_n == 1) begin
		i = 0;
		@(negedge sout);

		for(i = 10; i >= 0; i--) begin
		@(negedge clk);
		rx_shadow[i] = sout;
		
		end
		new_rx = 1; 
		rx = rx_shadow;
	end
	
	if(reset_n == 0)
	begin
		@(negedge clk); 
	end
end



//------------------------
// Tester main
   initial begin : tester
	  sin = 1'b1;	
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
	     crc = crc_calc({B, A, 1'b1, op_set});
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
         
         
         //@(posedge new_rx);
	    // new_rx = 0;
         //while(rx[9] != 0) begin
        // 	@(posedge new_rx);
	    //     new_rx = 0;
	    // end
	    // done = 1;
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------


bit [10:0] sin_monitor;
bit [10:0] sout_monitor;
int sin_monitor_ctr;
int sin_capturing;
int sout_capturing;
int sout_monitor_ctr;

bit [8:0] sin_queue [$];
bit [8:0] sout_queue [$];



bit [31:0] A_monitor, B_monitor, C_monitor;
//---------------------------
//Monitore mtm_Alu inputs / outputs. Capture, deserialize and push data into a queues
//---------------------------

function dut_monitor();
	//sin monitor
	if((sin_capturing == 1) | (sin == 0)) begin
		sin_capturing = 1;
		sin_monitor[10 - sin_monitor_ctr] = sin;
		sin_monitor_ctr++;
		if(sin_monitor_ctr > 10) begin
			sin_monitor_ctr = 0;
			sin_capturing = 0;
			 sin_queue.push_back(sin_monitor[9:1]);
		end
	end
	
	//sout monitor
	if((sout_capturing == 1) | (sout == 0)) begin
		sout_capturing = 1;
		sout_monitor[10 - sout_monitor_ctr] = sout;
		sout_monitor_ctr++;
		if(sout_monitor_ctr > 10) begin
			sout_monitor_ctr = 0;
			sout_capturing = 0;
			sout_queue.push_back(sout_monitor[9:1]);
		end
	end
endfunction

function bit err_recieved();
	int size = sout_queue.size();
	int j;
	if(size == 0) return 0;
	
	
	if(size >= 4) j = 4;
	else j  = size;
	
	for(int i = 0; i < j; i++) begin
		if(sout_queue[i][8] == 1)	return 1;
	end
	
	return 0;
endfunction


int correct = 0;
function bit data_ready();
	   	if(sin_queue.size() >= 9)
		   if((sout_queue.size() >= 5) | (err_recieved()))
			   return 1;
	 return 0;	
endfunction



class input_data;
	bit [31:0] A;
	bit [31:0] B;
	int data_ok;
	bit [7:0] ctl;
	bit ctl_ok;
	int crc_ok;
	operation_t op; 
	
	function reset_data();
		data_ok = 1;
		ctl_ok = 1;
		op = rsv_op;
		A = 0;
		B = 0;
		ctl = 0;	
	endfunction

	function queue_decode();
		bit [8:0] tmp;
		int i = 0;
		reset_data();
		
		while(i < 4) begin
			tmp = sin_queue.pop_front();
			if(tmp[8] == 1) begin
				data_ok = 0;
				break;
			end
			B[31-8*i -:8] = tmp;
			i++;
		end
		
		i = 0;
		while((data_ok == 1) & (i < 4)) begin
			tmp = sin_queue.pop_front();
			if(tmp[8] == 1) begin
				data_ok = 0;
				break;
			end
			A[31-8*i -:8] = tmp;
			i++;
		end
		
		if(data_ok == 1) tmp = sin_queue.pop_front();
		
		if(tmp[8] == 1)begin
			ctl = tmp[7:0];
			if(tmp[6:4] == 3'b000) op = and_op;
			if(tmp[6:4] == 3'b001) op = or_op;
			if(tmp[6:4] == 3'b100) op = add_op;
			if(tmp[6:4] == 3'b101) op = sub_op;
		end
		else begin
			ctl_ok = 0;	
		end
		
		
		
	endfunction
	
	
endclass


class output_data; 
	bit[31:0] C;
	int data_ok;
	bit[7:0] ctl;
	int ctl_ok;
	int error;
	flag_t f;
	
	function reset_data();
		data_ok = 1;
		ctl_ok = 1;
		C = 0;
		ctl = 0;
		error = 0;
		f = no_f;
	endfunction
	
	
	function queue_decode();
		bit [8:0] tmp;
		int i = 0;
		reset_data();
		
		while(i < 4) begin
			tmp = sout_queue.pop_front();
			if(tmp[8] == 1) begin
				data_ok = 0;
				break;
			end
			C[31-8*i -:8] = tmp;
			i++;
		end
		
		if(data_ok == 1) tmp = sout_queue.pop_front();
		
		if(tmp[8] == 1)begin
			ctl = tmp[7:0];
			if(ctl[7] == 0) begin
				if(ctl[6:3]);
			end
			if(tmp[6] == 1) f = carry_f;
			else if(tmp[5] == 1) f = ovf_f;
			else if(tmp[4] == 1) f = zero_f;
			else if(tmp[3] == 1) f = neg_f;
			else f = no_f;
		end
		else begin
			ctl_ok = 0;	
		end
	
		
	endfunction	
endclass	
 
 
bit [31:0] expected;

initial begin
	
	
	input_data DIN = new;
	output_data DOUT = new;
	
	
	sin_monitor_ctr = 0;
	sout_monitor_ctr = 0;
	sin_capturing = 0;
	sout_capturing = 0;

   	while(1) begin
	   	@(negedge clk);
	   	dut_monitor();
	   	if(data_ready()) begin
		   	DIN.queue_decode();
		   	DOUT.queue_decode();
		   	
		   	A_monitor = DIN.A;
		   	B_monitor = DIN.B;
		   	C_monitor = DOUT.C;
		   	case (DIN.op)
				and_op: expected = DIN.A & DIN.B;
         		or_op : expected = DIN.A | DIN.B;
         		sub_op : expected = DIN.B - DIN.A;
         		add_op: expected = DIN.B + DIN.A;
        		default: expected = 0;				     //60-63 / p = 6,25%
      		endcase // case (op_choice)
		   	
		   	
		   	if(expected != DOUT.C) begin
			   	correct = 0;
			   	$display("ERROR ERORORORO");
		   	end
		   	else begin
			   	if(DOUT.error == 1) correct = 0;
			   	else correct = 1;
			end  	
	   	end  
	end	 
end

   
endmodule : top
