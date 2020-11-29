`ifndef MTM_ALU_MODEL
`define MTM_ALU_MODEL



//
// Model symulowanego ALU. Na podstawie danych wejsciowych wylicza spodzeiwana odpowiedz.
//

import mtm_alu_pkg::*;

class mtm_alu_model;
	bit [31:0] res;
	bit [7:0] ctl;
	
	bit [5:0] err_flags;
	bit [3:0] flags;
	bit err;


	function void calculate_response(input_data din); 
		bit[2:0] crc_tmp;
		ctl = 0;
		
		if(din.format_ok == 0) begin
			ctl = 8'b11001001;
			//dout.push_back({1'b1, ctl})
		end
		else if(din.crc_ok == 0) begin
			ctl = 8'b10100101;
			//dout.push_back({1'b1, ctl})
		end
		else if(din.op_ok == 0) begin
			ctl = 8'b10010011;
			//dout.push_back({1'b1, ctl})
		end
		else begin
			ctl[7] = 0; //no error output
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
			
			ctl[4] = (res == 0); //zero
			ctl[3] = (res[31] == 1); //negative
		
			crc_tmp = nextCRC3_D37({res, 1'b0, ctl[6:3]});
			ctl[2:0] = crc_tmp;

		end
		
		if(ctl[7] == 0) begin
	    	err = 0;
			err_flags = 0;
			flags = ctl[6:3];
	    end
		else begin
			err = 1;
			err_flags = ctl[6:1];
			flags = 0;
		end
	endfunction
endclass	

`endif // MTM_ALU_MODEL
