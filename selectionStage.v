`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:56:56 03/19/2013 
// Design Name: 
// Module Name:    selectionStage 
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
module selectionStage(
	input clk,
   input left, // assume these are debounced and only give single-clock-cycle pulses
   input right,
   input up,
   input down,
	input [2:0] colIn,
   input [34:0] rowValues,
   output [2:0] columnOut,
   output submitted,
	output [6:0] value
	);


    reg submit=0;
	 
	 localparam NORMAL = 0;
	 localparam COL_TRANSITION = 1;
	 localparam ROW_TRANSITION = 2;
	 
	 reg [1:0] state;

    reg [2:0] column;
	 //letter color row column 
    //combine letter and color - last 5 bits are letter, 1st and 2nd are color 
    //instantiate as all empty, grey 
    //blank = 26, grey = 0, yellow=1, green= 2, red = 3
    //A=0, B=1, C=2, ...
    reg [6:0] currentValue; // all 0s -> letter A in grey
									 // init to anything else is not synthable
	 always @(posedge clk) begin //always gonna be grey here
		if (state == NORMAL) begin
			column<=colIn;
        if(down) begin
            currentValue[4:0] <= (currentValue[4:0]+ 1) % 26;
        end
		  else if(up) begin
            currentValue[4:0] <= (currentValue[4:0] + 25) % 26;
        end
        else if(right) begin
            if(column==4) begin
                submit<=1;
					 state<=ROW_TRANSITION;
            end
            else begin
               column <= column+1;
					currentValue[6:5] <= 0;
					state <= COL_TRANSITION;
			   end  
        end
		  else if(left) begin
            if(column!=0) begin
                column<=column-1;
					 currentValue<=rowValues[column];
            end
        end
		end else if (state == COL_TRANSITION) begin
			currentValue<=rowValues[column];
			state <= NORMAL;
		end else if (state == ROW_TRANSITION) begin
			column <= 0;
			submit <= 0;
			currentValue <= rowValues[0];
			state <= NORMAL;
		end
    end
    assign submitted=submit;
    assign columnOut=column;
    assign value=currentValue;
endmodule