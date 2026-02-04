class valid_tx_frames_serdes_width_64 extends pcs_base_test;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(valid_tx_frames_serdes_width_64)

//===============================
// Constructor
//===============================
function new(string name = "valid_tx_frames_serdes_width_64" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//========================================
// sequence to generate valid xgmi frames
//========================================
xgmi_tx_sequence tx_seq;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	// creating xgmi_tx_sequence
	tx_seq = xgmi_tx_sequence::type_id::create("tx_seq");
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	super.main_phase(phase);
	phase.raise_objection(this);
		tx_seq.start(pcs10g_env.tx_agnt.tx_sqncr);
	phase.drop_objection(this);
endtask

endclass