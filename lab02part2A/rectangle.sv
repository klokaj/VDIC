//`include "shape.sv"

class rectangle extends shape;
	function new(real w, real h);
		super.new(w,h);
	endfunction
	
	function real get_area();
		return width * height;
	endfunction : get_area
	
	function void print();
		$display("Rectangle w=%g h=%g area=%g", width, height, get_area() );
	endfunction : print

endclass : rectangle