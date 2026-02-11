////////////////////////////////////////////////////////////////////////////////
//
// Filename : pcs_uvm_package.sv
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
// Package contaning UVM files for 10G-PCS 
//
// ///////////////////////////////////////////////////////////////////////////////

package pcs_uvm_package;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	// UVM files
	`include "xgmii_seq_item.sv"
	`include "linkup_sequence.sv"
	`include "xgmi_tx_sequence.sv"
	`include "xgmii_terminate_char_sequence.sv"
	`include "tx_sequencer.sv"
	`include "tx_driver.sv"
	`include "tx_monitor.sv"
	`include "tx_agent.sv"
	`include "rx_monitor.sv"
	`include "serdes_monitor.sv"
	`include "rx_agent.sv"
	`include "rxpcs_ref_model.sv"
	`include "pcs_scoreboard.sv"
	`include "PCS_env.sv"
	`include "pcs_base_test.sv"
	`include "pcs_tx_rx_datapath_test.sv"
endpackage
