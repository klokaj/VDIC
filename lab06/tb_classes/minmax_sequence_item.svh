class minmax_sequence_item extends sequence_item;
	`uvm_object_utils(minmax_sequence_item)
	
	constraint data { A dist {32'h00000000:=1, 32'hFFFFFFFF:=1};
                     B dist {32'h00000000:=1,  32'hFFFFFFFF:= 1}; 			
    }
	
	function new(string name = "minmax_sequence_item");
		super.new(name);
	endfunction : new
	
	

endclass :minmax_sequence_item