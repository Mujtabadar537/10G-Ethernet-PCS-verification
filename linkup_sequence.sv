////////////////////////////////////////////////////////////////////////////////
//
// Filename : linkup_sequence.sv
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
// This sequence establishes the link by sending idle frames .
//
// ///////////////////////////////////////////////////////////////////////////////

class linkup_sequence extends uvm_sequence#(xgmii_seq_item);

//===============================
// Factory registeration
//===============================
`uvm_object_utils(linkup_sequence)

//===============================
// Constructor
//===============================
function new(string name = "linkup_sequence");
	super.new(name);
endfunction

//===============================
// XGMI sequence item handle
//===============================
xgmii_seq_item xgmi_frame;

//=================================
// body method containing stimulus
//=================================
task body();
	`uvm_info(get_type_name(), "_________Starting linkup_sequence_________", UVM_MEDIUM)
	// Establishing link between TX and RX
	repeat(2000) begin
		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
		
		//inter frame
		start_item(xgmi_frame);
		xgmi_frame.TXD = 64'h0707_0707_0707_0707;
		xgmi_frame.TXC = 8'b1111_1111;
		xgmi_frame.print_tx("XGMII_IDLE" , UVM_HIGH);
		finish_item(xgmi_frame);
	end
	`uvm_info(get_type_name(), "_________Ending linkup_sequence_________", UVM_MEDIUM)
endtask

endclass
