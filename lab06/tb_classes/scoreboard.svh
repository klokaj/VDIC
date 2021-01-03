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
class scoreboard extends uvm_subscriber #(result_transaction);

    `uvm_component_utils(scoreboard)
	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
	    cmd_f = new("cmd_f", this);
    endfunction : build_phase

    function result_transaction predict_result(sequence_item cmd);
	    result_transaction predicted;
	    bit[3:0] flag;
	    predicted = new("predicted");
	    
	    if(cmd.op == data_err_op) begin
			predicted.error = 1;
		    predicted.err_flag.data = 1;
		end
		else if( cmd.op == crc_err_op) begin
			predicted.error = 1;
			predicted.err_flag.crc = 1;
		end
		else if( cmd.op == op_err_op) begin
			predicted.error = 1;
			predicted.err_flag.op = 1;
		end
		else begin
			predicted.error = 0;
			case(cmd.op)
				and_op: begin
					predicted.C = cmd.A & cmd.B;
     			end
     			or_op : begin 
         			predicted.C = cmd.A | cmd.B;
     			end
     			sub_op: begin 
	         		predicted.C = cmd.B - cmd.A;
         			if(cmd.A > cmd.B) begin 
	         			flag[3] = 1; //overflow
	         			flag[2] = ((predicted.C[31] != cmd.B[31]) & (cmd.B[31] == 1 | cmd.A[31] == 1)) ;
         			end
         			else begin
	         			flag[2] = ((predicted.C[31] != cmd.B[31]) & cmd.B[31] == 1 & cmd.A[31] == 0);
	         		end	
				end
				add_op: begin
					predicted.C = cmd.B + cmd.A;
					flag[3] = (predicted.C < cmd.B | predicted.C < cmd.A);
					flag[2] = (predicted.C[31] != cmd.B[31] &  predicted.C[31] != cmd.A[31]);
				end
			endcase
			flag[1] = (predicted.C == 0); //zero
			flag[0] = (predicted.C[31] == 1); //negative
			
			predicted.flag.carry = flag[3];
			predicted.flag.ovf = flag[2];
			predicted.flag.zero = flag[1];
			predicted.flag.neg = flag[0];
		
			predicted.crc = nextCRC3_D37({predicted.C, 1'b0, flag});	
		end	    
	    return predicted;  
    endfunction : predict_result


    function void write(result_transaction t);
	    string data_str;
	    sequence_item cmd;
	    result_transaction predicted;
	
		do begin
			if(!cmd_f.try_get(cmd))
				$fatal(1, "Missing command in self checker");
		end
		while(cmd.op == rst_op);
			
		predicted = predict_result(cmd);
		
		data_str = {"\n", cmd.convert2string(),
			" ==> Actual", t.convert2string(), 
			"Predicted", predicted.convert2string()};


		if(!predicted.compare(t))
			`uvm_error("SELF CHECKER", {"FAIL: ", data_str})
		else
			`uvm_info("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
	   

    endfunction : write
endclass : scoreboard










//
//
//
//
//
//class scoreboard;
//	virtual mtm_alu_bfm bfm; 
//	function new (virtual mtm_alu_bfm b);
//		bfm = b;
//	endfunction : new
//
//	task execute();
//		input_data DIN;
//		output_data DOUT;
//		mtm_alu_model ALU_model;
// 		DIN = new();
//		DOUT = new();
//		ALU_model = new();
//
//		forever begin: self_checker
//	   	//sample sout and sin at clock negedge
//	   		@(negedge bfm.clk);
//	   		DIN.sample(bfm.sin, bfm.reset_n);
//	    	DOUT.sample(bfm.sout, bfm.reset_n);
//		   	//check if din and dout are ready (contains a CTL frame)
//		   	if(DIN.rdy() & DOUT.rdy()) begin
//			   	//decode imput / output frames payload
//			   	DIN.decode_data();
//			    DOUT.decode_data();
//			   	//calculate expected mtm alu response for a given input data
//			   	ALU_model.calculate_response(DIN);
//			   	
//			   	//$display("A = %g, B = %g", DIN.A, DIN.B);
//			   	//Check and report an errors
//			   	if(DOUT.err == 1'b1) begin
//				   if(DOUT.err != ALU_model.err) begin
//					   $display("--------------EXP_FRAME_ERROR------------------");
//				   end
//				   else if(DOUT.err_flags != ALU_model.err_flags) begin
//				   	   $display("--------------WRONG_ERROR_FLAGS------------------");
//				   end
//			   	end
//			   	else begin 
//				   	if(DOUT.flags != ALU_model.flags) begin
//					   $display("--------------WRONG_FLAGS------------------");
//					end
//				   	
//				   	if(DOUT.C != ALU_model.res) begin
//					   $display("--------------WRONG_REULT------------------");
//					end
//			   	end
//			end  //if(DIN.rdy() & DOUT.rdy())
//		end : self_checker
//	endtask : execute
//	
//endclass : scoreboard
////
////
////module scoreboard(mtm_alu_bfm bfm);
////   	import mtm_alu_pkg::*;
////
////
////bit[31:0] error_ctr;
////bit[31:0] frame_ctr;
////
////
////initial begin
////	input_data DIN;
////	output_data DOUT;
////	mtm_alu_model ALU_model;
////
//// 	DIN = new();
////	DOUT = new();
////	ALU_model = new();
////
////
////	error_ctr = 0;
////	frame_ctr = 0;
////	
////   	while(1) begin
////	   	//sample sout and sin at clock negedge
////	   	@(negedge bfm.clk);
////	   	DIN.sample(bfm.sin, bfm.reset_n);
////	    DOUT.sample(bfm.sout, bfm.reset_n);
////
////
////	   	//check if din and dout are ready (contains a CTL frame)
////	   	if(DIN.rdy() & DOUT.rdy()) begin
////		   	
////		   	//decode imput / output frames payload
////		   	DIN.decode_data();
////		    DOUT.decode_data();
////		   	
////		   	//calculate expected mtm alu response for a given input data
////		   	ALU_model.calculate_response(DIN);
////
////
////		   	//if(frame_ctr % 100 == 0) 
////		   	//	$display(frame_ctr);
////		   	//frame_ctr++;
////		   	
////	
////		   	//Check and report an errors
////		   	if(DOUT.err == 1'b1) begin
////			   if(DOUT.err != ALU_model.err) begin
////				   $display("--------------EXP_FRAME_ERROR------------------");
////				   print_error_data(DIN, DOUT, ALU_model);
////					error_ctr++;
////			   end
////			   else if(DOUT.err_flags != ALU_model.err_flags) begin
////			   	   $display("--------------WRONG_ERROR_FLAGS------------------");
////				   print_error_data(DIN, DOUT, ALU_model);
////					error_ctr++;
////			   end
////		   	end
////		   	else begin 
////			   	if(DOUT.flags != ALU_model.flags) begin
////				   $display("--------------WRONG_FLAGS------------------");
////				   print_error_data(DIN, DOUT, ALU_model);	
////					error_ctr++;
////				end
////			   	
////			   	if(DOUT.C != ALU_model.res) begin
////				   $display("--------------WRONG_REULT------------------");
////				   print_error_data(DIN, DOUT, ALU_model);
////				   error_ctr++;
////				end
////			end
////		  
////	   	end
////   	end	
////end	
////
////
////
////
////function void print_error_data(input_data DIN, output_data DOUT, mtm_alu_model exp);
////   case (DIN.op)
////	   	and_op : $display("operation AND");
////	   	or_op : $display("operation OR");
////	   	sub_op : $display("operation SUB");
////	   	add_op : $display("operation ADD");
////	   	default : $display("operation UKN");
////   endcase
////   
////   case (DIN.format)
////   	cmd_ok: $display("CMD ok, len = %d", DIN.packet_lenght);
////	cmd_short: $display("CMD short, len = %d", DIN.packet_lenght);
////	cmd_long: $display("CMD long, len = %d", DIN.packet_lenght);   
////   endcase
////   
////   	$display("A = %d, B = %d, C = %d", DIN.A, DIN.B, DOUT.C);
////	$display("CTL = %b, CTL_exp = %b, frame %d", DOUT.ctl, exp.ctl, frame_ctr); 
////endfunction
////
////	
////	
////	
////	
////	
////	
////	
////endmodule : scoreboard
