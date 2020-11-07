

class shape_factory;
	
	static function shape make_shape(string shape_type, real w, real h);
		rectangle rec_h;
		square sqr_h;
		triangle trng_h;
		
		case (shape_type)
		"rectangle": begin
				rec_h = new(w, h);
				shape_reporter #(rectangle)::put(rec_h);
				return rec_h;
			end
		"square": begin
				sqr_h = new(w);
				shape_reporter #(square)::put(sqr_h);
				return sqr_h;
			end
		"triangle": begin
				trng_h = new(w, h);
				shape_reporter #(triangle)::put(trng_h);
				return trng_h;
			end
		default: $fatal(1, {"No such shape type:", shape_type});
		
		endcase // case (shape_hype)

	endfunction : make_shape
	
endclass : shape_factory