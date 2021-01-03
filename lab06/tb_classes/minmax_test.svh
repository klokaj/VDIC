class minmax_test extends alu_base_test;
    `uvm_component_utils(minmax_test)

	
	
	minmax_sequence minmax_h;
	
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
		minmax_h = new("minmax_h");
	endfunction : new
	
	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		minmax_h.start(sequencer_h);
		phase.drop_objection(this);
	endtask : run_phase
	

endclass : minmax_test
