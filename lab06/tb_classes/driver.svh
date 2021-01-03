class driver extends uvm_driver #(sequence_item);
	`uvm_component_utils(driver)
	
	virtual mtm_alu_bfm bfm;
	//uvm_get_port #(command_transaction) command_port;
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1, "Failed to get BFM");
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		bit [3:0] crc, tmp; 
		bit [7:0] q[$], del_data;
		sequence_item command;
		
		void'(begin_tr(command));
		
		
		forever begin : command_loop
			seq_item_port.get_next_item(command);

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
			
			seq_item_port.item_done();
	        
		end :command_loop
		
		end_tr(command);
	endtask : run_phase
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass : driver
			