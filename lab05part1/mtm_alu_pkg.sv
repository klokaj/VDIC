`ifndef MTM_ALU_PKG
`define MTM_ALU_PKG

package mtm_alu_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	typedef enum bit[2:0] {
		and_op  = 3'b000,
    	or_op = 3'b001, 
     	add_op = 3'b100,
       	sub_op = 3'b101,
       	
       	op_err_op = 3'b011,
       	crc_err_op = 3'b110,
       	data_err_op = 3'b010,
       	
     	rst_op = 3'b111
    } operation_t;
	

	

	
	
	
	typedef struct packed {
		bit carry;
		bit ovf;
		bit zero;
		bit neg;
	} flags_s;
	
	typedef struct packed {
		bit data;
		bit crc;
		bit op;
	} err_flags_s;
	
	
	typedef struct packed{
		bit [31:0] C;
		bit error;
		bit [2:0] crc;
		
		flags_s flag;
		err_flags_s err_flag;
		
	} result_s;




class SerialMonitor;
	bit capturing;
	int capturing_ctr;
	bit [10:0] captured_data;
	bit[8:0] q [$];
	
	function new();
		capturing = 0;
		capturing_ctr = 0;
		captured_data = 0;
		q = {};
	endfunction
	
	function void sample(bit state, bit rst_n);
		if((capturing == 1) | (state == 0)) begin
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
			capturing_ctr = 0;
		end
		
		if(rst_n == 0) begin
			capturing = 0;
			q.delete();
			capturing_ctr = 0;
			captured_data = 0;
		end
	endfunction


	function bit is_data_frame(int index);
		bit [8:0] tmp;
		if(index > q.size()) return 0;
		tmp = q[index];
		return !tmp[8];
	endfunction

	function int get_lenght();
		return q.size();
	endfunction
	
	function bit[8:0] pop_front();
		return q.pop_front();
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
	endfunction
endclass


function [2:0] nextCRC3_D37( bit[37:0] Data);
    reg [2:0] crc;
    reg [36:0] d;
    reg [2:0] c;
    reg [2:0] newcrc;
  	begin
    d = Data;
    crc = 3'b000;
    c = crc;

    newcrc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
    newcrc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
    newcrc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
    return newcrc;
  end
  endfunction


function [3:0] nextCRC4_D68;
       input [67:0] Data;
       reg [67:0] d;
       reg [3:0] c;
       reg [3:0] newcrc;
     begin
       d = Data;
       c = 4'b0000;
       newcrc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
       newcrc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
       newcrc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
       newcrc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
       nextCRC4_D68 = newcrc;
     end
     endfunction




`include "command_transaction.svh"
`include "add_transaction.svh"
`include "minmax_transaction.svh"
`include "result_transaction.svh"
`include "coverage.svh"
`include "tester.svh"
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"

`include "env.svh"

`include "random_test.svh"
`include "minmax_test.svh"
//`include "add_test.svh"







endpackage : mtm_alu_pkg


`endif //MTM_ALU_PKG