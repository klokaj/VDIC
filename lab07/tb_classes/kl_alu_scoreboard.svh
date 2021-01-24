/******************************************************************************
* DVT CODE TEMPLATE: 
* Created by klokaj on Jan 24, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/
`ifndef IFNDEF_GUARD_kl_alu_scoreboard
`define IFNDEF_GUARD_kl_alu_scoreboard
//------------------------------------------------------------------------------
//
// CLASS: kl_alu_scoreboard
//
//------------------------------------------------------------------------------


class kl_alu_scoreboard extends uvm_subscriber #(kl_alu_result_item);

    `uvm_component_utils(kl_alu_scoreboard)
	uvm_tlm_analysis_fifo #(kl_alu_item) cmd_f;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
	    cmd_f = new("cmd_f", this);
    endfunction : build_phase

    function kl_alu_result_item predict_result(kl_alu_item cmd);
	    kl_alu_result_item predicted;
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


    function void write(kl_alu_result_item t);
	    string data_str;
	    kl_alu_item cmd;
	    kl_alu_result_item predicted;
	
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
endclass : kl_alu_scoreboard




`endif // `define IFNDEF_GUARD_kl_alu_scoreboard

