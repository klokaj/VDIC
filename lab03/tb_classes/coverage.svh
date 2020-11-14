 



  
 





class coverage extends uvm_component;
	`uvm_component_utils(coverage)

	virtual mtm_alu_bfm bfm;
	bit  [31:0] 	A;   //data in  A
	bit  [31:0] 	B;	// data in B
	operation_t  	op_set;	
	bit[3:0] 		expected_flag; 
	bit[5:0] 		expected_err_flag;
	bit	  	 		expected_err;	
	bit 			reset_n;
	
	covergroup op_cov;
	  option.name = "cg_op_cov";
	  coverpoint op_set {
	     // #A1 test all operations
	     bins A1_single_cycle[] = {[and_op : sub_op]};
	  
	     bins A2_twoops[] = ([and_op:sub_op] [* 2]);
	      
	     bins A3_rsv[] = {rsv_op}; 
	  }
	endgroup
	
	covergroup zeros_or_ones_on_ops;
	  	option.name = "cg_zeros_or_ones_on_ops";
	
	  	all_ops : coverpoint op_set {
	    	ignore_bins null_ops = {rsv_op};
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
	
	covergroup flags_cov;
	  option.name = "mtm alu flags cov";
	
	  err_cov : coverpoint  expected_err {
	    bins no_err = {1'b0};
	  	ignore_bins err = {1'b1};
	  }
	  
	  flags : coverpoint expected_flag {
	    wildcard bins carry = {4'b1xxx};
	    wildcard bins overflow = {4'bx1xx};
	    wildcard bins zero = {4'bxx1x};
	    wildcard bins negative = {4'bxxx1};
	    bins no_flag = {4'b0000};
	
	      
	  }
	
	  no_err_flags:  cross err_cov, flags{
	     bins no_err_carry = binsof (err_cov) intersect {no_err} &&
	                   (binsof (flags.carry));
	     bins no_err_ovf = binsof (err_cov) intersect {no_err} &&
	                   (binsof (flags.overflow));
	     bins no_err_zero = binsof (err_cov) intersect {no_err} &&
	           (binsof (flags.zero));
	     bins no_err_neg = binsof (err_cov) intersect {no_err} &&
	                   (binsof (flags.negative));
	     bins no_err_no_flag = binsof (err_cov) intersect {no_err} &&
	               (binsof (flags.no_flag));
	  }
	endgroup	
	
	covergroup err_flags_cov;
	  option.name = "mtm alu error flags cov";
	
	  err_cov : coverpoint  expected_err {
	    ignore_bins no_err = {1'b0};
	  	bins err = {1'b1};
	  }
	  
	  flags : coverpoint expected_err_flag {
	    wildcard bins err_data = {6'b100100};
	    wildcard bins err_crc = {6'b010010};
	    wildcard bins err_op = {6'b001001};
	    bins no_err = {6'b000000};    
	  }
		
	endgroup
	
	covergroup op_after_rst_cov;
	 option.name = "mtm alu operation after reset";
	
	 ops_after_reset: coverpoint {reset_n, op_set} {
		wildcard bins and_after_rst[] = ({1'b0, rsv_op} => {1'b1, and_op});
		wildcard bins or_after_rst[] = ( {1'b0, rsv_op} => {1'b1, or_op});
		wildcard bins add_after_rst[] = ( {1'b0, rsv_op} => {1'b1, add_op});
		wildcard bins sub_after_rst[] = ( {1'b0, rsv_op} => {1'b1, sub_op});
	 }
	endgroup	
	
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
		op_cov = new();
      	zeros_or_ones_on_ops = new();
		op_after_rst_cov = new();
		err_flags_cov = new();
		flags_cov = new();
	endfunction
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
	endfunction : build_phase
	
	
	task run_phase(uvm_phase phase);
	  input_data DIN;
	  mtm_alu_model ALU_model;
	  DIN = new();
	  ALU_model = new();
		
      forever begin : sample_cov
	     //sample sin at clock negedge
         @(negedge bfm.clk);
	     DIN.sample(bfm.sin, bfm.reset_n);
	     reset_n = bfm.reset_n;
	     
	     //check if input data is ready
	     if(DIN.rdy()) begin
		    //decode input data 
		    DIN.decode_data();
		     
		    A = DIN.A;
		    B = DIN.B;
		    op_set = DIN.op;
		     
		    ALU_model.calculate_response(DIN);  
		     
		    expected_flag = ALU_model.flags;
		    expected_err_flag = ALU_model.err_flags;
		    expected_err = ALU_model.err;
   
			op_cov.sample();
	      	zeros_or_ones_on_ops.sample();
		  	flags_cov.sample();
		  	err_flags_cov.sample();
		  	op_after_rst_cov.sample();

	     end	
	     else if(reset_n == 0) begin
		 	op_set = rsv_op;
		    op_after_rst_cov.sample();
		 end
      end		
	endtask : run_phase
endclass : coverage





//import mtm_alu_pkg::*;	
//
//class coverage;
//	virtual mtm_alu_bfm bfm;
//	bit  [31:0] 	A;   //data in  A
//	bit  [31:0] 	B;	// data in B
//	operation_t  	op_set;	
//	bit[3:0] 		expected_flag; 
//	bit[5:0] 		expected_err_flag;
//	bit	  	 		expected_err;	
//	bit 			reset_n;
//
//	covergroup op_cov;
//	  option.name = "cg_op_cov";
//	  coverpoint op_set {
//	     // #A1 test all operations
//	     bins A1_single_cycle[] = {[and_op : sub_op]};
//	  
//	     bins A2_twoops[] = ([and_op:sub_op] [* 2]);
//	      
//	     bins A3_rsv[] = {rsv_op}; 
//	  }
//	endgroup
//	
//	covergroup zeros_or_ones_on_ops;
//	  	option.name = "cg_zeros_or_ones_on_ops";
//	
//	  	all_ops : coverpoint op_set {
//	    	ignore_bins null_ops = {rsv_op};
//	  	}
//	
//	  	a_leg: coverpoint A {
//	     	bins zeros = {'h00_00_00_00};
//	     	bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
//	     	bins ones  = {'hFF_FF_FF_FF};
//	  	}
//	
//	  	b_leg: coverpoint B {
//	     	bins zeros = {'h00_00_00_00};
//	     	bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
//	     	bins ones  = {'hFF_FF_FF_FF};
//	  	}
//	
//	  	B_op_00_FF:  cross a_leg, b_leg, all_ops {
//	
//	     // #B1 simulate all zero input for all the operations
//	
//	 		bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
//	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//	
//	 		bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
//	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//	
//	 		bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
//	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//	
//	 		bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
//	               (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//	
//	 // #B2 simulate all one input for all the operations
//	
//	 		bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
//	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//	
//	 		bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
//	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//	
//	  		bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
//	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//	
//	  		bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
//	                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//	
//	  		ignore_bins others_only = binsof(a_leg.others) && binsof(b_leg.others);
//		}
//	endgroup
//
//
//
//	covergroup flags_cov;
//	  option.name = "mtm alu flags cov";
//	
//	  err_cov : coverpoint  expected_err {
//	    bins no_err = {1'b0};
//	  	ignore_bins err = {1'b1};
//	  }
//	  
//	  flags : coverpoint expected_flag {
//	    wildcard bins carry = {4'b1xxx};
//	    wildcard bins overflow = {4'bx1xx};
//	    wildcard bins zero = {4'bxx1x};
//	    wildcard bins negative = {4'bxxx1};
//	    bins no_flag = {4'b0000};
//	
//	      
//	  }
//	
//	  no_err_flags:  cross err_cov, flags{
//	     bins no_err_carry = binsof (err_cov) intersect {no_err} &&
//	                   (binsof (flags.carry));
//	     bins no_err_ovf = binsof (err_cov) intersect {no_err} &&
//	                   (binsof (flags.overflow));
//	     bins no_err_zero = binsof (err_cov) intersect {no_err} &&
//	           (binsof (flags.zero));
//	     bins no_err_neg = binsof (err_cov) intersect {no_err} &&
//	                   (binsof (flags.negative));
//	     bins no_err_no_flag = binsof (err_cov) intersect {no_err} &&
//	               (binsof (flags.no_flag));
//	  }
//	endgroup
//	
//	
//	covergroup err_flags_cov;
//	  option.name = "mtm alu error flags cov";
//	
//	  err_cov : coverpoint  expected_err {
//	    ignore_bins no_err = {1'b0};
//	  	bins err = {1'b1};
//	  }
//	  
//	  flags : coverpoint expected_err_flag {
//	    wildcard bins err_data = {6'b100100};
//	    wildcard bins err_crc = {6'b010010};
//	    wildcard bins err_op = {6'b001001};
//	    bins no_err = {6'b000000};    
//	  }
//		
//	endgroup
//	
//	covergroup op_after_rst_cov;
//	 option.name = "mtm alu operation after reset";
//	
//	 ops_after_reset: coverpoint {reset_n, op_set} {
//		wildcard bins and_after_rst[] = ({1'b0, rsv_op} => {1'b1, and_op});
//		wildcard bins or_after_rst[] = ( {1'b0, rsv_op} => {1'b1, or_op});
//		wildcard bins add_after_rst[] = ( {1'b0, rsv_op} => {1'b1, add_op});
//		wildcard bins sub_after_rst[] = ( {1'b0, rsv_op} => {1'b1, sub_op});
//	 }
//	endgroup
//	
//	
//	
//	function new (virtual mtm_alu_bfm b);
//		op_cov = new();
//      	zeros_or_ones_on_ops = new();
//	  	flags_cov = new();
//	  	err_flags_cov = new();
//	  	op_after_rst_cov = new();
//		
//		bfm = b;
//	endfunction
//
//
//
//	task execute();
//	  input_data DIN;
//	  mtm_alu_model ALU_model;
//	  
//	  DIN = new();
//	  ALU_model = new();	
//		
//		
//
//      forever begin : sample_cov
//	     //sample sin at clock negedge
//         @(negedge bfm.clk);
//	    	reset_n = bfm.reset_n;
//	     	DIN.sample(bfm.sin, bfm.reset_n);
//	     
//	     //check if input data is ready
//	     if(DIN.rdy()) begin
//		    //decode input data 
//		    DIN.decode_data();
//		     
//		    //extract data for coverage blocks (coverage sampling signals could by redefined)  
//		    A = DIN.A;
//		    B = DIN.B;
//		    op_set = DIN.op;
//		     
//		   //calculate expected response for a given input data 
//		    ALU_model.calculate_response(DIN);  
//		    //extract flags for a coverage blocks 
//		    expected_flag = ALU_model.flags;
//		    expected_err_flag = ALU_model.err_flags;
//		    expected_err = ALU_model.err;
//   
//			op_cov.sample();
//	      	zeros_or_ones_on_ops.sample();
//		  	flags_cov.sample();
//		  	err_flags_cov.sample();
//		  	op_after_rst_cov.sample();
//	     end	
//	     else if(reset_n == 1'b0) begin
//		    op_set = rsv_op;
//		 	op_after_rst_cov.sample();
//		 end
//      end
//	endtask : execute
//endclass : coverage






   

   



