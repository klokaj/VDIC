/******************************************************************************
* DVT CODE TEMPLATE: agent
* Created by klokaj on Jan 24, 2021
* uvc_company = kl, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kl_alu_agent
`define IFNDEF_GUARD_kl_alu_agent

//------------------------------------------------------------------------------
//
// CLASS: kl_alu_agent
//
//------------------------------------------------------------------------------

class kl_alu_agent extends uvm_agent;

	// Configuration object
	protected kl_alu_config_obj m_config_obj;

	kl_alu_driver m_driver;
	kl_alu_sequencer m_sequencer;
	kl_alu_monitor m_monitor;
	kl_alu_coverage_collector m_coverage_collector;

	// TODO Add fields here
	

	`uvm_component_utils(kl_alu_agent)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		$display("Check if create a driver");
		// Get the configuration object
		if(!uvm_config_db#(kl_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})

		// Propagate the configuration object to monitor
		uvm_config_db#(kl_alu_config_obj)::set(this, "m_monitor", "m_config_obj", m_config_obj);
		// Create the monitor
		m_monitor = kl_alu_monitor::type_id::create("m_monitor", this);

		if(m_config_obj.m_coverage_enable) begin
			m_coverage_collector = kl_alu_coverage_collector::type_id::create("m_coverage_collector", this);
		end
		$display("Check if create a driver");
		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			$display("Creating the driver");
			// Propagate the configuration object to driver
			uvm_config_db#(kl_alu_config_obj)::set(this, "m_driver", "m_config_obj", m_config_obj);
			// Create the driver
			m_driver = kl_alu_driver::type_id::create("m_driver", this);

			// Create the sequencer
			m_sequencer = kl_alu_sequencer::type_id::create("m_sequencer", this);
		end
	endfunction : build_phase

	virtual function void connect_phase(uvm_phase phase);
		if(m_config_obj.m_coverage_enable) begin
			m_monitor.m_collected_item_port.connect(m_coverage_collector.m_monitor_port);
		end

		if(m_config_obj.m_is_active == UVM_ACTIVE) begin
			m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
		end
	endfunction : connect_phase

endclass : kl_alu_agent

`endif // IFNDEF_GUARD_kl_alu_agent
