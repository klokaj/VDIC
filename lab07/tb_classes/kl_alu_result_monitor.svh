/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by klokaj on Jan 24, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_result_monitor
`define IFNDEF_GUARD_kl_alu_result_monitor

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_result_monitor
//
//------------------------------------------------------------------------------

class kl_alu_result_monitor extends kl_alu_base_monitor;


	// Configuration object
	//protected kl_alu_config_obj m_config_obj;
	// Collected item
	protected kl_alu_result_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(kl_alu_result_item) m_collected_item_port;

	`uvm_component_utils(kl_alu_result_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);
		// Allocate collected_item.
		m_collected_item = kl_alu_result_item::type_id::create("m_collected_item", this);
		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

	virtual protected task collect_items();
		bit[8:0] tmp;
		//result_transaction result;
		SerialMonitor outMonitor; 
		outMonitor = new();
		forever begin : sout_monitor_loop
			//result = new();
			@(negedge m_kl_alu_vif.clk);
			outMonitor.sample(m_kl_alu_vif.sout, m_kl_alu_vif.reset_n);
			
			if(outMonitor.get_lenght() >= 5) begin
				m_collected_item = new();
				for(int i = 0; i < 4; i++) begin
					tmp = outMonitor.pop_front();
					m_collected_item.C[31-8*i -:8] = tmp[7:0];
				end
				
				tmp = outMonitor.pop_front();
				m_collected_item.error = 0;
				m_collected_item.flag.carry = tmp[6];
				m_collected_item.flag.ovf = tmp[5];				
				m_collected_item.flag.zero = tmp[4];
				m_collected_item.flag.neg = tmp[3];		
				m_collected_item.crc = tmp[2:0];
				
				`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
				m_collected_item_port.write(m_collected_item);
				if (m_config_obj.m_checks_enable)
					perform_item_checks();
			end
			else if(outMonitor.get_lenght() == 1) begin
				if(outMonitor.is_ctl_frame_inside()) begin
					m_collected_item = new();
					
					tmp = outMonitor.pop_front();
					m_collected_item.error = 1;
					m_collected_item.err_flag.data = tmp[3];
					m_collected_item.err_flag.crc = tmp[2];
					m_collected_item.err_flag.op = tmp[1];
					
					`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
					m_collected_item_port.write(m_collected_item);
					if (m_config_obj.m_checks_enable)
					perform_item_checks();
		
				end
			
			end
		end	: sout_monitor_loop	
	endtask : collect_items

endclass : kl_alu_result_monitor

`endif // IFNDEF_GUARD_kl_alu_result_monitor
