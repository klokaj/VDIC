`ifndef RANDOM_DATA_GEN
`define RANDOM_DATA_GEN



`include "data_types.sv"
`include "crc_calc.sv"

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
      bit [3:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 4'b0000)
        return 32'h00_00_00_00;
      else if (zero_ones == 4'b1111)
        return 32'hFF_FF_FF_FF;
      else
        return $random;
   endfunction : get_data
   
   

   
   
   
   task get_data_(output bit [31:0] A, output bit [31:0] B, output [7:0] q[$]);
      bit [3:0] zero_ones;
      bit [7:0] to_send;
	  bit [63:0] data_packet; 
	  int i; 
	   
	   
	  q.delete();
	   
	  //generate A data,  1/16 chance that data will be zeros or ones
        A =  get_data();
      
      //generate B data,  1/16 chance that data will be zeros or ones
        B =  get_data(); 
   
      
      data_packet = {B, A};
      
      //choose witch bytes will be put to buffer. There is a 1/255 chance that some data will be lost
      to_send = $random; 
      if(to_send == 8'b0000_0000) begin
	      to_send = $random;
      end
      else 
	      to_send = 8'b0000_0000;
   
      // put data to buffer
      for(i = 0; i < 8; i++) begin
	     if(to_send[7-i] == 1) q.push_back(data_packet[63 -8*i -: 8]); 
      end
      
      
      //add extra data frame;
      to_send = $random; 
      if(to_send == 8'b0000_0000) begin
	      to_send = $random;
	      q.push_back(to_send);
	  end
   endtask
   
   
   //get crc - 1/255 chance that crc is wrong
   function bit [3:0] get_crc_(bit[31:0] A, bit [31:0] B, operation_t op_set);
	   bit [3:0] crc;
	   bit[7:0] r;
	   r = $random; 
	   
	   crc = nextCRC4_D68({B, A, 1'b1, op_set});
	   if(r == 0) crc = $random;   
	   
	   return crc; 
   endfunction
   
`endif
   