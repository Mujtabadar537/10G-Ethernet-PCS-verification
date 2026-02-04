//////////////////////////////////////////////////////////////////////////////////
//
// Filename : rxpcs_ref_model.sv
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
// rxpcs_ref_model implements behaviorial model for a rx_gearbox , descrambler
// and a decoder that takes data from SerDes and generates expected XGMII output  .
// /////////////////////////////////////////////////////////////////////////////////

`uvm_analysis_imp_decl(_serdes)

class rxpcs_ref_model extends uvm_scoreboard;

//===============================
// Factory registeration
//===============================
`uvm_component_utils(rxpcs_ref_model)

//===============================
// Constructor
//===============================
function new(string name = "rxpcs_ref_model" , uvm_component parent = null);
	super.new(name , parent);
endfunction

//===============================
// Analysis implementation ports
//===============================
uvm_analysis_imp_serdes#(xgmii_seq_item , rxpcs_ref_model) serdes_analysis_imp_port;

//===================================
// Queue to store serdes data
//===================================
xgmii_seq_item serdes_queue[$];

//===================================
// seq_item to store cloned data
//===================================
xgmii_seq_item serdes_clone;

virtual debug_interface debug_vif;

//===============================
// Build phase
//===============================
function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	`uvm_info(get_type_name(), "__________Starting rxpcs_ref_model build phase__________", UVM_MEDIUM);	
	
	// getting debug interface here just to see some signals in waveform
	uvm_config_db#(virtual debug_interface)::get(this , "" , "debug_vif" , debug_vif);	

	//creating analysis implementation ports
	serdes_analysis_imp_port = new("serdes_analysis_imp_port" , this);

	`uvm_info(get_type_name(), "__________Ending rxpcs_ref_model build phase__________", UVM_MEDIUM);
endfunction

//====================================
// Write functions for analysis ports
//====================================
function void write_serdes(xgmii_seq_item serdes);
	$cast(serdes_clone , serdes.clone());
	serdes_queue.push_back(serdes_clone);
endfunction


//======================================
// Outputs and variables for PCS blocks
//======================================
bit [ 66:0] gearbox_out;// 66 bit output of gearbox
bit [ 63:0] descrambler_out;// 64 bit output of desrambler
bit [  1:0] synch;// variable to store sync header before passing it to descrambler
bit [ 63:0] decoder_out; // output of decoder indicating expected RXD of XGMII


//===============================
// Main phase
//===============================
task main_phase(uvm_phase phase);
	xgmii_seq_item serdes_seq_item;

	forever begin
		// waiting for serdes_queue to be populated
		wait(serdes_queue.size() > 0);

		// popping queues in seq_item variables
		serdes_seq_item = serdes_queue.pop_front();	
	
		// processing SerDes data 
		if(receiver_gearbox(serdes_seq_item, gearbox_out)) begin
			synch = gearbox_out[1:0];
			debug_vif.sync_header = synch;// driving on debug interface for debugging only

    			descrambler(gearbox_out[65:2] , descrambler_out);
			//`uvm_info("data_block" , $sformatf("Descrambled output = %h" , {descrambler_out , synch}) , UVM_MEDIUM)
			decoder({descrambler_out , synch} , decoder_out);
		end
	end
endtask


//=================================
// Behavorial model for RX-GEARBOX
//=================================
bit [127:0] bit_accum;// buffer to store 128 bits of incoming data
int         accum_cnt;// counter to accumulate next 64 bits
bit         block_lock;// flag to indicate that lock is achieved
int         sync_hdr_cnt = 0;// counter to count valid sync headers
typedef bit [127 : 0] bit128_t;// user defined bit , used to type cast 64 bit serdes data to 128 bit to prevent any loss of data 

function bit receiver_gearbox(xgmii_seq_item itm, output bit [65:0] block_out);
    // Storing the data in 128 bit buffer
    bit_accum |= (bit128_t'(itm.serdes) << accum_cnt);
    accum_cnt += 64;

    // Checking only when data is 66bits or greater in bit_accum
    while (accum_cnt >= 66) begin
        if (!block_lock) begin
            // Detecting valid sync headers
            if (bit_accum[1:0] == 2'b01 || bit_accum[1:0] == 2'b10) begin
                sync_hdr_cnt++; 
                if (sync_hdr_cnt >= 64) begin
                    `uvm_info("receiver_gearbox" , "Lock achieved", UVM_MEDIUM) 
                    block_lock = 1;
                end
                
                // Extract this potential block and slide 66 bits
                block_out = bit_accum[65:0];
                bit_accum >>= 66;
                accum_cnt -= 66;
		//`uvm_info(get_type_name(), $sformatf("Block_out = %h", block_out), UVM_MEDIUM)
                return 1; // Found a valid header
	
            end 
	    // Slipping logic
	    else begin
                // SLIP 1 BIT: The header was invalid, slide and try again
                sync_hdr_cnt = 0; 
                bit_accum >>= 1;
                accum_cnt -= 1;
                // Loop continues to check next bit alignment
            end
        end 

	// Lock mode
        else begin
            block_out = bit_accum[65:0];
            //`uvm_info(get_type_name(), $sformatf("Gearbox_out = %h", block_out), UVM_MEDIUM)
            bit_accum >>= 66;
            accum_cnt -= 66;
            return 1; 
        end
    end

    return 0; // Waiting for more data
endfunction


//==================================
// Behavorial model for DESCRAMBLER
//==================================
// Shift register for the descrambler
bit [57:0] desc_state; 

function bit [63:0] descrambler(bit [63:0] scrambled_in , output logic [63:0] descrambled_out);
	for (int i = 0; i < 64; i++) begin
        	// XOR current bit with bits at taps 39 and 58
        	descrambled_out[i] = scrambled_in[i] ^ desc_state[38] ^ desc_state[57];
        	// Update state with the incoming scrambled bit
        	desc_state = {desc_state[56:0], scrambled_in[i]};
    	end
	//`uvm_info("data_block" , $sformatf("Descrambled output = %h" , descrambled_out) , UVM_MEDIUM)
    	return descrambled_out;
endfunction


//==================================
// Behavorial model for DECODER
//==================================
function void decoder(bit [65:0]descrambled_in , output logic [63:0] RXD_ex);
	//`uvm_info("decoder" , $sformatf("Decoder_in = %h" , descrambled_in) , UVM_MEDIUM)
	
	// check for block field type 0x1E , indicating all control blocks
	if(descrambled_in[9:2] == 8'h1E) begin
		if(synch != 2'b10) begin
			`uvm_error("decoder" , "Invalid syncheader recevied")
			`uvm_error("decoder" , $sformatf("Block_type_field = %0h  |  synch = %b\n" ,descrambled_in[9:2] , descrambled_in[1:0]));

		end
		else if(synch == 2'b10) begin
			RXD_ex = 64'h0707070707070707;
			`uvm_info("decoder" , $sformatf("RXD_expected = %0h" , RXD_ex) , UVM_MEDIUM);
			`uvm_info("decoder" , $sformatf("Block_type_field = %0h  |  synch = %b\n" ,descrambled_in[9:2] , descrambled_in[1:0]) , UVM_MEDIUM);
		end
	end
	
	// check for block field type 0x78 , indicating /S/ 
	else if(descrambled_in[9:2] == 8'h78) begin
		if(synch == 2'b01) begin
			`uvm_error("decoder" , "Invalid syncheader recevied")
			`uvm_error("decoder" , $sformatf("Block_type_field = %h  |  synch = %b\n" ,descrambled_in[9:2] , descrambled_in[1:0]));
		end
		else if(synch == 2'b10) begin
			`uvm_info("decoder" , "Start of frame (/S/) at [7:0] detected ." , UVM_MEDIUM)
			`uvm_info("decoder" , $sformatf("Block_type_field = %h  |  synch = %b" ,descrambled_in[9:2] , descrambled_in[1:0]) , UVM_MEDIUM);
			`uvm_info("decoder" , $sformatf("66b_block = %h" ,descrambled_in) , UVM_MEDIUM);
			RXD_ex = (descrambled_in >> 2);// removing synch
			RXD_ex[7:0] = 8'hFB;// xgmii code for /S/
			`uvm_info("decoder" , $sformatf("RXD_ex = %h\n" ,RXD_ex) , UVM_MEDIUM);
		end
	end

	// check for block field type 0x87 , indicating /T/ 
	else if(descrambled_in[9:2] == 8'h87) begin
		if(synch == 2'b10) begin
			`uvm_error("decoder" , "Invalid syncheader recevied")
			`uvm_error("decoder" , $sformatf("Block_type_field = %h  |  synch = %b\n" ,descrambled_in[9:2] , descrambled_in[1:0]));
		end
		else if(synch == 2'b01) begin
			`uvm_info("decoder" , "Terminate character (/T/) at [7:0] detected ." , UVM_MEDIUM)
			`uvm_info("decoder" , $sformatf("Block_type_field = %h  |  synch = %b\n" ,descrambled_in[9:2] , descrambled_in[1:0]) , UVM_MEDIUM);
			`uvm_info("decoder" , $sformatf("66b_block = %h" ,descrambled_in) , UVM_MEDIUM);
			RXD_ex = (descrambled_in >> 2);// removing synch
			RXD_ex[7:0] = 8'hFD;// xgmii code for /T/
			RXD_ex[63:8] = 57'h07070707070707;
			`uvm_info("decoder" , $sformatf("RXD_ex = %h\n" ,RXD_ex) , UVM_MEDIUM);
		end
	end

	// check for sync header 01 , indicating payload
	else if(synch == 2'b01) begin
		`uvm_info("decoder" , $sformatf("66b_block = %h" ,descrambled_in) , UVM_MEDIUM);
		RXD_ex = (descrambled_in >> 2);// removing synch
		`uvm_info("decoder" , $sformatf("RXD_ex = %h\n" ,RXD_ex) , UVM_MEDIUM);
	end
endfunction


endclass
