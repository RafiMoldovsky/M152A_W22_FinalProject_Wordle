`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:49:36 04/1/2022
// Design Name: 
// Module Name:    getColors 
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
module getColors(
	input [34:0] input_row,		// The word the player inputs into wordle 
	input [24:0] chosenWord,
	output [34:0] output_row);
	
	reg [4:0] yellows;
	reg [4:0] greens;
	
	assign output_row = {yellows[4], greens[4], input_row[32:28], 
	yellows[3], greens[3], input_row[25:21],
	yellows[2], greens[2], input_row[18:14], 
	yellows[1], greens[1], input_row[11:7], 
	yellows[0], greens[0], input_row[4:0]};
	
	wire [24:0] inputWord;
	assign inputWord = {input_row[32:28], 
	input_row[25:21],
	input_row[18:14], 
	input_row[11:7], 
	input_row[4:0]};

	//check greens first
    //not sure if this has to be in an always block
    integer i;
    integer j;
	 integer k;
    integer true; //1 is true
	 always @* begin
	 true=1;
    for(i=0; i<5; i=i+1) begin
	 for(j=5*i; j<(5*i)+5; j=j+1) begin
            if(inputWord[j]!=chosenWord[j])begin
                true=0;
            end
        end
		   if(true==1) begin
            greens[i]=1; 
				yellows[i]=0;
        end
        else begin
            greens[i]=0;
        end
        true=1;
    end
	 //now for yellows
    for(i=0; i<5; i=i+1) begin
            for(j=0; j<5; j=j+1) begin
                for(k=0; k<5;k=k+1) begin
                    if(greens[i]==1) begin  //only for those letters which are not green
                        true=0;
                    end
                    else if(inputWord[k+(i*5)]!=chosenWord[k+(j*5)]) begin
                        true=0;
								end
                end
                if(true==1) begin
                    yellows[i]=1;
                end
                true=1;
            end
        end
    end
endmodule 