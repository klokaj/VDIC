//`include "shape.sv"

class square extends shape;
	function new(real w);
		super.new(w,w);
	endfunction
	
	function real get_area();
		return width * height;
	endfunction : get_area
	
	function void print();
		$display("Square w=%g area=%g", width, get_area() );
	endfunction : print

endclass : rectangle