//`include "shape.sv"
//`include "rectangle.sv"
//include "shape_factory"

module main();
  
  
  rectangle rec_h; 
  square sqr_h;
  triangle trng_h;
  shape shape_h;
  
   initial begin 
	   int file;
	   string line;
	   string shape_type;
	   real w;
	   real h;
	   
	   
	   
	   file = $fopen("lab02part2A_shapes.txt", "r");
	   
	   
	   while(!$feof(file)) begin
		  $fgets(line, file);
		  
		  if(line != "") begin
		  	$sscanf(line, "%s %g %g", shape_type, w, h);
			shape_h = shape_factory::make_shape(shape_type, w, h); 
		 end
	   end
	   $fclose(file);
	   
	   
	   shape_reporter #(rectangle)::report_shapes();
	   shape_reporter #(square)::report_shapes();
	   shape_reporter #(triangle)::report_shapes();
	end
   
endmodule : main
