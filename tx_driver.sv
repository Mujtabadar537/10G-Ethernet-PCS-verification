////////////////////////////////////////////////////////////////////////////////
//
// Filename : tx_driver.sv
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
// Driver class for XGMII interface .  
//
// ///////////////////////////////////////////////////////////////////////////////

class tx_driver extends uvm_driver#(xgmii_seq_item);

//===============================
// Factory registeration
//===============================
`uvm_component_utils(tx_driver)

//===============================
// Constructor
//===============================
function new(string name = "tx_driver" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Virutal interface handle
//===============================
virtual xgmi_interface xgmi_vif;

//===============================
// XGMI sequence item handle
//===============================
xgmii_seq_item xgmi_frame;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting tx_driver build phase__________", UVM_MEDIUM);
	// getting virtual interfce
	if(!(uvm_config_db#(virtual xgmi_interface)::get(this, "", "xgmi_vif", xgmi_vif))) begin
      		`uvm_error(get_type_name(), "Failed to get virtual interface");
    	end
    	else begin
      		`uvm_info(get_type_name(), "Virtual interface recieved successfully", UVM_HIGH);
    	end
	`uvm_info(get_type_name(), "__________Ending tx_driver build phase__________", UVM_MEDIUM);
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	super.main_phase(phase);
	`uvm_info(get_type_name() , "__________Starting main phase of tx driver__________" , UVM_MEDIUM)
	
	forever begin
		seq_item_port.get_next_item(xgmi_frame);
		wait_for_ready();
		xgmi_frame_drive(xgmi_frame);
		seq_item_port.item_done();
	end
	`uvm_info(get_type_name() , "__________Ending main phase of tx driver__________" , UVM_MEDIUM)
endtask

//=====================================================
// Waiting for ready , so tx_gb_fifo does'nt overflow  
//=====================================================
virtual task wait_for_ready();
    // As soon as ready is deasserted we also deassert valid
    // to ensure that no valid data is driven by xgmii driver
    while (xgmi_vif.READY !== 1) begin
        xgmi_vif.VALID <= 0; // Deassert valid while waiting
        @(posedge xgmi_vif.TX_CLK);
    end
endtask


//===============================
// Driving logic 
//===============================
virtual task xgmi_frame_drive(xgmii_seq_item xgmi_frame);
	@(posedge xgmi_vif.TX_CLK iff xgmi_vif.rstn_as_i);
	xgmi_vif.TXD <= xgmi_frame.TXD;
	xgmi_vif.TXC <= xgmi_frame.TXC;
	xgmi_vif.VALID <= 1;
	xgmi_vif.SGNL_OK <= 2'b11;
endtask

endclass
