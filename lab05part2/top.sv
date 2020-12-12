module top;
	
import uvm_pkg::*;
import mtm_alu_pkg::*;		
	
`include "uvm_macros.svh"


mtm_alu_bfm class_bfm();
mtm_Alu class_dut( .clk(class_bfm.clk), .rst_n(class_bfm.reset_n), .sin(class_bfm.sin), .sout(class_bfm.sout));
	
mtm_alu_bfm module_bfm();
mtm_Alu modue_dut( .clk(module_bfm.clk), .rst_n(module_bfm.reset_n), .sin(module_bfm.sin), .sout(module_bfm.sout));
	


mtm_alu_tester_module stim_module(module_bfm);

initial begin 
	uvm_config_db #(virtual mtm_alu_bfm)::set(null, "*", "class_bfm", class_bfm);
	uvm_config_db #(virtual mtm_alu_bfm)::set(null, "*", "module_bfm", module_bfm);
	run_test("dual_test");
end

endmodule : top


