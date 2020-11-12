class testbench;
	virtual mtm_alu_bfm bfm;
	
	function new (virtual mtm_alu_bfm b);
		bfm = b;
	endfunction
	

	tester 			tester_h;
	scoreboard	    scoreboard_h;
	coverage 		coverage_h;	
	
	task execute();
		scoreboard_h = new(bfm);
		tester_h = new(bfm);
		coverage_h = new(bfm);
		fork 
			scoreboard_h.execute();
			tester_h.execute();
			coverage_h.execute();
		join_none
	endtask :execute
	
endclass : testbench