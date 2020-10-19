`ifndef DATA_TYPES
`define DATA_TYPES

	typedef enum bit[2:0] {and_op  = 3'b000,
                          or_op = 3'b001, 
                          add_op = 3'b100,
                          sub_op = 3'b101,
                          rsv_op = 3'b111
    } operation_t;
	
	typedef enum bit[3:0] {
		no_f = 4'b0000,
		carry_f = 4'b0001,
		ovf_f = 4'b0010,
		zero_f = 4'b0100,
		neg_f = 4'b1000
	} flag_t;
	
	typedef enum bit[5:0] {
		data_err = 6'b100100,
		crc_err = 6'b010010,
		op_err = 6'b001001,
		no_err = 6'b000000
	} err_flag_t;
	
	
`endif