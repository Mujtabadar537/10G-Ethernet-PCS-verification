////////////////////////////////////////////////////////////////////////////////
//
// Filename : pcs_scoreboard.sv
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
// pcs_scoreboard receives packets from both tx and rx monitors and compare the
// TX and RX frames to ensure frame integrity of PCS .
//
// ///////////////////////////////////////////////////////////////////////////////
`uvm_analysis_imp_decl(_tx)
`uvm_analysis_imp_decl(_rx)

class pcs_scoreboard extends uvm_scoreboard;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(pcs_scoreboard)

//===============================
// Constructor
//===============================
function new(string name = "pcs_scoreboard" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Analysis implementation ports
//===============================
uvm_analysis_imp_tx#(xgmii_seq_item , pcs_scoreboard) tx_analysis_imp_port;
uvm_analysis_imp_rx#(xgmii_seq_item , pcs_scoreboard) rx_analysis_imp_port;

//===================================
// Queues to store TX and RX packets
//===================================
xgmii_seq_item tx_queue[$];
xgmii_seq_item rx_queue[$];

xgmii_seq_item tx_clone;
xgmii_seq_item rx_clone;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting pcs_scoreboard build phase__________", UVM_MEDIUM);	

	//creating analysis implementation ports
	tx_analysis_imp_port = new("tx_analysis_port" , this);
	rx_analysis_imp_port = new("rx_analysis_imp_port" , this);

	`uvm_info(get_type_name(), "__________Ending pcs_scoreboard build phase__________", UVM_MEDIUM);
endfunction

//====================================
// Write functions for analysis ports
//====================================
function void write_tx(xgmii_seq_item xgmii_tx);
	$cast(tx_clone , xgmii_tx.clone());
	tx_queue.push_back(tx_clone);
endfunction

function void write_rx(xgmii_seq_item xgmii_rx);
	$cast(rx_clone , xgmii_rx.clone());
	rx_queue.push_back(rx_clone);
endfunction

//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	//super.main_phase(phase);
	
	xgmii_seq_item tx_seq_item;
	xgmii_seq_item rx_seq_item;

	forever begin
		//`uvm_info(get_type_name() , "Waiting for TX and RX queues to be populated" , UVM_HIGH);
		wait(tx_queue.size() > 0 && rx_queue.size() > 0);
		//`uvm_info(get_type_name() , "TX and RX queues are populated" , UVM_HIGH);

		// popping queues in seq_item variables
		tx_seq_item = tx_queue.pop_front();
		rx_seq_item = rx_queue.pop_front();	
		frame_comparison(tx_seq_item , rx_seq_item);	
	end
endtask


//=========================================
// Comaprison of actual and expected data
//=========================================
task frame_comparison(xgmii_seq_item TX , xgmii_seq_item RX);
	if(RX.RXD == TX.TXD) begin
		`uvm_info("MATCH" , $sformatf("Expected data = %0h" , TX.TXD) , UVM_NONE);
		`uvm_info("MATCH" , $sformatf("Actual   data = %0h" , RX.RXD) , UVM_NONE);
	end
	else if(RX.RXD == 64'hFEFEFEFEFEFEFEFE) begin
		`uvm_error("ERROR_CHARACTER" , "Error characters received on RXD")
	end
	else begin
		`uvm_info("MISMATCH" , $sformatf("Expected data = %0h" , TX.TXD) , UVM_NONE);
		`uvm_info("MISMATCH" , $sformatf("Actual   data = %0h" , RX.RXD) , UVM_NONE);
	end
endtask




endclass
