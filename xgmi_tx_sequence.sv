////////////////////////////////////////////////////////////////////////////////
//
// Filename : xgmi_tx_sequence.sv
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
// This sequence generates stimulus for XGMII . It sends complete xgmi frame in the
// following format sfd --> premable + /S/ --> payload --> /T/ .
//
// ///////////////////////////////////////////////////////////////////////////////

class xgmi_tx_sequence extends uvm_sequence#(xgmii_seq_item);

//===============================
// Factory registeration
//===============================
`uvm_object_utils(xgmi_tx_sequence)

//===============================
// Constructor
//===============================
function new(string name = "xgmi_tx_sequence");
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
int error_char;
int start_align;

logic [31:0] data_payload;

//===============================
// pre-body method
//===============================
task pre_body();
	// getting number of frames from config_db
	uvm_config_db#(int)::get(null, "", "frame_count", xgmii_frame_count);

	// getting payload size from config_db
	uvm_config_db#(int)::get(null, "", "payload_size", payload_size);

	// error_char should be 1 to drive error characters
	uvm_config_db#(int)::get(null, "", "error_char", error_char);

	// indicates position of start control character
	uvm_config_db#(int)::get(null, "", "start_align", start_align);
endtask

//=================================
// body method containing stimulus
//=================================
task body();
	`uvm_info(get_type_name(), "_________Starting xgmi tx sequence_________", UVM_MEDIUM)
	
	// Sending XGMII frames
	repeat(xgmii_frame_count) begin
    		// Sending preamble and SFD(start frame delimeter)
    		repeat(1) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
			if(start_align == 4) begin
        			//xgmi_frame.TXD = 64'hD555_55FB_0707_0707;  
        			//xgmi_frame.TXC = 8'b0001_1111;
				xgmi_frame.TXD = 64'h5555_55FB_0707_0707;  
        			xgmi_frame.TXC = 8'b0001_1111;
			end
			
			if(start_align == 0) begin
				xgmi_frame.TXD = 64'hD555_5555_5555_55FB;
        			xgmi_frame.TXC = 8'b0000_0001;
			end
        		//xgmi_frame.print_tx("XGMII_PREAMBLE_SFD" , UVM_HIGH);
        		finish_item(xgmi_frame);
    		end
		
    		// Payload
    		repeat(payload_size) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
			if(error_char == 0) begin
				data_payload = $urandom();
				xgmi_frame.TXD = {data_payload , 8'hD5 , 24'h555555};
				xgmi_frame.TXC = 8'b0000_0000;				

				//xgmi_frame.TXD = {$urandom() , $urandom()};
        			//xgmi_frame.TXC = 8'b0000_0000;
			end
			else begin
				xgmi_frame.TXD = 64'hFEFEFEFEFEFEFEFE;
				xgmi_frame.TXC = 8'b1111_1111;
			end
        		//xgmi_frame.print_tx("XGMII_PAYLOAD" , UVM_HIGH);
        		finish_item(xgmi_frame);
    		end

    		// Sending terminate control character
    		repeat(1) begin
        		xgmi_frame = xgmii_seq_item::type_id::create("xgmi_frame");
        		start_item(xgmi_frame);
        		xgmi_frame.TXD = 64'h0707_0707_0707_07FD;
        		xgmi_frame.TXC = 8'b1111_1111;
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
	`uvm_info(get_type_name(), "_________Ending xgmi tx sequence_________", UVM_MEDIUM)
endtask

endclass
