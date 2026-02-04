////////////////////////////////////////////////////////////////////////////////
//
// Filename : pcs_base_test.sv
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
// Base test class for 10G-PCS 
//
// ///////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

class pcs_base_test extends uvm_test;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(pcs_base_test)

//===============================
// Constructor
//===============================
function new(string name = "pcs_base_test" , uvm_component parent);
	super.new(name , parent);
endfunction

//===============================
// 10G-PCS environment instance
//===============================
PCS_env pcs10g_env;

//===============================
// Virtual interface handle
//===============================
virtual xgmi_interface xgmi_vif;

//===============================
// Argument variables
//===============================
int xgmii_frame_count;
int payload_size;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting pcs_base_test build phase__________", UVM_MEDIUM);
	// creating environment
	pcs10g_env = PCS_env::type_id::create("pcs10g_env" , this);

	// getting virtual interface
	if(!(uvm_config_db#(virtual xgmi_interface)::get(this, "", "xgmi_vif", xgmi_vif))) begin
      		`uvm_error(get_type_name(), "Failed to get virtual interface");
    	end
    	else begin
      		`uvm_info(get_type_name(), "Virtual interface recieved successfully", UVM_HIGH);
    	end
	
	// getting number of frames as argument
	$value$plusargs("FRAME_COUNT=%0d" , xgmii_frame_count);
	`uvm_info(get_type_name() , $sformatf("FRAME_COUNT has been set to %0d" , xgmii_frame_count) , UVM_MEDIUM);
	// setting number of frames in config_db
	uvm_config_db#(int)::set(null , "*" , "frame_count" , xgmii_frame_count);

	// getting payload size in bytes as argument
	$value$plusargs("PAYLOAD_SIZE=%0d" , payload_size);
	`uvm_info(get_type_name() , $sformatf("PAYLOAD_SIZE is selected as %0d bytes" , (payload_size * 64)/8) , UVM_MEDIUM);
	// setting number of frames in config_db
	uvm_config_db#(int)::set(null , "*" , "payload_size" , payload_size);

	`uvm_info(get_type_name(), "__________Ending pcs_base_test build phase__________", UVM_MEDIUM);
endfunction

//===============================
// Reset phase
//===============================
task reset_phase(uvm_phase phase);
	`uvm_info(get_type_name(), "__________Starting pcs_base_test reset phase__________", UVM_MEDIUM);
	super.reset_phase(phase);
	phase.raise_objection(this);
	xgmi_vif.TXD = 64'h0707_0707_0707_0707;
	xgmi_vif.TXC = 8'hFF;
	xgmi_vif.VALID = 1;
	xgmi_vif.SGNL_OK = 2'b00;
	phase.drop_objection(this);
	`uvm_info(get_type_name(), "__________Ending pcs_base_test reset phase__________", UVM_MEDIUM);
endtask

endclass
