

class minmax_transaction extends command_transaction; 
	`uvm_object_utils(minmax_transaction)
	
	constraint data { A dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:/10, 32'hFFFFFFFF:=1};
                     B dist {32'h00000000:=1, [32'h00000001 : 32'hFFFFFFFE]:/10, 32'hFFFFFFFF:= 1}; 			
    }
	
	
	function new (string name = "");
		super.new(name);
	endfunction
	
	
endclass : minmax_transaction