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

// 7-segment display controller
segdisplay U2(
	.segclk(segclk),
	.clr(clr),
	.seg(seg),
	.an(an)
	);

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
debouncer LeftDebouncer(.clk_sys(clk), .button(btnl), .button_output(left));
debouncer RightDebouncer(.clk_sys(clk), .button(btnr), .button_output(right));
debouncer UpDebouncer(.clk_sys(clk), .button(btnu), .button_output(up));
debouncer DownDebouncer(.clk_sys(clk), .button(btnd), .button_output(down));
// Lets us see if button press goes through
assign dp = up | down | left | right;

selectionStage select(
	.clk(clk),
	.clr(clr),
	.up(up),
	.down(down),
	.left(left),
	.right(right),
	.rowValues(display[row]),
	.columnOut(col),
	.submitted(submitted),
	.value(value)
);

// the main FSM

localparam SELECT_WORD = 2'b00;
localparam EDIT_LETTER = 2'b01;
localparam DISPLAY_WIN = 2'b10;



target_word Target_word(.index(word_index), .word(current_word)); 

getColors GetColors(.input_row(display[row]), .chosenWord(current_word), 
	.output_row(row_display_with_color));

always @(posedge logicclk or posedge clr) begin
if (clr) begin
	row <= 0;
	word_index <= 0;
	current_state <= SELECT_WORD;

	display[0] <= 35'b0;
	display[1] <= 35'b0;
	display[2] <= 35'b0;
	display[3] <= 35'b0;
	display[4] <= 35'b0;
	display[5] <= 35'b0;
end else begin
	if (current_state == SELECT_WORD) begin
		word_index <= (word_index + 1) % 100;
		if (right) begin
			current_state <= EDIT_LETTER;
		end
	end
	else if (current_state == EDIT_LETTER) begin
		if (submitted) begin
			row <= row + 1;
			display[row] <= row_display_with_color;
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

endmodule
