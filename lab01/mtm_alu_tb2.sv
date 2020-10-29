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
		op_err = 6'b001001,
		no_err = 6'b000000
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
   
   function bit [7:0] get_to_send();
	   bit[5:0] r;
	   r = $random; 
	   
	   if(r == 0) return $random;
	   else return 8'b1111_1111;
   endfunction;
   
   function bit get_bad_crc();
	   bit[5:0] r;
	   r = $random; 
	   
	   if(r == 0) return 1;
	   else return 0;
   endfunction;
   
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
endtask



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



bit[7:0] to_send; 
bit bad_crc;
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
	     to_send = get_to_send();
	      bad_crc = get_bad_crc();
	      if(bad_crc) crc = $random;
	      else crc = crc_calc({B, A, 1'b1, op_set});
	      
	     
	     $display("CRC =  %d", crc);
	      
	     
	     
	     ctl_in = {1'b0, op_set, crc};
	     //send B
	     if(to_send[7]) tx_data( {2'b00, B[31:24], 1'b1});
	     if(to_send[6]) tx_data( {2'b00, B[23:16], 1'b1});
	     if(to_send[5]) tx_data( {2'b00, B[15:8], 1'b1});
	     if(to_send[4]) tx_data( {2'b00, B[7:0], 1'b1});
         
         //send A
         if(to_send[3])	tx_data( {2'b00, A[31:24], 1'b1});
	     if(to_send[2])tx_data( {2'b00, A[23:16], 1'b1});
	     if(to_send[1])tx_data( {2'b00, A[15:8], 1'b1});
	     if(to_send[0])tx_data( {2'b00, A[7:0], 1'b1});
	     
	     //send cmd
	     tx_data( {2'b01, ctl_in, 1'b1});
         
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

bit correct;
bit [31:0] A_monitor, B_monitor, C_monitor;
//---------------------------
//Monitore mtm_Alu inputs / outputs. Capture, deserialize and push data into a queues
//---------------------------

bit s_monitor_working = 0;

class s_monitor;
	bit capturing;
	int capturing_ctr;
	bit [10:0] captured_data;
	bit[8:0] q [$];
	
	function new();
		capturing = 0;
		capturing_ctr = 0;
		captured_data = 0;
		q = {};
	endfunction;
	
	function sample(bit state);
		if((capturing == 1) | (state == 0)) begin
			s_monitor_working = !s_monitor_working;
			capturing = 1;
			captured_data[10 - capturing_ctr] = state;
			capturing_ctr++;
			if(capturing_ctr > 10) begin
				capturing_ctr = 0;
				capturing = 0;
				q.push_back(captured_data[9:1]);
			end
		end
		else begin
			capturing = 0;
			s_monitor_working = 0;
			capturing_ctr = 0;
		end
	endfunction

	function bit is_data_frame(int index);
		bit [8:0] tmp;
		if(index > q.size()) return 0;
		tmp = q[index];
		return !tmp[8];
	endfunction

	function bit is_ctl_frame(int index);
		bit [8:0] tmp;
		if(index > q.size()) return 0;
		tmp = q[index];
		return tmp[8];
	endfunction

	function bit is_ctl_frame_before_index(int index);
		//int j = (index-1 > q.size()) ? q.size() : index-1;
		int j;
		if(q.size > index) j = index;
		else j = q.size;
		
		for(int i = 0; i < j; i++)begin
			if(is_ctl_frame(i)) return 1;	
		end
		return 0;
	endfunction
	
	function bit is_first_ctl_frame_at_index(int index);
		if(is_ctl_frame(index) == 0) return 0;
		if(is_ctl_frame_before_index(index-1)) return 0;
		return 1;
	endfunction
	
	function bit is_ctl_frame_inside();
		return is_ctl_frame_before_index(q.size());
	endfunction;	
endclass



class input_data;
	bit [31:0] A;
	bit [31:0] B;
	bit [7:0] ctl;
	operation_t op;
	bit [3:0] crc;
	bit format_ok;
	bit op_ok; 
	bit crc_ok;
	
	s_monitor in_monitor = new;
	
	//function new();
	//	in_monitor = new;
	//endfunction
	
	//samples series in data and stores them in queue
	function sample();
		in_monitor.sample(sin);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();
		//if(in_monitor.q.size() >= 9) return 1;	//min 9 frames recieved
		//return in_monitor.is_ctl_frame_before_index(8);
		return in_monitor.is_ctl_frame_inside();
	endfunction
	

	function decode_data();
		bit [8:0] tmp = 0;
		format_ok = in_monitor.is_first_ctl_frame_at_index(8);
		//reads data from queue
		
		if(format_ok) begin
			for(int i = 0; i < 4; i++) begin
				tmp = in_monitor.q.pop_front();
				B[31-8*i -:8] = tmp[7:0];
			end
			
			for(int i = 0; i < 4; i++) begin
				tmp = in_monitor.q.pop_front();
				A[31-8*i -:8] = tmp[7:0];
			end
			
			tmp = in_monitor.q.pop_front();
			ctl = tmp[7:0];
		end
		else begin
			//tmp = in_monitor.q.pop_front();
			while(in_monitor.is_data_frame(0)) begin
				in_monitor.q.pop_front();
			end
			if(in_monitor.is_ctl_frame(0)) begin
				tmp = in_monitor.q.pop_front();
				ctl = tmp[7:0];
			end
			else ctl = 0;
		end
		
		handle_op();
		handle_crc();
		
	endfunction
	
	function handle_op();
		if(ctl[6:4] == 3'b000) op = and_op;
		else if(ctl[6:4] == 3'b001) op = or_op;
		else if(ctl[6:4] == 3'b100) op = add_op;
		else if(ctl[6:4] == 3'b101) op = sub_op;
		else op = rsv_op;
		op_ok = !(op == rsv_op);
	endfunction
	
	function handle_crc();
		bit [3:0] expected_crc;
		crc = ctl[3:0];
		
		expected_crc = crc_calc({B, A, 1'b1, ctl[6:4]});
		crc_ok = (expected_crc == crc);
	endfunction
endclass



class output_data;
	bit [31:0] C;
	bit [7:0] ctl;
	bit format_ok;
	flag_t flag;
	err_flag_t error_f;
	bit error;
	
	s_monitor out_monitor = new;
	//function new();
	//	out_monitor = new(m);
	//endfunction
	
	//samples series in data and stores them in queue
	function sample();
		out_monitor.sample(sout);
	endfunction
	//cheks if data are ready (ctl frame in buffor)
	function bit rdy();
		//if(in_monitor.q.size() >= 9) return 1;	//min 9 frames recieved
		//return in_monitor.is_ctl_frame_before_index(8);
		return out_monitor.is_ctl_frame_inside();
	endfunction
	

	function decode_data();
		bit [8:0] tmp = 0;
		format_ok = out_monitor.is_first_ctl_frame_at_index(4);
		//reads data from queue
		if(format_ok == 1) begin
			for(int i = 0; i < 4; i++) begin
				tmp = out_monitor.q.pop_front();
				C[31-8*i -:8] = tmp[7:0];
			end
			tmp = out_monitor.q.pop_front();
			ctl = tmp[7:0];
		end
		else begin
			//tmp = out_monitor.q.pop_front();
			while(out_monitor.is_data_frame(0)) begin
				out_monitor.q.pop_front();
			end
			if(out_monitor.is_ctl_frame(0)) begin
				tmp = out_monitor.q.pop_front();
				ctl = tmp[7:0];
			end
			else ctl = 0;
		end
		
		
		handle_error();
		handle_flag();
	endfunction
	
	function handle_error();
		error = ctl[7];
		error_f = no_err;
		if(error) begin
			if(ctl[6] == 1) error_f = data_err;
			else if(ctl[5] == 1) error_f = crc_err;
			else if(ctl[4] == 1) error_f = op_err;
			else if(ctl[3] == 1) error_f = data_err;
			else if(ctl[2] == 1) error_f = crc_err;
			else if(ctl[1] == 1) error_f = op_err;
		end
	endfunction
	
	function handle_flag();
		flag = no_f;
		if(!error) begin
			if(ctl[6] == 1) flag = carry_f;
			else if(ctl[5] == 1) flag = ovf_f;
			else if(ctl[4] == 1) flag = zero_f;
			else if(ctl[3] == 1) flag = neg_f;
			else flag = no_f;
		end
	endfunction
endclass

bit smple;
bit ins;
bit [31:0] expected;
input_data DIN = new;
output_data DOUT = new;

initial begin
   	while(1) begin
	   	smple = !smple;
	   	@(negedge clk);
	   	DIN.sample();
	    DOUT.sample();
	   	@(posedge clk);
	   	
	   	if(DIN.rdy() & DOUT.rdy()) begin
		   	ins = !ins;
		   	DIN.decode_data();
		   	DOUT.decode_data();
		   	
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
