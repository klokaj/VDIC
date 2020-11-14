module top;
import uvm_pkg::*;
`include "uvm_macros.svh"
import mtm_alu_pkg::*;	
`include "tb_classes/base_tester.svh"
`include "tb_classes/random_tester.svh"
`include "tb_classes/add_tester.svh"

`include "tb_classes/scoreboard.svh"
`include "tb_classes/coverage.svh"
`include "tb_classes/env.svh"

`include "tb_classes/random_test.svh"
`include "tb_classes/add_test.svh"
	//tb_classes/env.svh
//tb_classes/random_test.svh
//tb_classes/random_tester.svh
//tb_classes/add_tester.svh
//tb_classes/add_test.svh
//tb_classes/base_tester.svh
//tb_classes/coverage.svh
//tb_classes/scoreboard.svh
mtm_alu_bfm    	bfm(); 
	
mtm_Alu DUT( .clk(bfm.clk), .rst_n(bfm.reset_n), .sin(bfm.sin), .sout(bfm.sout));
 


initial begin 
	uvm_config_db #(virtual mtm_alu_bfm)::set(null, "*", "bfm", bfm);
	run_test();
end

endmodule : top


