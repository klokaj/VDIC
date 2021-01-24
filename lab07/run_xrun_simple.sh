xrun \
	-F tb.f -F dut.f \
	-uvm \
	-uvmhome /cad/XCELIUM1909/tools/methodology/UVM/CDNS-1.2/sv \
	+UVM_TESTNAME=kl_alu_random_test \
	+UVM_TESTNAME=kl_alu_minmax_test \
	"$@" 

