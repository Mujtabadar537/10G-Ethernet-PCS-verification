////////////////////////////////////////////////////////////////////////////////
//
// Filename : xgmii_terminate_char_sequence.sv
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
// This sequence sends terminate character one by one on every octet of TXD .
//
// ///////////////////////////////////////////////////////////////////////////////

class xgmii_terminate_char_sequence extends uvm_sequence#(xgmii_seq_item);

//===============================
// Factory registeration
//===============================
`uvm_object_utils(xgmii_terminate_char_sequence)

//===============================
// Constructor
//===============================
function new(string name = "xgmii_terminate_char_sequence");
	super.new(name);
endfunction

//===============================
// XGMI sequence item handle
//===============================
xgmii_seq_item xgmi_frame;

//===============================
// Argument variables
//===============================
int xgmii_frame_count;
int payload_size;

//===============================
// Pre-body method
//===============================
task pre_body();
	// getting number of frames from config_db
	uvm_config_db#(int)::get(null, "", "frame_count", xgmii_frame_count);

	// getting payload size from config_db
	uvm_config_db#(int)::get(null, "", "payload_size", payload_size);
endtask


//=================================
// Body method containing stimulus
//=================================
task body();
	`uvm_info(get_type_name(), "_________Starting xgmi_terminate_char_sequence_________", UVM_MEDIUM)

	// Sending XGMII frames
	repeat(xgmii_frame_count) begin
    		// Sending preamble and SFD(start frame delimeter)
    		repeat(1) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
			xgmi_frame.TXD = 64'hD555_5555_5555_55FB;
        		xgmi_frame.TXC = 8'b0000_0001;
        		finish_item(xgmi_frame);
    		end
			
		// Payload in case of start character at 1st octet
    		repeat(payload_size) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);			
			xgmi_frame.TXD = {$urandom() , $urandom()};
        		xgmi_frame.TXC = 8'b0000_0000;
        		//xgmi_frame.print_tx("XGMII_PAYLOAD" , UVM_HIGH);
        		finish_item(xgmi_frame);
    		end

    		// Sending terminate control character
    		repeat(1) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
        		xgmi_frame.TXD = 64'h0707_0707_0707_FDDE;
        		xgmi_frame.TXC = 8'b1111_1110;
        		//xgmi_frame.print_tx("XGMII_EFD" , UVM_HIGH);
        		finish_item(xgmi_frame);
    		end

    		// Making the link idle again after terminate control character
    		repeat(30) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
        		xgmi_frame.TXD = 64'h0707_0707_0707_0707;
        		xgmi_frame.TXC = 8'b1111_1111;
        		//xgmi_frame.print_tx("XGMII_IDLE" , UVM_HIGH);
        		finish_item(xgmi_frame);
    		end
	end

	`uvm_info(get_type_name(), "_________Ending xgmi_terminate_char_sequence_________", UVM_MEDIUM)
endtask

endclass
