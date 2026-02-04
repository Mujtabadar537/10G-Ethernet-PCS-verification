////////////////////////////////////////////////////////////////////////////////
//
// Filename : tx_agent.sv
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
// tx_agent will be resonsible for driving XGMII tx frames on PCS-TX side 
//
// ///////////////////////////////////////////////////////////////////////////////

class tx_agent extends uvm_agent;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(tx_agent)

//===============================
// Constructor
//===============================
function new(string name = "tx_agent" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Agent components
//===============================
tx_sequencer tx_sqncr;
tx_driver    tx_drvr ;
tx_monitor   tx_mntr ;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting tx_agent build phase__________", UVM_MEDIUM);
	tx_sqncr = tx_sequencer::type_id::create("tx_sqncr" , this);
	tx_drvr = tx_driver::type_id::create("tx_drvr" , this);
	tx_mntr = tx_monitor::type_id::create("tx_mntr" , this);
	`uvm_info(get_type_name(), "__________Ending tx_agent build phase__________", UVM_MEDIUM);
endfunction

//===============================
// Connect phase
//===============================
function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	`uvm_info(get_type_name(), "__________Starting tx_agent connect phase__________", UVM_MEDIUM);
	tx_drvr.seq_item_port.connect(tx_sqncr.seq_item_export);// connecting tx_sqncr and tx_drvr
	`uvm_info(get_type_name(), "__________Ending tx_agent connect phase__________", UVM_MEDIUM);
endfunction

endclass
