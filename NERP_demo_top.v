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
	input wire clr,			//center pushbutton for reset
   input btnd,
	input btnr,
   input btnl,
   input btnu,
	output wire [7:0] seg,	//7-segment display LEDs
	output wire [3:0] an,	//7-segment display anode enable
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

// slow down logic clock
wire logicclk;

// generate 7-segment clock & display clock
clockdiv U1(
	.clk(clk),
	.clr(clr),
	.logicclk(logicclk),
	.segclk(segclk),
	.dclk(dclk)
	);

/*
// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.seg(seg),
	.an(an)
	); */

// These values maintained by top
reg [2:0] row;
reg [34:0] display [0:5];
reg [1:0] current_state;
reg[6:0] word_index;

// These values maintained by selectionStage
wire [2:0] col;
wire submitted;
wire [6:0] value;

// These values maintained by target_word
wire[24:0] current_word;

// These values maintained by getColors
wire[34:0] row_display_with_color;

wire up, down, left, right;
debouncer LeftDebouncer(.logicclk(logicclk), .button(btnl), .timeToFirstPress(7'd40), .button_output(left));
debouncer RightDebouncer(.logicclk(logicclk), .button(btnr), .timeToFirstPress(7'd100), .button_output(right));
debouncer UpDebouncer(.logicclk(logicclk), .button(btnu), .timeToFirstPress(7'd40), .button_output(up));
debouncer DownDebouncer(.logicclk(logicclk), .button(btnd), .timeToFirstPress(7'd40), .button_output(down));
// Lets us see if button press goes through
// assign dp = up | down | left | right;

selectionStage select(
	.clk(logicclk),
	.clr(clr),
	.up(up),
	.down(down),
	.left(left),
	.right(right),
	.rowValuesFlat(display[row]),
	.columnOut(col),
	.submitted(submitted),
	.value(value)
);

// the main FSM

localparam SELECT_WORD = 2'b00;
localparam EDIT_LETTER = 2'b01;
localparam DISPLAY_WIN = 2'b10;



target_word Target_word(.index(word_index), .word(current_word)); 
// EDCBA
// assign current_word = 25'b0000000001000100001100100;
wire doneGame;
getColors GetColors(.input_row(display[row]), .chosenWord(current_word), 
	.output_row(row_display_with_color),.doneGame(doneGame));

always @(posedge logicclk or posedge clr) begin
if (clr) begin
	word_index <= 0;
	current_state <= SELECT_WORD;
end else begin
	if (current_state == SELECT_WORD) begin
		word_index <= (word_index + 1) % 7'd100;
		if (right) begin
		// setup for new game
			row <= 0;
			display[0] <= 35'b00110100011010001101000110100011010;
			display[1] <= 35'b00110100011010001101000110100011010;
			display[2] <= 35'b00110100011010001101000110100011010;
			display[3] <= 35'b00110100011010001101000110100011010;
			display[4] <= 35'b00110100011010001101000110100011010;
			display[5] <= 35'b00110100011010001101000110100011010;
			current_state <= EDIT_LETTER;
		end
	end
	else if (current_state == EDIT_LETTER) begin
		if (submitted) begin
			row <= row + 1;
			display[row] <= row_display_with_color;
			if (doneGame || row == 5) current_state <= SELECT_WORD;
		end else begin
			display[row][7 * col +: 7] <= value;
		end
	end else if (current_state == DISPLAY_WIN) begin
		// TODO
		current_state <= SELECT_WORD;
	end
end
end


// VGA controller
vga640x480 U3(
	.dclk(dclk),
	.clr(clr),
	.display({display[5],display[4],display[3],display[2],display[1],display[0]}),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);

// print word index
fourdig_7seg(.clk(segclk), .blink_clk(segclk), .blink_which(4'b0), 
	.minutes(word_index), .seconds(current_state), .seg(seg), .an(an));

endmodule

module fourdig_7seg(
	input clk,
	input blink_clk,
	input [3:0] blink_which, // 0000 for nothing, 1100 for min, 0011 for sec
	input [6:0] minutes,
	input [6:0] seconds,
	output [7:0] seg,
	output [3:0] an);

reg [1:0] ctr;
reg [3:0] dig;
reg [3:0] an_fast;

assign an = an_fast | (blink_which * blink_clk);

to_7seg To_7Seg(.dig(dig), .seg(seg));
	
always @(posedge clk) begin
ctr <= ctr+1;
if (ctr == 0) begin
	dig <= seconds % 10;
	an_fast <= 4'b1110;
end else if (ctr == 1) begin
	an_fast <= 4'b1101;
	dig <= seconds / 10;
end else if (ctr == 2) begin
	dig <= minutes % 10;
	an_fast <= 4'b1011;
end else begin
	an_fast <= 4'b0111;
	dig <= minutes / 10;
end
	
	
end

endmodule

module to_7seg(input [3:0] dig, output reg [7:0] seg);
always @(*) begin
if (dig == 0)
	seg = 8'b11000000;
else if (dig == 1)
	seg = 8'b11111001; // BC
	else if (dig == 2) 
	seg = 8'b10100100; // ABDEG
	else if (dig == 3)
	seg = 8'b10110000; // ABCDG
	else if (dig == 4)
	seg = 8'b10011001; // BCFG
	else if (dig == 5)
	seg = 8'b10010010; // ACDFG
	else if (dig == 6)
	seg = 8'b10000010; // ACDEFG
	else if (dig == 7)
	seg = 8'b11111000; // ABC
	else if (dig == 8)
	seg = 8'b10000000; // ABCDEFG
	else if (dig == 9)
	seg = 8'b10010000; // ABCDFG
	// 
end
endmodule
