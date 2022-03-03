`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:28:25 03/19/2013 
// Design Name: 
// Module Name:    NERP_demo_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module NERP_demo_top(
	input wire clk,			//master clock = 50MHz
	input wire clr,			//right-most pushbutton for reset
    input btnd,
	input btnr,
    input btnl,
    input btnu,
	output wire [6:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
	output wire dp,			//7-segment display decimal point
	output wire [2:0] red,	//red vga output - 3 bits
	output wire [2:0] green,//green vga output - 3 bits
	output wire [1:0] blue,	//blue vga output - 2 bits
	output wire hsync,		//horizontal sync out
	output wire vsync			//vertical sync out
	);

// 7-segment clock interconnect
wire segclk;

// VGA display clock interconnect
wire dclk;

// disable the 7-segment decimal points
assign dp = 1;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.segclk(segclk),
	.dclk(dclk)
	);

// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.seg(seg),
	.an(an)
	);
	
wire [6:0] display;
assign display = 7'b0100010;
wire [2:0] row;
wire [2:0] col;
assign row = 0;
assign col = 0;

//Start game
//choose word 
reg [2:0] col=0;
reg [2:0] row=0;
reg [6:0] DISPLAY [0:5] [0:6];
reg submitted =0;
reg [6:0] value;
while(submitted==0) begin //use clock instead
	selectionStage select(
		.clk(clk),
		.btnd(btnd),
		.btnr(btnr),
		.btnl(btnl),
		.btnu(btnu),
		.colIn(col),
		.rowValues(DISPLAY[row]),
		.columnOut(col),
		.submitted(submitted),
		.value(value)
	);
	DISPLAY[row][value]=value;
	//display this
end
//check if correct
//if not correct and last row - end game
//if not correct and not last row - go back selectionStage
//if correct end game
// VGA controller
vga640x480 U3(
	.dclk(dclk),
	.clr(clr),
	.display(display),
	.row(row),
	.col(col),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);

endmodule
