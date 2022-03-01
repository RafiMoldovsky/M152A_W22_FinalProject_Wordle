`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:08:53 03/01/2022 
// Design Name: 
// Module Name:    testbench 
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
module testbench(
    );
	 reg [24:0] inputWord;
	 reg [24:0] chosenWord;
	 wire [4:0] yellowsOut;
	 wire [4:0] greensOut;
	getColors uut(.inputWord(inputWord), .chosenWord(chosenWord), .yellowsOut(yellowsOut) 
	,.greensOut(greensOut));
	
	initial begin 
		inputWord=25'b0;
		chosenWord=25'b0;
		 #100;
		 inputWord=25'b1;
		 chosenWord=25'b11;
		 #100;
			inputWord=25'b1;
		 chosenWord=25'b11111;	
		#100;
			inputWord=25'b11111;
		 chosenWord=25'b11111;
			#100;
			inputWord=25'b11111;
		 chosenWord=25'b11110;		
			#100;
			inputWord=25'b1111100000;
			chosenWord=25'b11111;
			#100
			inputWord=25'b111110000011111;
			chosenWord=25'b1111100000;
			#100
			inputWord=25'b111110000011111;
			chosenWord=25'b11111;
			#100
			inputWord=25'b111110000011111;
			chosenWord=25'b0;
			#100
			inputWord=25'b100000000000000;
			chosenWord=25'b0;
			#100
			inputWord=25'b10000000000000000000;
			chosenWord=25'b0;
	end

endmodule
