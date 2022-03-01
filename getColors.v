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
	input [24:0] inputWord,		// The word the player inputs into wordle 
	input [24:0] chosenWord,		// The word we choose to check against
	output wire [4:0] yellowsOut,		// 5 bit register holding whether each letter should be yellow
	output wire [4:0] greensOut	// 5 bit register holding whether each letter should be green
	);
	reg [4:0] yellows;
	reg [4:0] greens;
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
						//this is for the case of double letter words - 
						  //don't want a second letter to show up green for a single letter 
                    //For example: inputWord=vivid, chosenWord=simple - only want the first i to show up green 
                    // second i should show up as grey
						  for(k=0; k<5;k=k+1) begin
						  if(greens[i]==0 && greens[j]==0 && yellows[i]==0) begin  //only for those letters which are not green
							if(inputWord[k+(i*5)]!=chosenWord[k+(j*5)]) begin
								true=0;
							end
							else begin
								true=true+1;
							end
							end
						  end
						  if(true==5 && greens[i]==0 && greens[j]==0) begin
							yellows[i]=1;
							//j=5;
						  end
						  true=0;
                
            end
        end
    end
	 
	 assign yellowsOut=yellows;
	 assign greensOut=greens;
endmodule 