`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    00:30:38 03/19/2013 
// Design Name: 
// Module Name:    vga648'h480 
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
module vga640x480(
	input wire dclk,			//pixel clock: 25MHz
	input wire clr,			//asynchronous reset
	input wire [209:0] display,	// sadly, arrays not allowed as input in verilog
	output wire hsync,		//horizontal sync out
	output wire vsync,		//vertical sync out
	output reg [2:0] red,	//red vga output
	output reg [2:0] green, //green vga output
	output reg [1:0] blue	//blue vga output
	);

// video structure constants
parameter hpixels = 800;// horizontal pixels per line
parameter vlines = 521; // vertical lines per frame
parameter hpulse = 96; 	// hsync pulse length
parameter vpulse = 2; 	// vsync pulse length
parameter [9:0] hbp = 144; 	// end of horizontal back porch
parameter [9:0] hfp = 784; 	// beginning of horizontal front porch
parameter [9:0] vbp = 31; 		// end of vertical back porch
parameter [9:0] vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

wire [34:0] display_rows [0:5];
assign display_rows[0] = display[34:0];
assign display_rows[1] = display[69:35];
assign display_rows[2] = display[104:70];
assign display_rows[3] = display[139:105];
assign display_rows[4] = display[174:140];
assign display_rows[5] = display[209:175];

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// alphabet bitmaps
// ARTWORK
localparam ALPHABET [0:26][0:7][7:0] = {
	 { 8'h0C, 8'h1E, 8'h33, 8'h33, 8'h3F, 8'h33, 8'h33, 8'h00},   // U+0041 (A)
    { 8'h3F, 8'h66, 8'h66, 8'h3E, 8'h66, 8'h66, 8'h3F, 8'h00},   // U+0042 (B)
    { 8'h3C, 8'h66, 8'h03, 8'h03, 8'h03, 8'h66, 8'h3C, 8'h00},   // U+0043 (C)
    { 8'h1F, 8'h36, 8'h66, 8'h66, 8'h66, 8'h36, 8'h1F, 8'h00},   // U+0044 (D)
    { 8'h7F, 8'h46, 8'h16, 8'h1E, 8'h16, 8'h46, 8'h7F, 8'h00},   // U+0045 (E)
    { 8'h7F, 8'h46, 8'h16, 8'h1E, 8'h16, 8'h06, 8'h0F, 8'h00},   // U+0046 (F)
    { 8'h3C, 8'h66, 8'h03, 8'h03, 8'h73, 8'h66, 8'h7C, 8'h00},   // U+0047 (G)
    { 8'h33, 8'h33, 8'h33, 8'h3F, 8'h33, 8'h33, 8'h33, 8'h00},   // U+0048 (H)
    { 8'h1E, 8'h0C, 8'h0C, 8'h0C, 8'h0C, 8'h0C, 8'h1E, 8'h00},   // U+0049 (I)
    { 8'h78, 8'h30, 8'h30, 8'h30, 8'h33, 8'h33, 8'h1E, 8'h00},   // U+004A (J)
    { 8'h67, 8'h66, 8'h36, 8'h1E, 8'h36, 8'h66, 8'h67, 8'h00},   // U+004B (K)
    { 8'h0F, 8'h06, 8'h06, 8'h06, 8'h46, 8'h66, 8'h7F, 8'h00},   // U+004C (L)
    { 8'h63, 8'h77, 8'h7F, 8'h7F, 8'h6B, 8'h63, 8'h63, 8'h00},   // U+004D (M)
    { 8'h63, 8'h67, 8'h6F, 8'h7B, 8'h73, 8'h63, 8'h63, 8'h00},   // U+004E (N)
    { 8'h1C, 8'h36, 8'h63, 8'h63, 8'h63, 8'h36, 8'h1C, 8'h00},   // U+004F (O)
    { 8'h3F, 8'h66, 8'h66, 8'h3E, 8'h06, 8'h06, 8'h0F, 8'h00},   // U+0050 (P)
    { 8'h1E, 8'h33, 8'h33, 8'h33, 8'h3B, 8'h1E, 8'h38, 8'h00},   // U+0051 (Q)
    { 8'h3F, 8'h66, 8'h66, 8'h3E, 8'h36, 8'h66, 8'h67, 8'h00},   // U+0052 (R)
    { 8'h1E, 8'h33, 8'h07, 8'h0E, 8'h38, 8'h33, 8'h1E, 8'h00},   // U+0053 (S)
    { 8'h3F, 8'h2D, 8'h0C, 8'h0C, 8'h0C, 8'h0C, 8'h1E, 8'h00},   // U+0054 (T)
    { 8'h33, 8'h33, 8'h33, 8'h33, 8'h33, 8'h33, 8'h3F, 8'h00},   // U+0055 (U)
    { 8'h33, 8'h33, 8'h33, 8'h33, 8'h33, 8'h1E, 8'h0C, 8'h00},   // U+0056 (V)
    { 8'h63, 8'h63, 8'h63, 8'h6B, 8'h7F, 8'h77, 8'h63, 8'h00},   // U+0057 (W)
    { 8'h63, 8'h63, 8'h36, 8'h1C, 8'h1C, 8'h36, 8'h63, 8'h00},   // U+0058 (X)
    { 8'h33, 8'h33, 8'h33, 8'h1E, 8'h0C, 8'h0C, 8'h1E, 8'h00},   // U+0059 (Y)
    { 8'h7F, 8'h63, 8'h31, 8'h18, 8'h4C, 8'h66, 8'h7F, 8'h00},   // U+005A (Z)
	 { 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00}	  // Blank
};

// BEGIN stuff from NERP Demo

// Horizontal & vertical counters --
// this is how we keep track of where we are on the screen.
// ------------------------
// Sequential "always block", which is a block that is
// only triggered on signal transitions or "edges".
// posedge = rising edge  &  negedge = falling edge
// Assignment statements can only be used on type "reg" and need to be of the "non-blocking" type: <=
always @(posedge dclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		hc <= 0;
		vc <= 0;
	end
	else
	begin
		// keep counting until the end of the line
		if (hc < hpixels - 1)
			hc <= hc + 1;
		else
		// When we hit the end of the line, reset the horizontal
		// counter and increment the vertical counter.
		// If vertical counter is at the end of the frame, then
		// reset that one too.
		begin
			hc <= 0;
			if (vc < vlines - 1)
				vc <= vc + 1;
			else
				vc <= 0;
		end
		
	end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

// END stuff from NERP demo

// Display consists of 6 row x 5 col 80x80 squares tiling the rectangle
// with upper left corner at (vbp, hbp + 120) (inclusive)
// and lower right corner at (vbp + 480, hbp + 520) (exclusive)
// (cur_row, cur_col) indicates which square (vc, hc) is in

wire [2:0] cur_row;
assign cur_row = (vc - vbp) / 7'd80;

wire [2:0] cur_col;
assign cur_col = (hc - hbp - 10'd120) / 7'd80;

// Letters are drawn in the middle 64x64 of each 80x80 box
// upper left corner at (8,8) lower right at (72,72) in each box
// and are bitmapped from 8x8 (hence the divide by 8)
// (ltr_x, ltr_y) give the coordinates corresponding to (vc,hc)
// within the 8x8 bitmap 

wire [3:0] ltr_x;
assign ltr_x = ((vc - vbp + 10'd72) % 7'd80) / 4'd8;
wire [3:0] ltr_y;
assign ltr_y = ((hc - hbp + 10'd32) % 7'd80) / 4'd8;

wire v_in_box;
assign v_in_box = ltr_x < 8;

wire h_in_box;
assign h_in_box = ltr_y < 8;

// fetch the relevant part of the display
wire [6:0] cur_cell_display;
// this is what I meant by +: syntax
assign cur_cell_display = display_rows[cur_row][7*cur_col +: 7];


always @(*) begin
// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// main display area
		if (hc >= (hbp) && hc < (hbp+640))
		begin
			// main game area
			if (hc >= (hbp+120) && hc < (hbp+520)) begin
				if (h_in_box && v_in_box && ALPHABET[cur_cell_display[4:0]][ltr_x][ltr_y]) begin
						red = 3'b111;
						green = 3'b111;
						blue = 2'b11;
				end else begin
					if (cur_cell_display[6:5] == 0) begin
						// gray
						red = 3'b010;
						green = 3'b010;
						blue = 2'b01;
					end else if (cur_cell_display[6:5] == 1) begin
						// green
						red = 0;
						green = 3'b111;
						blue = 0;
					end else if (cur_cell_display[6:5] == 2) begin
						// yellow
						red = 3'b111;
						green = 3'b111;
						blue = 0;
					end else if (cur_cell_display[6:5] == 3) begin
						// dark red
						red = 3'b101;
						green = 3'b000;
						blue = 2'b00;
					end 
				end
			end
			// Ukraine flag
			else if (vc >= (vbp + 240)) begin
				red = 3'b111;
				green = 3'b111;
				blue = 0;
			end else begin
				red = 0;
				green = 0;
				blue = 2'b11;
			end
		end
		// we're outside active horizontal range so display black
		else
		begin
			red = 0;
			green = 0;
			blue = 0;
		end
	end
	// we're outside active vertical range so display black
	else
	begin
		red = 0;
		green = 0;
		blue = 0;
	end
end

endmodule

