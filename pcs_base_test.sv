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
int error_char;
int start_align;

//===============================
// linkup_sequence handle
//===============================
linkup_sequence linkup_seq;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting pcs_base_test build phase__________", UVM_MEDIUM);
	// creating environment
	pcs10g_env = PCS_env::type_id::create("pcs10g_env" , this);

	// creating linkup_sequence
	linkup_seq = linkup_sequence::type_id::create("linkup_seq");

	if(!(uvm_config_db#(virtual xgmi_interface)::get(this, "", "xgmi_vif", xgmi_vif))) begin
      		`uvm_error(get_type_name(), "Failed to get virtual interface");
    	end
    	else begin
      		`uvm_info(get_type_name(), "Virtual interface recieved successfully", UVM_HIGH);
    	end
	
	// getting number of frames as argument
	$value$plusargs("FRAME_COUNT=%0d" , xgmii_frame_count);
	`uvm_info(get_type_name() , $sformatf("FRAME_COUNT has been set to %0d" , xgmii_frame_count) , UVM_MEDIUM);
	uvm_config_db#(int)::set(null , "*" , "frame_count" , xgmii_frame_count);

	// getting payload size in bytes as argument
	$value$plusargs("PAYLOAD_SIZE=%0d" , payload_size);
	`uvm_info(get_type_name() , $sformatf("PAYLOAD_SIZE is selected as %0d bytes" , (payload_size * 64)/8) , UVM_MEDIUM);
	uvm_config_db#(int)::set(null , "*" , "payload_size" , payload_size);

	// error_char should be 1 to drive error characters at TX
	$value$plusargs("ERROR_CHAR=%0d" , error_char);
	`uvm_info(get_type_name() , $sformatf("ERROR_CHAR is selected as %0d " , error_char) , UVM_MEDIUM);
	uvm_config_db#(int)::set(null , "*" , "error_char" , error_char);

	// START_ALIGNMENT can be 0 or 4 , indicating 1st and 5th octet of TXD respectively
	$value$plusargs("START_ALIGN=%0d" , start_align);
	`uvm_info(get_type_name() , $sformatf("START_ALIGNMENT is selected as %0d " , start_align) , UVM_MEDIUM);
	uvm_config_db#(int)::set(null , "*" , "start_align" , start_align);

	`uvm_info(get_type_name(), "__________Ending pcs_base_test build phase__________", UVM_MEDIUM);
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	super.main_phase(phase);
	phase.raise_objection(this);
		// starting linkup sequence 
		linkup_seq.start(pcs10g_env.tx_agnt.tx_sqncr);
	phase.drop_objection(this);
endtask

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
