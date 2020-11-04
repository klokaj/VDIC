`include "mtm_alu_bfm.sv"
`include "tester.sv"
`include "scoreboard.sv"
`include "coverage.sv"


//
// Glowny plik symulacyjn
//



module top;
mtm_alu_bfm    	bfm();
tester 			tester_i(bfm);
scoreboard	    scoreboard_i(bfm);
coverage 		coverage_i(bfm);
 
   
//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------
mtm_Alu DUT( .clk(bfm.clk), .rst_n(bfm.reset_n), .sin(bfm.sin), .sout(bfm.sout));
 





endmodule : top
