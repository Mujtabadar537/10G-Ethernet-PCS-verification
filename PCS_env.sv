////////////////////////////////////////////////////////////////////////////////
//
// Filename : PCS_env.sv
// Author : Mujtaba Waseem
//
// No portions of this material may be reproduced in any form without
// the written permission of CoMira Solutions Inc.
//
// All information contained in this document is CoMira Solutions
// private, proprietary and trade secret.
//
// Description
// ===========
// UVM Environment class for 10G PCS verif 
//
// ///////////////////////////////////////////////////////////////////////////////

class PCS_env extends uvm_env;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(PCS_env)

//===============================
// Constructor
//===============================
function new(string name = "PCS_env" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Agent handles
//===============================
tx_agent tx_agnt;
rx_agent rx_agnt;
pcs_scoreboard scoreboard;
rxpcs_ref_model rxpcs;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting PCS_env build phase__________", UVM_MEDIUM);
	
	// creating tx_agent
	tx_agnt = tx_agent::type_id::create("tx_agnt" , this);

	// creating rx_agent
	rx_agnt = rx_agent::type_id::create("rx_agnt" , this);

	// creating pcs_scoreboard
	scoreboard = pcs_scoreboard::type_id::create("scoreboard" , this);

	// creating rxpcs_ref_model
	rxpcs = rxpcs_ref_model::type_id::create("rxpcs" , this);
	`uvm_info(get_type_name(), "__________Ending PCS_env build phase__________", UVM_MEDIUM);
endfunction

//===============================
// Connect phase
//===============================
function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	// connecting analysis ports with their implementations
	tx_agnt.tx_mntr.tx_analysis_port.connect(scoreboard.tx_analysis_imp_port);
	rx_agnt.rx_mntr.rx_analysis_port.connect(scoreboard.rx_analysis_imp_port);
	rx_agnt.serdes_mntr.serdes_analysis_port.connect(rxpcs.serdes_analysis_imp_port);
	rx_agnt.rx_mntr.rxref_analysis_port.connect(rxpcs.rxref_analysis_imp_port);
endfunction

endclass
