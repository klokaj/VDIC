

class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    uvm_analysis_port #(result_s) ap;

    function void write_to_monitor(result_s r);
//        $display ("RESULT MONITOR: resultA: 0x%0h",r);
        ap.write(r);
    endfunction : write_to_monitor

    function void build_phase(uvm_phase phase);
        virtual mtm_alu_bfm bfm;
        if(!uvm_config_db #(virtual mtm_alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        bfm.result_monitor_h = this;
        ap                   = new("ap",this);
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : result_monitor






