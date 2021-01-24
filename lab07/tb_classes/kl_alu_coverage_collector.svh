/******************************************************************************
* DVT CODE TEMPLATE: coverage collector
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_coverage_collector
`define IFNDEF_GUARD_kl_alu_coverage_collector

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_coverage_collector
//
//------------------------------------------------------------------------------

class kl_alu_coverage_collector extends uvm_component;

	// Configuration object
	protected kl_alu_config_obj m_config_obj;

	// Item collected from the monitor
	protected kl_alu_item m_collected_item;
	
	//
	protected bit  [31:0] 	A;   //data in  A
	protected bit  [31:0] 	B;	// data in B
	protected operation_t  	op_set;	

	// Using suffix to handle more ports
	`uvm_analysis_imp_decl(_collected_item)

	// Connection to the monitor
	uvm_analysis_imp_collected_item#(kl_alu_item, kl_alu_coverage_collector) m_monitor_port;

	// TODO: More items and connections can be added if needed

	`uvm_component_utils(kl_alu_coverage_collector)

	covergroup item_cg;
		option.per_instance = 1;
		// TODO add coverpoints here
		
	endgroup : item_cg
	
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
	
	

	function new(string name, uvm_component parent);
		super.new(name, parent);
		op_cov = new();
      	zeros_or_ones_on_ops = new();
		//item_cg=new;
		//item_cg.set_inst_name({get_full_name(), ".item_cg"});
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_monitor_port = new("m_monitor_port",this);

		// Get the configuration object
		if(!uvm_config_db#(kl_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction : build_phase

	function void write_collected_item(kl_alu_item item);
		
		$display("COVERAGE: Sampling data");
		m_collected_item = item;
		A = item.A;
		B = item.B;
		op_set = item.op;
		//item_cg.sample();
		op_cov.sample();
		zeros_or_ones_on_ops.sample();
	endfunction : write_collected_item

endclass : kl_alu_coverage_collector

`endif // IFNDEF_GUARD_kl_alu_coverage_collector
