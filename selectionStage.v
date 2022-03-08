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
	input clr,
   input left, // assume these are debounced and only give single-clock-cycle pulses
   input right,
   input up,
   input down,
	input doneGame,
   input [34:0] rowValuesFlat,
   output [2:0] columnOut,
   output submitted,
	output [6:0] value
	);


wire [6:0] rowValues [0:4];
assign rowValues[0] = rowValuesFlat[6:0];
assign rowValues[1] = rowValuesFlat[13:7];
assign rowValues[2] = rowValuesFlat[20:14];
assign rowValues[3] = rowValuesFlat[27:21];
assign rowValues[4] = rowValuesFlat[34:28];

    reg submit;
	 
	 localparam NORMAL = 2'b00;
	 localparam LEFT_TRANSITION = 2'b01;
	 localparam RIGHT_TRANSITION = 2'b10;
	 localparam ROW_TRANSITION = 2'b11;
	 localparam WAIT = 3'b100;
	 
	 reg [2:0] state;

    reg [2:0] column;
	 //letter color row column 
    //combine letter and color - last 5 bits are letter, 1st and 2nd are color 
    //instantiate as all empty, grey 
    //blank = 26, grey = 0, yellow=1, green= 2, red = 3
    //A=0, B=1, C=2, ...
    reg [6:0] currentValue; // all 0s -> letter A in grey
	 
	 assign submitted=submit;
    assign columnOut=column;
    assign value=currentValue;
	 
	 wire [4:0] currentLetter;
	 assign currentLetter = currentValue[4:0];
	 
always @(posedge clk or posedge clr) begin //always gonna be grey here
	 if (clr) begin
		 currentValue <= 0;
		 state <= WAIT;
		 column <= 0;
		 submit <= 0;
	 end else begin
		if (state == NORMAL) begin
        if(down) begin
            currentValue[4:0] <= (currentLetter + 5'd1) % 5'd26;
        end
		  else if(up) begin
            if (currentLetter == 5'd0) currentValue[4:0] <= 5'd25;
				else currentValue[4:0] <= currentLetter - 1;
        end
        else if(right) begin
            if(column==4) begin
                submit<=1;
					 state<=ROW_TRANSITION;
            end
            else begin
					currentValue <= currentValue & 7'b0011111;
					state <= RIGHT_TRANSITION;
			   end  
        end
		  else if(left) begin
            if(column!=0) begin
					 currentValue <= currentValue & 7'b0011111;
					 state<=LEFT_TRANSITION;
            end
        end
		end else if (state == LEFT_TRANSITION) begin
			currentValue<= rowValues[column-1] | 7'b1100000;
			column <= column-1;
			state <= NORMAL;
		end else if (state == RIGHT_TRANSITION) begin
			if (rowValues[column+1][4:0] == 5'd26)
				currentValue<=7'b1100000;
			else
				currentValue<=rowValues[column+1] | 7'b1100000;
			column <= column+1;
			state <= NORMAL;
		end else if (state == ROW_TRANSITION) begin
			column <= 0;
			submit <= 0;
			currentValue <= rowValues[0] | 7'b1100000;
			if (doneGame)
				state <= NORMAL;
			else
				state <= WAIT;
		end else if (state == WAIT) begin
			column <= 0;
			submit <= 0;
			if (right) begin
				state <= NORMAL;
			end
		end
    end
end
endmodule
