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
	
reg [209:0] display;

//Start game
//choose word 
reg [2:0] col=0;
reg [2:0] row=0;

wire submitted;
wire[6:0] value;

wire up, down, left, right;
debouncer LeftDebouncer(.clk_sys(clk), .button(btnl), .button_output(left));
debouncer RightDebouncer(.clk_sys(clk), .button(btnr), .button_output(right));
debouncer UpDebouncer(.clk_sys(clk), .button(btnu), .button_output(up));
debouncer DownDebouncer(.clk_sys(clk), .button(btnd), .button_output(down));

selectionStage select(
	.clk(clk),
	.up(up),
	.down(down),
	.left(left),
	.right(right),
	.colIn(col),
	.rowValues(display[35*row +: 35]),
	.columnOut(col),
	.submitted(submitted),
	.value(value)
);

// the main FSM

localparam SELECT_WORD = 2'b00;
localparam EDIT_LETTER = 2'b01;
localparam DISPLAY_WIN = 2'b10;

reg [1:0] current_state;
wire[24:0] current_word;
reg[6:0] word_index;

target_word Target_word(.index(word_index), .word(current_word)); 

wire[34:0] row_display_with_color;
getColors GetColors(.input_row(display[35 * row +: 35]), .chosenWord(current_word), 
	.output_row(row_display_with_color));

always @(posedge clk) begin
if (current_state == SELECT_WORD) begin
	word_index <= (word_index + 1) % 100;
	if (right) begin
		current_state <= EDIT_LETTER;
	end
end
else if (current_state == EDIT_LETTER) begin
	if (submitted) begin
		row <= row + 1;
		display[35 * row +: 35] <= row_display_with_color;
	end else begin
		display[35 * row + 7 * col +: 7] <= value;
	end
end else if (current_state == DISPLAY_WIN) begin

end
end


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
