



module mtm_alu_tester_module(mtm_alu_bfm bfm);
   	import mtm_alu_pkg::*;
	
	


  function operation_t get_op();
      bit [5:0] op_choice;
	  
      op_choice = $random;
      case (op_choice) inside
        [6'b000000 : 6'b001110] : return and_op; //0-14  / p = 23,43%
        [6'b001111 : 6'b011101] : return or_op;  //15-29 / p = 23,43%
        [6'b011110 : 6'b101100] : return sub_op; //30-44 / p = 23,43%
        [6'b101101 : 6'b111011] : return add_op; //45-59 / p = 23,43%
        default: return op_err_op;//$random;				     //60-63 / p = 6,25%
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function bit [31:0] get_data();
      bit [3:0] zero_ones;
      zero_ones = $random; 
      if (zero_ones == 4'b0000)
        return 32'h00_00_00_00;
      else if (zero_ones == 4'b1111)
        return 32'hFF_FF_FF_FF;
      else
        return $random;
   endfunction : get_data
   
   
   task get_data_(output bit [31:0] A, output bit [31:0] B, inout [7:0] q[$]);
	  bit [4:0] equalize; 
      bit [3:0] zero_ones;
      bit [7:0] to_send;
	  bit [63:0] data_packet; 
	  int i; 
	   
	  q.delete();
	   
	  //generate A data,  1/16 chance that data will be zeros or ones
      A =  get_data();
      
      //generate B data,  1/16 chance that data will be zeros or ones
      B =  get_data(); 
   
      equalize = $random;
	  if(equalize == 0) B = A;
      
      
      
      
      data_packet = {B, A};
      
      //choose witch bytes will be put to buffer. There is a 1/255 chance that some data will be lost
      to_send = $random; 
      if(to_send == 8'b0000_0000) begin
	      to_send = $random;
      end
      else 
	      to_send = 8'b1111_1111;
   
      
      // put data to buffer
      for(i = 0; i < 8; i++) begin
	     if(to_send[7-i] == 1) q.push_back(data_packet[63 -8*i -: 8]); 
      end
      
   endtask
   
   
   //get crc - 1/255 chance that crc is wrong
   function bit [3:0] get_crc_(bit[31:0] A, bit [31:0] B, operation_t op_set);
	   bit [3:0] crc;            
	   bit[7:0] r;
	   r = $random; 
	   
	   crc = $random;
	   crc = nextCRC4_D68({B, A, 1'b1, op_set});
	   if(r == 0) crc = $random;   
	   //else crc = $random;
	   return crc; 
   endfunction
	
	
	
	
initial begin : tester 
  	bit [31:0] A_in, B_in;
  	bit [3:0] crc_in;
  	operation_t  op_set_in;
  	bit [7:0] q [$];
  	
  	bfm.reset_alu();

  	repeat (5000) begin : tester_main
     	@(negedge bfm.clk);
	  	
	  	//prepare data to transmitt
     	op_set_in = get_op();
     	get_data_(A_in, B_in, q);
     	crc_in = get_crc_(A_in, B_in, op_set_in);
     	q.push_back({1'b0, op_set_in, crc_in});   
	  	
	  	//transmitt data
     	bfm.tx_packet(q);
	     	
	    //0.1% chance to reset alu	
      	if($urandom_range(50, 0) == 0) begin
			bfm.reset_alu();
      	end
      
  	end
  	$finish;
end : tester
	
endmodule : mtm_alu_tester_module