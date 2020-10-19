`ifndef COVERAGE_BLOCK
`define COVERAGE_BLOCK


`include "data_types.sv"
//
////------------------------------------------------------------------------------
//// Coverage block
////------------------------------------------------------------------------------
//   covergroup op_cov;
//      option.name = "cg_op_cov";
//      coverpoint op_set {
//         // #A1 test all operations
//         bins A1_single_cycle[] = {[and_op : sub_op]};
//
//	     // #A2 test all 
//	     //bins A2_op_aft_and[] = {and_op => [or_op:sub_op]};
//	      
//	     // #A2 test all 
//	     //bins A3_op_aft_or[] = {or_op => and_op, [add_op:sub_op]};	   
//	    	     // #A2 test all 
//	    // bins A4_op_aft_sub[] = {sub_op => [and_op:or_op], add_op};
//	      
//	      	     // #A2 test all 
//	    // bins A5_op_aft_add[] = {add_op => [and_op:sub_op]};	
//         // #A6 two operations in row
//         bins A6_twoops[] = ([and_op:sub_op] [* 2]);
//
//         // bins manymult = (mul_op [* 3:5]);
//      }
//
//   endgroup
//
//   covergroup zeros_or_ones_on_ops;
//
//      option.name = "cg_zeros_or_ones_on_ops";
//
//      all_ops : coverpoint op_set {
//        //ignore_bins null_ops = {rst_op, no_op};
//      }
//
//      a_leg: coverpoint A {
//         bins zeros = {'h00_00_00_00};
//         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
//         bins ones  = {'hFF_FF_FF_FF};
//      }
//
//      b_leg: coverpoint B {
//         bins zeros = {'h00_00_00_00};
//         bins others= {['h00_00_00_01:'hFF_FF_FF_FE]};
//         bins ones  = {'hFF_FF_FF_FF};
//      }
//
//      B_op_00_FF:  cross a_leg, b_leg, all_ops {
//
//         // #B1 simulate all zero input for all the operations
//
//         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
//                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//
//         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
//                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//
//         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
//                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//
//         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
//                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));
//
//         // #B2 simulate all one input for all the operations
//
//         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
//                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//
//         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
//                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//
//         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
//                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//
//         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
//                       (binsof (a_leg.ones) || binsof (b_leg.ones));
//
//         //bins B2_mul_max = binsof (all_ops) intersect {mul_op} &&
//         //               (binsof (a_leg.ones) && binsof (b_leg.ones));
//
//         ignore_bins others_only =
//                                  binsof(a_leg.others) && binsof(b_leg.others);
//
//      }
//
//   endgroup



`endif