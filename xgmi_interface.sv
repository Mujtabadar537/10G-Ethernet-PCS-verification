////////////////////////////////////////////////////////////////////////////////
//
// Filename : xgmi_interface.sv
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
// XGMII (10G Media Indpendent Interface) 
// SerDes interface
//
// ///////////////////////////////////////////////////////////////////////////////

interface xgmi_interface(input logic TX_CLK , input logic rstn_as_i);

logic [ 63:0]     TXD;// transmit data
logic [  7:0]     TXC;// transmit control
logic [ 63:0]     RXD;// receive data
logic [  7:0]     RXC;// recevie control
logic [  1:0] SGNL_OK;// status of SerDes
logic           VALID;// data and control valid

logic 	      RXVALID;// valid data on RX
logic            LOCK;// lock state of RX
logic           READY;// tells when PCS is ready to accept valid data

logic [ 63:0]  serdes;// SerDes connection 
endinterface
