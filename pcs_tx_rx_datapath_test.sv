class pcs_tx_rx_datapath_test extends pcs_base_test;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(pcs_tx_rx_datapath_test)

//===============================
// Constructor
//===============================
function new(string name = "pcs_tx_rx_datapath_test" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//========================================
// sequence to generate valid xgmi frames
//========================================
xgmi_tx_sequence tx_seq;
xgmii_terminate_char_sequence terminate_seq;

//===============================
// Argument variables
//===============================
int run_tx_seq;
int run_terminate_seq;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	// creating xgmi_tx_sequence
	tx_seq = xgmi_tx_sequence::type_id::create("tx_seq");
	
	// creating xgmi_terminate_char_sequence
	terminate_seq = xgmii_terminate_char_sequence::type_id::create("terminate_seq");

	uvm_config_db#(int)::get(this, "", "run_tx_seq", run_tx_seq);
	uvm_config_db#(int)::get(this, "", "run_terminate_seq", run_terminate_seq);
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	super.main_phase(phase);
	phase.raise_objection(this);
	if(run_tx_seq == 1) begin
		tx_seq.start(pcs10g_env.tx_agnt.tx_sqncr);
	end
		
	if(run_terminate_seq == 1) begin
		terminate_seq.start(pcs10g_env.tx_agnt.tx_sqncr);
	end
	phase.drop_objection(this);
endtask

endclass
