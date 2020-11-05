`ifndef SERIAL_MONITOR
`define SERIAL_MONITOR



//
// Klasa do monitorowania lini szeregowych. Dane z lini szeregowej sa probkowane i zapisywane do wewnetrznej kolejki. 
// Klasa zapewnia metody do sprawdzania zawartosci buffora - sprawdzanie czy ma okreslana dlugosc, czy znajduje sie w nim ramka CMD 
// i na jakiej pozycji
// 


class s_monitor;
	bit capturing;
	int capturing_ctr;
	bit [10:0] captured_data;
	bit[8:0] q [$];
	
	function new();
		capturing = 0;
		capturing_ctr = 0;
		captured_data = 0;
		q = {};
	endfunction
	
	function sample(bit state, bit rst_n);
		if((capturing == 1) | (state == 0)) begin
			capturing = 1;
			captured_data[10 - capturing_ctr] = state;
			capturing_ctr++;

			if(capturing_ctr > 10) begin
				capturing_ctr = 0;
				capturing = 0;
				q.push_back(captured_data[9:1]);
			end
		end
		else begin
			capturing = 0;
			capturing_ctr = 0;
		end
		
		if(rst_n == 0) begin
			capturing = 0;
			q.delete();
			capturing_ctr = 0;
			captured_data = 0;
		end
	endfunction

	function bit is_data_frame(int index);
		bit [8:0] tmp;
		if(index > q.size()) return 0;
		tmp = q[index];
		return !tmp[8];
	endfunction

	function bit is_ctl_frame(int index);
		bit [8:0] tmp;
		if(index > q.size()) return 0;
		tmp = q[index];
		return tmp[8];
	endfunction

	function bit is_ctl_frame_before_index(int index);
		//int j = (index-1 > q.size()) ? q.size() : index-1;
		int j;
		if(q.size > index) j = index;
		else j = q.size;
		
		for(int i = 0; i < j; i++)begin
			if(is_ctl_frame(i)) return 1;	
		end
		return 0;
	endfunction
	
	function bit is_first_ctl_frame_at_index(int index);
		if(is_ctl_frame(index) == 0) return 0;
		if(is_ctl_frame_before_index(index-1)) return 0;
		return 1;
	endfunction
	
	function bit is_ctl_frame_inside();
		return is_ctl_frame_before_index(q.size());
	endfunction
endclass


`endif

