
class coverage extends uvm_subscriber #(sequence_item);
	`uvm_component_utils(coverage)

	bit  [31:0] 	A;   //data in  A
	bit  [31:0] 	B;	// data in B
	operation_t  	op_set;	

	
	covergroup op_cov;
	  option.name = "cg_op_cov";
	  coverpoint op_set {
	     // #A1 test all operations
	     bins A1_single[] = {add_op, or_op, and_op, sub_op};
	  
	     bins A2_twoops[] = ( add_op, or_op, and_op, sub_op [* 2]);
		  
		  
	     bins A3_op_after_reset[] = ( rst_op => add_op, or_op, and_op, sub_op);
		 bins A4_op_after_err[] = (crc_err_op, data_err_op, op_err_op => add_op, or_op, and_op, sub_op);
		 bins A5_err_ops[] = {crc_err_op, data_err_op, op_err_op};
		  
	  }
	endgroup
	
	covergroup zeros_or_ones_on_ops;
	  	option.name = "cg_zeros_or_ones_on_ops";
	
	  	all_ops : coverpoint op_set {
	    	ignore_bins null_ops = {op_err_op, data_err_op, crc_err_op,  rst_op};
	  	}
	
	  	a_leg: coverpoint A {
	     	bins zeros = {'h00_00_00_00};
	     	bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
	     	bins ones  = {'hFF_FF_FF_FF};
	  	}
	
	  	b_leg: coverpoint B {
	     	bins zeros = {'h00_00_00_00};
	     	bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
	     	bins ones  = {'hFF_FF_FF_FF};
	  	}
	
	  	B_op_00_FF:  cross a_leg, b_leg, all_ops {
	
	     // #B1 simulate all zero input for all the operations
	
	 		bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	
	 		bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	
	 		bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	
	 		bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
	
	 // #B2 simulate all one input for all the operations
	
	 		bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	
	 		bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	
	  		bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	
	  		bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
	
	  		ignore_bins others_only = binsof(a_leg.others) && binsof(b_leg.others);
		}
	endgroup
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
		op_cov = new();
      	zeros_or_ones_on_ops = new();
	endfunction
	
	function void write(sequence_item t);
		A = t.A;
		B = t.B;
		op_set = t.op;
	
		op_cov.sample();
		zeros_or_ones_on_ops.sample();
	
	endfunction :write
endclass : coverage	