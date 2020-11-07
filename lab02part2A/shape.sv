virtual class shape;
	real width;
	real height;
	
	function new(real w, real h);
		width = w;
		height = h;
	endfunction
	
	
	pure virtual function real get_area();
	pure virtual function void print();
	
endclass : shape 
