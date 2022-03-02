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
parameter hbp = 144; 	// end of horizontal back porch
parameter hfp = 784; 	// beginning of horizontal front porch
parameter vbp = 31; 		// end of vertical back porch
parameter vfp = 511; 	// beginning of vertical front porch
// active horizontal video is therefore: 784 - 144 = 640
// active vertical video is therefore: 511 - 31 = 480

// registers for storing the horizontal & vertical counters
reg [9:0] hc;
reg [9:0] vc;

// alphabet bitmaps
// ARTWORK
localparam ALPHABET [0:25][0:7][0:7] = {
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
    { 8'h7F, 8'h63, 8'h31, 8'h18, 8'h4C, 8'h66, 8'h7F, 8'h00}   // U+005A (Z)
};

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

// Drawing values for the board
reg [2:0] counter_row; // the square the pixels are currently on
reg [2:0] counter_col;
reg [6:0] square_x; // coords of the counter within the board square
reg [6:0] square_y;
reg [4:0] art_x; // coords on 8x8 artwork grid within the square
reg [4:0] art_y;

// Division is not synthesizable so we have to determine the pointer location the hard way
always @(hc) begin
	if (hc > 140 && hc <= hbp+220) begin counter_col <= 0; square_x <= hc - 140; end
	else if (hc <= hbp+300) begin counter_col <= 1; square_x <= hc - 220; end
	else if (hc <= hbp+380) begin counter_col <= 2; square_x <= hc - 300; end
	else if (hc <= hbp+460) begin counter_col <= 3; square_x <= hc - 380; end
	else if (hc <= hbp+540) begin counter_col <= 4; square_x <= hc - 460; end
end

always @(vc) begin
	if 	    (vc <=  vbp+80) begin counter_row <= 0; square_y <= vc; end
	else if (vc <= vbp+160) begin counter_row <= 1; square_y <= vc - 80; end
	else if (vc <= vbp+240) begin counter_row <= 2; square_y <= vc - 160; end
	else if (vc <= vbp+320) begin counter_row <= 3; square_y <= vc - 240; end
	else if (vc <= vbp+400) begin counter_row <= 4; square_y <= vc - 320; end
	else begin counter_row <= 5; square_y <= vc - 400; end
end

always @(square_x) begin
	if (square_x > 25 && square_x <= 30) art_x <= 0;
	else if (square_x <= 35) art_x <= 1;
	else if (square_x <= 40) art_x <= 2;
	else if (square_x <= 45) art_x <= 3;
	else if (square_x <= 50) art_x <= 4;
	else if (square_x <= 55) art_x <= 5;
	else if (square_x <= 60) art_x <= 6;
	else if (square_x <= 65) art_x <= 7;
	else art_x <= -1;
end

always @(square_y) begin
	if (square_y > 25 && square_y <= 30) art_y <= 0;
	else if (square_y <= 35) art_y <= 1;
	else if (square_y <= 40) art_y <= 2;
	else if (square_y <= 45) art_y <= 3;
	else if (square_y <= 50) art_y <= 4;
	else if (square_y <= 55) art_y <= 5;
	else if (square_y <= 60) art_y <= 6;
	else if (square_y <= 65) art_y <= 7;
	else art_y <= -1;
end

// display 100% saturation colorbars
// ------------------------
// Combinational "always block", which is a block that is
// triggered when anything in the "sensitivity list" changes.
// The asterisk implies that everything that is capable of triggering the block
// is automatically included in the sensitivty list.  In this case, it would be
// equivalent to the following: always @(hc, vc)
// Assignment statements can only be used on type "reg" and should be of the "blocking" type: =
always @(*)
begin
	// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// now display different colors every 80 pixels
		// while we're within the active horizontal range
		// -----------------
		if (hc >= hbp && hc < hfp)
		begin
			if (hc >= (hbp+140) && hc < (hfp-100) && vc % 80 >= 25 && vc % 80 < 35)
			// display horizontal lines
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			else if (hc >= (hbp+120) && hc < (hfp-90) && hc % 80 >= 40 && hc % 80 < 50)
			// display vertical lines
			begin
				red = 0;
				green = 0;
				blue = 0;
			end
			else
			// display white background
			begin
				red = 3'b111;
				green = 3'b111;
				blue = 2'b11;
			end
			
			if (counter_row == 1 && counter_col == 1)
			// hard code an A
			begin
				if (art_x != -1 && art_y != -1)
				begin
					if (ALPHABET[0][art_y][art_x]) begin
					red = 0;
					green = 0;
					blue = 0;
					end
					else begin
						red = 3'b111;
						green = 3'b111;
						blue = 2'b11;
					end
				end
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
