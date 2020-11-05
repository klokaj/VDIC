



module tester(mtm_alu_bfm bfm);
   	import mtm_alu_pkg::*;
	
	
	
	
	
initial begin : tester 
  	bit [31:0] A_in, B_in;
  	bit [3:0] crc_in;
  	operation_t  op_set_in;
  	bit [7:0] q [$];
  	
  	bfm.reset_alu();

  	repeat (10000) begin : tester_main
     	@(negedge bfm.clk);
	  	
	  	//prepare data to transmitt
     	op_set_in = get_op();
     	get_data_(A_in, B_in, q);
     	crc_in = get_crc_(A_in, B_in, op_set_in);
     	q.push_back({1'b0, op_set_in, crc_in});   
	  	
	  	
	  	//transmitt data
     	bfm.tx_packet(q);
	     	
	    //0.1% chance to reset alu	
      	if($urandom_range(1000, 0) == 0) begin
			bfm.reset_alu();
      	end
      
  	end
  	$finish;
end : tester
	
endmodule : tester
