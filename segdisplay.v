`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:56 03/19/2013 
// Design Name: 
// Module Name:    segdisplay 
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
module segdisplay(
	input wire segclk,		//7-segment clock
	input wire clr,			//asynchronous reset
	output reg [6:0] seg,	//7-segment display LEDs
	output reg [3:0] an		//7-segment display anode enable
	);

// constants for displaying letters on display
parameter N = 7'b1001000;
parameter E = 7'b0000110;
parameter R = 7'b1001100;
parameter P = 7'b0001100;

// Finite State Machine (FSM) states
parameter left = 2'b00;
parameter midleft = 2'b01;
parameter midright = 2'b10;
parameter right = 2'b11;

// state register
reg [1:0] state;

// FSM which cycles though every digit of the display every 2.62ms.
// This should be fast enough to trick our eyes into seeing that
// all four digits are on display at the same time.
always @(posedge segclk or posedge clr)
begin
	// reset condition
	if (clr == 1)
	begin
		seg <= 7'b1111111;
		an <= 7'b1111;
		state <= left;
	end
	// display the character for the current position
	// and then move to the next state
	else
	begin
		case(state)
			left:
			begin
				seg <= N;
				an <= 4'b0111;
				state <= midleft;
			end
			midleft:
			begin
				seg <= E;
				an <= 4'b1011;
				state <= midright;
			end
			midright:
			begin
				seg <= R;
				an <= 4'b1101;
				state <= right;
			end
			right:
			begin
				seg <= P;
				an <= 4'b1110;
				state <= left;
			end
		endcase
	end
end

endmodule
