/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_input_monitor
`define IFNDEF_GUARD_kl_alu_input_monitor

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_monitor
//
//------------------------------------------------------------------------------

class kl_alu_input_monitor extends kl_alu_base_monitor;

	// Collected item
	protected kl_alu_item m_collected_item;
	
	// Collected item is broadcast on this port
	uvm_analysis_port #(kl_alu_item) m_collected_item_port;

	`uvm_component_utils(kl_alu_input_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = kl_alu_item::type_id::create("m_collected_item", this);
		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new
	
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual protected task collect_items();
		//forever begin
			// FIXME Fill this place with the logic for collecting the data
			// ...
			//wait(0);
		bit [3:0] crc, expected_crc; 
		
		bit[8:0] tmp;
		kl_alu_item command;
		SerialMonitor inMonitor; 
		operation_t op;
		
		inMonitor = new();
		command = new("command");
		
		forever begin : sin_monitor_loop
			@(negedge m_kl_alu_vif.clk);
			inMonitor.sample(m_kl_alu_vif.sin, m_kl_alu_vif.sout);
			if( inMonitor.is_ctl_frame_inside()) begin
				if(inMonitor.is_first_ctl_frame_at_index(8)) begin
					for(int i = 0; i < 4; i++) begin
						tmp = inMonitor.pop_front();
						m_collected_item.B[31-8*i -:8] = tmp[7:0];
					end
			
					for(int i = 0; i < 4; i++) begin
						tmp = inMonitor.pop_front();
						m_collected_item.A[31-8*i -:8] = tmp[7:0];
					end
					tmp = inMonitor.pop_front();
					crc = tmp[3:0];
					expected_crc = nextCRC4_D68({m_collected_item.B, m_collected_item.A, 1'b1, tmp[6:4]});
				
					if(crc == expected_crc)
						m_collected_item.op = op2enum(tmp[6:4]);
					else 
						m_collected_item.op = crc_err_op;

					`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
					m_collected_item_port.write(m_collected_item);
					if (m_config_obj.m_checks_enable)
						perform_item_checks();
					
				end
				else begin 
					
					while(! inMonitor.is_ctl_frame(0)) begin
						tmp = inMonitor.pop_front();
					end
					
					tmp = inMonitor.pop_front();
					m_collected_item.op = data_err_op;
					`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
					m_collected_item_port.write(m_collected_item);
					if (m_config_obj.m_checks_enable)
						perform_item_checks();
		
				end
			end
		end
	endtask : collect_items
endclass : kl_alu_input_monitor

`endif // IFNDEF_GUARD_kl_alu_input_monitor
