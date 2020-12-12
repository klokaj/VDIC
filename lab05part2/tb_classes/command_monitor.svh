

class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual mtm_alu_bfm bfm;
    uvm_analysis_port #(command_transaction) ap;
 
 
 
    function void build_phase(uvm_phase phase);
        mtm_alu_agent_config mtm_alu_agent_config_h;

        if(!uvm_config_db #(mtm_alu_agent_config)::get(this, "","config",mtm_alu_agent_config_h))
            `uvm_fatal("COMMAND MONITOR", "Failed to get config");

        mtm_alu_agent_config_h.bfm.command_monitor_h = this;
        
        ap = new("ap",this);

    endfunction : build_phase

    function void write_to_monitor(command_transaction cmd);
//        $display("COMMAND MONITOR: A:0x%2h B:0x%2h op: %s", cmd.A, cmd.B, cmd.op.name());
        ap.write(cmd);
    endfunction : write_to_monitor

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

endclass : command_monitor

