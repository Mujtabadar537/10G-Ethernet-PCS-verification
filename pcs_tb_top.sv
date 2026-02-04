////////////////////////////////////////////////////////////////////////////////
//
// Filename : pcs_tb_top.sv
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
// This file is testbench top for 10G-PCS UVM verification environment 
//
// ///////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

`include "debug_interface.sv"
`include "xgmi_interface.sv"
`include "pcs_uvm_package.sv"

module pcs_tb_top;

//===============================
// Importing packages
//===============================
import uvm_pkg::*;
import pcs_uvm_package::*;
`include "uvm_macros.svh"

//===============================
// Clocks and resets declaration
//===============================
logic mac_clk_i   ;
logic serdes_clk_i;
logic rstn_as_i   ;
logic miiswrst    ;

//===============================
// XGMI interface instance
//===============================
xgmi_interface xgmi_vif(
	.TX_CLK(mac_clk_i) , 
	.rstn_as_i(rstn_as_i)
);

debug_interface debug_vif();


//=====================================
// Wire to connect SerDes in loopback
//=====================================
logic [63:0] SerDes_loopback;

//===============================
// Initializing clocks
//===============================
initial begin
	mac_clk_i = 0;
	serdes_clk_i = 0;
end

//===============================
// Applying reset
//===============================
initial begin
	rstn_as_i = 0;
	miiswrst  = 1;
	#20
	rstn_as_i = 1;
	miiswrst  = 0;
end

//===============================
// Driving clocks
//===============================
always #1 mac_clk_i    = ~mac_clk_i   ;
always #1 serdes_clk_i = ~serdes_clk_i;

//===============================
// Instantiating 10G-PCS 
//===============================
umac10l1p5c1 PCS10G_inst (
    // Inputs
    .mac_clk_i               (       mac_clk_i),
    .rstn_as_i               (       rstn_as_i),
    .serdes_clk_i            (    serdes_clk_i),
    .txphy_miiswrst_mc_i     (        miiswrst),
    .txphy_miictrl_mc_i      (    xgmi_vif.TXC),
    .txphy_miidata_mc_i      (    xgmi_vif.TXD),
    .txphy_miivld_mc_i       (  xgmi_vif.VALID),
    .rxphy_serdesdata0_rc0_i ( xgmi_vif.serdes),
    .rxphy_serdessigok_as_i  (xgmi_vif.SGNL_OK),

    // Outputs
    .txphy_serdesdata0_tc0_o ( xgmi_vif.serdes),
    .rxphy_miiswrst_mc_o     (                ),
    .rxphy_miictrl_mc_o      (    xgmi_vif.RXC),
    .rxphy_miidata_mc_o      (    xgmi_vif.RXD),
    .rxphy_miivld_mc_o       (xgmi_vif.RXVALID),
    .rxphy_miilock_mc_o      (   xgmi_vif.LOCK),
    .txphy_miirdy_mc_o       (  xgmi_vif.READY)
);


//=================================
// Setting virtual xgmi interface
//=================================
initial begin
	uvm_config_db#(virtual xgmi_interface)::set(null , "*" , "xgmi_vif" , xgmi_vif);
	uvm_config_db#(virtual debug_interface)::set(null , "*" , "debug_vif" , debug_vif);
end

//===============================
// Running test case 
//===============================
initial begin
	run_test();
end

//===============================
// Dumping vcd 
//===============================
initial begin
	$dumpfile("wave_dump.vcd");
	$dumpvars(0 , pcs_tb_top , pcs_tb_top.PCS10G_inst);
end

endmodule
