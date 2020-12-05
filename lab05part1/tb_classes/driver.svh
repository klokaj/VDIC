class driver extends uvm_component;
	`uvm_component_utils(driver)
	
	virtual mtm_alu_bfm bfm;
	uvm_get_port #(command_s) command_port;
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
		command_port = new("command_port", this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		bit[7:0] q[$];
		command_s command;
		
		forever begin : command_loop
			command_port.get(command);
			if(command.op == rst_op) begin 
				bfm.reset_alu();	
			end
			else begin
				q.delete();
		        q.push_back(command.B[31:24]);
		        q.push_back(command.B[23:16]);
		        q.push_back(command.B[15:8]);
		        q.push_back(command.B[7:0]);
		        
		        q.push_back(command.A[31:24]);
		        q.push_back(command.A[23:16]);
		        q.push_back(command.A[15:8]);
		        q.push_back(command.A[7:0]);
		     	q.push_back({1'b0, command.op, command.crc});  
		        bfm.tx_packet(q);
			end
	        
		end :command_loop
	endtask : run_phase
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass : driver
			