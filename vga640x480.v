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
	input wire [209:0] display,	// [6:5] color; [4:0] character
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
localparam ALPHABET [0:26][0:7][0:7] = {
	 { 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00},	  // Blank
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

 reg [31:0] ctr;
 always @(posedge dclk) begin
 ctr <= ctr + 1;
end

wire in_db;

//word_db Word_db(.word(ctr), .in_db(in_db));

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

wire [2:0] box_i;
assign box_i = (vc - vbp) / 80;

wire [2:0] box_j;
assign box_j = (hc - hbp - 120) / 80;

wire [2:0] ltr_x;
assign ltr_x = ((vc - vbp + 64) % 80) / 8;
wire [2:0] ltr_y;
assign ltr_y = ((hc - hbp + 24) % 80) / 8;

wire v_in_box;
assign v_in_box = ((vc - vbp + 64) % 80) < 64;

wire h_in_box;
assign h_in_box = ((hc - hbp + 24) % 80) < 64;

// get current row and column
reg [2:0] cur_row;
reg [2:0] cur_col;

always @(hc) begin
	if (hc > 140 && hc <= hbp+220) begin cur_col <= 0; end
	else if (hc <= hbp+300) begin cur_col <= 1; end
	else if (hc <= hbp+380) begin cur_col <= 2; end
	else if (hc <= hbp+460) begin cur_col <= 3; end
	else if (hc <= hbp+540) begin cur_col <= 4; end
end

always @(vc) begin
	if 	    (vc <=  vbp+80) begin cur_row <= 0; end
	else if (vc <= vbp+160) begin cur_row <= 1; end
	else if (vc <= vbp+240) begin cur_row <= 2; end
	else if (vc <= vbp+320) begin cur_row <= 3; end
	else if (vc <= vbp+400) begin cur_row <= 4; end
	else begin cur_row <= 5; end
end

// generate sync pulses (active low)
// ----------------
// "assign" statements are a quick way to
// give values to variables of type: wire
assign hsync = (hc < hpulse) ? 0:1;
assign vsync = (vc < vpulse) ? 0:1;

wire [4:0] char;
wire [1:0] color;
assign char = box_i * 35 + box_j * 7 + 4:box_i * 35 + box_j * 7 + 0;
assign color = box_i * 35 + box_j * 7 + 6:box_i * 35 + box_j * 7 + 5;

always @(*) begin
// first check if we're within vertical active video range
	if (vc >= vbp && vc < vfp)
	begin
		// main display area
		if (hc >= (hbp) && hc < (hbp+640))
		begin
			// main game area
			if (hc >= (hbp+120) && hc < (hbp+520)) begin
				if (h_in_box && v_in_box) begin
					if (ALPHABET[display[char]][ltr_x][7-ltr_y]) begin
						red = 3'b111;
						green = 3'b111;
						blue = 2'b11;
					end else begin
						if (display[color] == 0) begin
							// white
							red = 0;
							green = 0;
							blue = 0;
						end else if (display[color] == 1) begin
							// green
							red = 0;
							green = 3'b111;
							blue = 0;
						end else if (display[color] == 2) begin
							// yellow
							red = 3'b111;
							green = 3'b111;
							blue = 0;
						end else if (display[color] == 3) begin
							// gray
							red = 3'b011;
							green = 3'b011;
							blue = 2'b01;
						end
					end 
				end else begin
					red = 0;
					green = 0;
					blue = 0;
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

