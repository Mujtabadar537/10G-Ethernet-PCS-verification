////////////////////////////////////////////////////////////////////////////////
//
// Filename : tx_sequencer.sv
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
// tx_sequecner for driving PCS-TX stimulus 
//
// ///////////////////////////////////////////////////////////////////////////////

class tx_sequencer extends uvm_sequencer#(xgmii_seq_item);

//===============================
// Factory registeration
//===============================
`uvm_component_utils(tx_sequencer)

//===============================
// Constructor
//===============================
function new(string name = "tx_sequencer" , uvm_component parent = null);
	super.new(name , parent);
endfunction

endclass