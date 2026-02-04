////////////////////////////////////////////////////////////////////////////////
//
// Filename : xgmii_seq_item.sv
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
// Sequence item for XGMII 
//
// ///////////////////////////////////////////////////////////////////////////////

class xgmii_seq_item extends uvm_sequence_item;

//======================
// XGMII item
//======================
rand logic [63:0]      TXD;
logic 	   [ 7:0]      TXC;
logic      [ 1:0]  SGNL_OK;
logic                VALID;
logic  		      LOCK;

logic      [63:0]      RXD;
logic      [ 7:0]      RXC;
logic     [ 63:0]   serdes;


//======================
// UVM Object Utilities
//======================
`uvm_object_utils_begin(xgmii_seq_item)
        `uvm_field_int(TXD    , UVM_HEX+UVM_ALL_ON);
	`uvm_field_int(TXC    , UVM_HEX+UVM_ALL_ON);
	`uvm_field_int(RXD    , UVM_HEX+UVM_ALL_ON);
	`uvm_field_int(RXC    , UVM_HEX+UVM_ALL_ON);
	`uvm_field_int(serdes , UVM_HEX+UVM_ALL_ON);
`uvm_object_utils_end

//===============================
// Constructor
//===============================
function new(string name = "xgmii_seq_item");
	super.new(name);
endfunction

//==================================
// Functions to print sequence item
//==================================
function void print_tx(string tag, int verbosity);
      `uvm_info(tag, "--------------------------------------------", verbosity)
      `uvm_info(tag, "                  TX-XGMII FRAME              ", verbosity)
      `uvm_info(tag, "--------------------------------------------", verbosity)

      `uvm_info(tag, $sformatf("TXD___________0x%0h", TXD),   verbosity)
      `uvm_info(tag, $sformatf("TXC___________0x%0h", TXC),   verbosity)
      `uvm_info(tag, $sformatf("SIGNAL_OK___________0x%0h", SGNL_OK),   verbosity)
      `uvm_info(tag, $sformatf("VALID___________0x%0h", VALID),   verbosity)
endfunction

function void print_rx(string tag, int verbosity);
      `uvm_info(tag, "--------------------------------------------", verbosity)
      `uvm_info(tag, "                  RX-XGMII FRAME              ", verbosity)
      `uvm_info(tag, "--------------------------------------------", verbosity)

      `uvm_info(tag, $sformatf("RXD___________0x%0h", RXD),   verbosity)
      `uvm_info(tag, $sformatf("RXC___________0x%0h", RXC),   verbosity)
endfunction

endclass
