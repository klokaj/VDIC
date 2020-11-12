module top;
import mtm_alu_pkg::*;	
	

mtm_Alu DUT( .clk(bfm.clk), .rst_n(bfm.reset_n), .sin(bfm.sin), .sout(bfm.sout));
 
mtm_alu_bfm    	bfm(); 
testbench testbench_h; 

	
initial begin 
	testbench_h = new(bfm);
	testbench_h.execute();
end

endmodule : top
