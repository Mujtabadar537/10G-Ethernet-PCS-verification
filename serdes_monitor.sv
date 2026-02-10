////////////////////////////////////////////////////////////////////////////////
//
// Filename : serdes_monitor.sv
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
// This monitor captures SerDes data on PCS . 
//
// ///////////////////////////////////////////////////////////////////////////////

class serdes_monitor extends uvm_monitor;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(serdes_monitor)

//===============================
// Constructor
//===============================
function new(string name = "serdes_monitor" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Virutal interface handle
//===============================
virtual xgmi_interface xgmi_vif;

//===============================
// XGMI sequence item handle
//===============================
xgmii_seq_item xgmi_item;

//===================================================
// Analysis port for sending TX frames to scoreboard
//===================================================
uvm_analysis_port #(xgmii_seq_item) serdes_analysis_port;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	// creating xgmi item
	xgmi_item = xgmii_seq_item::type_id::create("xgmi_item");
	
	// creating analysis port
	serdes_analysis_port = new("serdes_analysis_port" , this);
	
	// getting vitual interface
	if(!uvm_config_db#(virtual xgmi_interface)::get(this , "" , "xgmi_vif" , xgmi_vif)) begin
		`uvm_error(get_type_name(), "Failed to get virtual interface");
    	end
    	else begin
      		`uvm_info(get_type_name(), "Virtual interface recieved successfully", UVM_HIGH);
    	end
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	super.main_phase(phase);
	`uvm_info(get_type_name() , "__________Starting main phase of serdes_monitor__________" , UVM_MEDIUM)
	forever begin
		sample_serdes_data();
	end
	`uvm_info(get_type_name() , "__________Ending main phase of serdes_monitor__________" , UVM_MEDIUM)
endtask

//================================
// Task to sample serdes data
//================================
task sample_serdes_data();
	@(posedge xgmi_vif.TX_CLK iff xgmi_vif.rstn_as_i);
	xgmi_item.serdes = xgmi_vif.serdes;
	//`uvm_info(get_type_name() , $sformatf("SERDES_DATA = %0h" , xgmi_item.serdes) , UVM_MEDIUM)
	serdes_analysis_port.write(xgmi_item);// writing to analysis port
endtask

endclass
