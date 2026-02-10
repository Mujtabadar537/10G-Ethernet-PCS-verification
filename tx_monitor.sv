////////////////////////////////////////////////////////////////////////////////
//
// Filename : tx_monitor.sv
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
// This monitor captures TX packets on PCS . 
//
// ///////////////////////////////////////////////////////////////////////////////

class tx_monitor extends uvm_monitor;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(tx_monitor)

//===============================
// Constructor
//===============================
function new(string name = "tx_monitor" , uvm_component parent = null);
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
uvm_analysis_port #(xgmii_seq_item) tx_analysis_port;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	// creating xgmi item
	xgmi_item = xgmii_seq_item::type_id::create("xgmi_item");
	
	// creating analysis port
	tx_analysis_port = new("tx_analysis_port" , this);
	
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
	`uvm_info(get_type_name() , "__________Starting main phase of tx monitor__________" , UVM_MEDIUM)
	forever begin
		sample_xgmi_frame();
		//tx_analysis_port.write(xgmi_item);// writing on tx analysis port
	end
	`uvm_info(get_type_name() , "__________Ending main phase of tx monitor__________" , UVM_MEDIUM)
endtask

//================================
// Task to sample tx xgmii frames
//================================
task sample_xgmi_frame();
	@(posedge xgmi_vif.TX_CLK iff (xgmi_vif.rstn_as_i /*&& xgmi_vif.VALID == 1 && xgmi_vif.SGNL_OK == 3*/));	
	//if(xgmi_vif.TXD[63:0] == 64'hD5555555555555FB) begin
	if(xgmi_vif.TXD[7:0] == 8'hFB) begin
		`uvm_info(get_type_name() , "=========================================================================" , UVM_MEDIUM)
		`uvm_info(get_type_name() , "                         XGMII MONITOR FOR TX-PCS"                         , UVM_MEDIUM)
		`uvm_info(get_type_name() , "=========================================================================" , UVM_MEDIUM)
		 xgmi_item.TXD = xgmi_vif.TXD;
		 xgmi_item.TXC = xgmi_vif.TXC;

		 xgmi_item.VALID = xgmi_vif.VALID;
		 xgmi_item.SGNL_OK = xgmi_vif.SGNL_OK;
		 xgmi_item.print_tx("TX_MONITOR" , UVM_MEDIUM);
		 tx_analysis_port.write(xgmi_item);
		`uvm_info(get_type_name() , $sformatf("Start control character (%0h) detected on link" , xgmi_vif.TXD[7:0]) , UVM_MEDIUM)
		`uvm_info(get_type_name() , $sformatf("Start of frame delimeter (%0h) detected on link" , xgmi_vif.TXD[63:56]) , UVM_MEDIUM)
		`uvm_info(get_type_name() , $sformatf("Premable (%0h) detected on link\n" , xgmi_vif.TXD[55:8]) , UVM_MEDIUM)
	end
	else if(xgmi_vif.TXD[39:32] == 8'hFB) begin
		`uvm_info(get_type_name() , "=========================================================================" , UVM_MEDIUM)
		`uvm_info(get_type_name() , "                         XGMII MONITOR FOR TX-PCS"                         , UVM_MEDIUM)
		`uvm_info(get_type_name() , "=========================================================================" , UVM_MEDIUM)	

		 xgmi_item.TXD = xgmi_vif.TXD;
		 xgmi_item.TXC = xgmi_vif.TXC;

		 xgmi_item.VALID = xgmi_vif.VALID;
		 xgmi_item.SGNL_OK = xgmi_vif.SGNL_OK;
		 xgmi_item.print_tx("TX_MONITOR" , UVM_MEDIUM);
		 tx_analysis_port.write(xgmi_item);
		`uvm_info(get_type_name() , $sformatf("Start control character (%0h) detected on link" , xgmi_vif.TXD[39:32]) , UVM_MEDIUM)
		//`uvm_info(get_type_name() , $sformatf("Start of frame delimeter (%0h) detected on link" , xgmi_vif.TXD[63:56]) , UVM_MEDIUM)
		//`uvm_info(get_type_name() , $sformatf("Premable (%0h) detected on link\n" , xgmi_vif.TXD[55:8]) , UVM_MEDIUM)
	end
	else if(xgmi_vif.TXC == 8'h00) begin
		 xgmi_item.TXD = xgmi_vif.TXD;
		 xgmi_item.TXC = xgmi_vif.TXC;

		 xgmi_item.VALID = xgmi_vif.VALID;
		 xgmi_item.SGNL_OK = xgmi_vif.SGNL_OK;
		 xgmi_item.print_tx("TX_MONITOR" , UVM_MEDIUM);
		 tx_analysis_port.write(xgmi_item);
		`uvm_info(get_type_name() , $sformatf("Payload is begin driven on link\n") , UVM_MEDIUM)
	end
	else if(xgmi_vif.TXD[7:0] == 8'hFD) begin
		 xgmi_item.TXD = xgmi_vif.TXD;
		 xgmi_item.TXC = xgmi_vif.TXC;

		 xgmi_item.VALID = xgmi_vif.VALID;
		 xgmi_item.SGNL_OK = xgmi_vif.SGNL_OK;
		 xgmi_item.print_tx("TX_MONITOR" , UVM_MEDIUM);
		 tx_analysis_port.write(xgmi_item);
		`uvm_info(get_type_name() , $sformatf("Terminate control character (%0h) dtected on link\n" , xgmi_vif.TXD[7:0]) , UVM_MEDIUM);
	end
	else begin
		`uvm_info(get_type_name() , "Link is idle..." , UVM_HIGH);
	end
endtask
endclass
