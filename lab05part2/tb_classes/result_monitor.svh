

class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    virtual mtm_alu_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;

    function void write_to_monitor(result_transaction r);
//        $display ("RESULT MONITOR: resultA: 0x%0h",r);
        ap.write(r);
    endfunction : write_to_monitor

    function void build_phase(uvm_phase phase);
	    mtm_alu_agent_config mtm_alu_agent_config_h;
	    
     
        if(!uvm_config_db #(mtm_alu_agent_config)::get(this, "","config", mtm_alu_agent_config_h))
            `uvm_fatal("RESULT MONITOR", "Failed to get CONFIG");
      
        mtm_alu_agent_config_h.bfm.result_monitor_h = this;
        ap = new("ap",this);
        
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : result_monitor






