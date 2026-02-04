////////////////////////////////////////////////////////////////////////////////
//
// Filename : rx_agent.sv
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
// rx_agent is passive in nature and will only capture the RX-PCS packets 
// for monitoring .
//
// ///////////////////////////////////////////////////////////////////////////////

class rx_agent extends uvm_agent;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(rx_agent)

//===============================
// Constructor
//===============================
function new(string name = "rx_agent" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Agent components
//===============================
rx_monitor rx_mntr;
serdes_monitor serdes_mntr;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting rx_agent build phase__________", UVM_MEDIUM);
	rx_mntr = rx_monitor::type_id::create("rx_mntr" , this);
	serdes_mntr = serdes_monitor::type_id::create("serdes_mntr" , this);
	`uvm_info(get_type_name(), "__________Ending rx_agent build phase__________", UVM_MEDIUM);
endfunction


//===============================
// Connect phase
//===============================
function void connect_phase(uvm_phase phase);
	super.connect_phase(phase);
endfunction

endclass
