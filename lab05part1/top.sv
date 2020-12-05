module top;
	
import uvm_pkg::*;
import mtm_alu_pkg::*;		
	
`include "uvm_macros.svh"


mtm_alu_bfm    	bfm(); 
mtm_Alu DUT( .clk(bfm.clk), .rst_n(bfm.reset_n), .sin(bfm.sin), .sout(bfm.sout));
 


initial begin 
	uvm_config_db #(virtual mtm_alu_bfm)::set(null, "*", "bfm", bfm);
	run_test();
end

endmodule : top


