class driver extends uvm_component;
	`uvm_component_utils(driver)
	
	virtual mtm_alu_bfm bfm;
	uvm_get_port #(command_transaction) command_port;
	
	function void build_phase(uvm_phase phase);
		mtm_alu_agent_config mtm_alu_agent_confih_h;
		if(!uvm_config_db #(mtm_alu_agent_config)::get(this, "", "config", mtm_alu_agent_confih_h))
			`uvm_fatal("DRIVER", "Failed to get config");
		
		bfm = mtm_alu_agent_confih_h.bfm;
		command_port = new("command_port", this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		bit [3:0] crc, tmp; 
		bit [7:0] q[$], del_data;
		command_transaction command;
		
		forever begin : command_loop
			command_port.get(command);
			if(command.op == rst_op) begin 
				//$display("DRIVER, reseting_ALU");
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
				
				
				
				crc = nextCRC4_D68({command.B, command.A, 1'b1, command.op});
		     	if(command.op == crc_err_op) begin
				    tmp  = $random;
				    while(crc == tmp)
					    tmp = $random;
				    crc = tmp;
		     	end 
		     	else if(command.op == data_err_op) begin
			    	{tmp, crc} = q.pop_front();
			    end
		     	
			    
		     	
		     	q.push_back({1'b0, command.op, crc});  
		        //$display("DRIVER: A %d %s B %d", command.A, command.op.name(), command.B);
		        bfm.tx_packet(q);
			end
	        
		end :command_loop
	endtask : run_phase
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass : driver
			