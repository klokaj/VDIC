/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by klokaj on Jan 22, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_monitor
`define IFNDEF_GUARD_kl_alu_monitor

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_monitor
//
//------------------------------------------------------------------------------

class kl_alu_monitor extends uvm_monitor;

	// The virtual interface to HDL signals.
	protected virtual kl_alu_if m_kl_alu_vif;

	// Configuration object
	protected kl_alu_config_obj m_config_obj;

	// Collected item
	protected kl_alu_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(kl_alu_item) m_collected_item_port;

	`uvm_component_utils(kl_alu_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = kl_alu_item::type_id::create("m_collected_item", this);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual kl_alu_if)::get(this, "", "m_kl_alu_vif", m_kl_alu_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_kl_alu_vif"})

		// Get the configuration object
		if(!uvm_config_db#(kl_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		// Start monitoring only after an initial reset pulse
		@(negedge m_kl_alu_vif.reset)
			do @(posedge m_kl_alu_vif.clock);
			while(m_kl_alu_vif.reset!==1);

		// Start monitoring
		forever begin
			fork
				// Start the monitoring thread
				begin
					main_thread=process::self();
					collect_items();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_kl_alu_vif.reset) begin
						// Interrupt current item at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_monitor();
					end
				end
			join_any

			if (rst_mon_thread) rst_mon_thread.kill();
		end
	endtask : run_phase

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



//			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
//
//			m_collected_item_port.write(m_collected_item);
//
//			if (m_config_obj.m_checks_enable)
//				perform_item_checks();
		end
		
		
		
	endtask : collect_items

	virtual protected function void perform_item_checks();
		// Perform item checks here
	endfunction : perform_item_checks

	virtual protected function void reset_monitor();
		// Reset monitor specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endfunction : reset_monitor

endclass : kl_alu_monitor

`endif // IFNDEF_GUARD_kl_alu_monitor
