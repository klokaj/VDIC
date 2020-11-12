

module scoreboard(mtm_alu_bfm bfm);
   	import mtm_alu_pkg::*;


bit[31:0] error_ctr;
bit[31:0] frame_ctr;


initial begin
	input_data DIN;
	output_data DOUT;
	mtm_alu_model ALU_model;

 	DIN = new();
	DOUT = new();
	ALU_model = new();


	error_ctr = 0;
	frame_ctr = 0;
	
   	while(1) begin
	   	//sample sout and sin at clock negedge
	   	@(negedge bfm.clk);
	   	DIN.sample(bfm.sin, bfm.reset_n);
	    DOUT.sample(bfm.sout, bfm.reset_n);


	   	//check if din and dout are ready (contains a CTL frame)
	   	if(DIN.rdy() & DOUT.rdy()) begin
		   	
		   	//decode imput / output frames payload
		   	DIN.decode_data();
		    DOUT.decode_data();
		   	
		   	//calculate expected mtm alu response for a given input data
		   	ALU_model.calculate_response(DIN);


		   	//if(frame_ctr % 100 == 0) 
		   	//	$display(frame_ctr);
		   	//frame_ctr++;
		   	
	
		   	//Check and report an errors
		   	if(DOUT.err == 1'b1) begin
			   if(DOUT.err != ALU_model.err) begin
				   $display("--------------EXP_FRAME_ERROR------------------");
				   print_error_data(DIN, DOUT, ALU_model);
					error_ctr++;
			   end
			   else if(DOUT.err_flags != ALU_model.err_flags) begin
			   	   $display("--------------WRONG_ERROR_FLAGS------------------");
				   print_error_data(DIN, DOUT, ALU_model);
					error_ctr++;
			   end
		   	end
		   	else begin 
			   	if(DOUT.flags != ALU_model.flags) begin
				   $display("--------------WRONG_FLAGS------------------");
				   print_error_data(DIN, DOUT, ALU_model);	
					error_ctr++;
				end
			   	
			   	if(DOUT.C != ALU_model.res) begin
				   $display("--------------WRONG_REULT------------------");
				   print_error_data(DIN, DOUT, ALU_model);
				   error_ctr++;
				end
			end
		  
	   	end
   	end	
end	




function void print_error_data(input_data DIN, output_data DOUT, mtm_alu_model exp);
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
	$display("CTL = %b, CTL_exp = %b, frame %d", DOUT.ctl, exp.ctl, frame_ctr); 
endfunction

	
	
	
	
	
	
	
endmodule : scoreboard
