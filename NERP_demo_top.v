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
	


//Start game
//choose word 
wire [24:0] targetWord = 25'b0000100010000110010000101; //ABCDE 
//target_word target(.chosenWord(targetWord));
wire [2:0] col=0;
wire [2:0] row=0;
reg [6:0] DISPLAY [0:5] [0:4]; //assume this is initialized to all zero which is blank
wire submitted =0;
//wire [6:0] value;
reg [24:0] guess;
wire [4:0] greens;
wire[4:0] yellows;
reg gameOver=0;
integer i=0;
integer greenCount=0;
wire [34:0] display_wire1;
wire [34:0] display_wire2;
wire [34:0] display_wire3;
wire [34:0] display_wire4;
wire [34:0] display_wire5;
wire [34:0] display_wire6;
reg [2:0] col_reg;
reg submit_reg;
//selectionStage select(
//			.clk(clk),
//			.btnd(btnd),
//			.btnr(btnr),
//			.btnl(btnl),
//			.btnu(btnu),
//			.colIn(col),
//			.rowValues({DISPLAY[row][0],DISPLAY[row][1],DISPLAY[row][2],DISPLAY[row][3],DISPLAY[row][4]}),
//			.columnOut(col_out),
//			.submitted(submitted),
//			.value(value)
//		);
		getColors colors(
			.inputWord(guess),
			.chosenWord(targetWord),
			.yellowsOut(yellows),
			.greensOut(greens)
		);
	debouncer LeftDebouncer(.clk_sys(clk), .button(btnl), .button_output(left));
    debouncer RightDebouncer(.clk_sys(clk), .button(btnr), .button_output(right));
    debouncer UpDebouncer(.clk_sys(clk), .button(btnu), .button_output(up));
    debouncer DownDebouncer(.clk_sys(clk), .button(btnd), .button_output(down));
	     reg [6:0] currentValue = 7'b0000001; //letter A in grey
		  reg [34:0] rowValues; 
always @(posedge clk) begin
	submit_reg<=submitted;
		rowValues<={DISPLAY[row][0],DISPLAY[row][1],DISPLAY[row][2],DISPLAY[row][3],DISPLAY[row][4]};
		col_reg<=col;
        if(btnd) begin
            currentValue<=currentValue+1'b1;
            if(currentValue==7'b0011011) begin //equals 27
                currentValue<= 7'b0000001;
            end
        end
		  else if(btnu) begin
            if(currentValue==7'b0000001) begin //equals A 
                currentValue<= 7'b0011010;
            end
				else begin
					currentValue<=currentValue-1'b1;
				end
        end
        else if(btnr) begin
            if(col_reg==3'b100) begin
                submit_reg<=1;
            end
            else begin
                col_reg<=col_reg+1;
                currentValue<=rowValues[((col_reg+1)*7)-1-:6];
            end  
        end
		  else if(btnl) begin
            if(col_reg!=0) begin
                col_reg<=col_reg-1;
					 currentValue<=rowValues[((col_reg+1)*7)-1-:6];
            end
        end
	DISPLAY[row][col_reg]<=currentValue;
	if(submit_reg==1 && gameOver==0) begin
		guess <= {DISPLAY[row][0][4:0], DISPLAY[row][1][4:0],
		DISPLAY[row][2][4:0],DISPLAY[row][3][4:0],DISPLAY[row][4][4:0]};
	end
	for(i=0; i<5; i=i+1) begin
			if(greens[i]==1) begin
				DISPLAY[row][i][6:5]<=2'b01;
				greenCount<=greenCount+1;
			end
			else if(yellows[i]==1) begin
				DISPLAY[row][i][6:5]<=2'b10;
			end
	end
		if(greenCount==5) begin
			gameOver<=1;
		end
		else if(col_reg==3'b110) begin //if on the last column
			gameOver<=1;
		end
		else begin
			col_reg<=col_reg+1'b1;
			greenCount<=0;
			submit_reg<=0;
		end
end 

//assign col=col_reg;
//assign submitted=submit_reg;

//assign display_wire1={DISPLAY[0][0],DISPLAY[0][1],DISPLAY[0][2],DISPLAY[0][3],DISPLAY[0][4]};
assign display_wire1={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
assign display_wire2={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
assign display_wire3={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
assign display_wire4={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
assign display_wire5={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
assign display_wire6={7'b0000001,7'b0000010,7'b0000011,7'b0000100,7'b0000101}; //ABCDE
//assign display_wire2={DISPLAY[1][0],DISPLAY[1][1],DISPLAY[1][2],DISPLAY[1][3],DISPLAY[1][4]};
//assign display_wire3={DISPLAY[2][0],DISPLAY[2][1],DISPLAY[2][2],DISPLAY[2][3],DISPLAY[2][4]};
//assign display_wire4={DISPLAY[3][0],DISPLAY[3][1],DISPLAY[3][2],DISPLAY[3][3],DISPLAY[3][4]};
//assign display_wire5={DISPLAY[4][0],DISPLAY[4][1],DISPLAY[4][2],DISPLAY[4][3],DISPLAY[4][4]};
//assign display_wire6={DISPLAY[5][0],DISPLAY[5][1],DISPLAY[5][2],DISPLAY[5][3],DISPLAY[5][4]};

		
	vga640x480 U3(
	.dclk(dclk),
	.clr(clr),
	.display({display_wire6,display_wire5,display_wire4,display_wire3,display_wire2,display_wire1}),
	.hsync(hsync),
	.vsync(vsync),
	.red(red),
	.green(green),
	.blue(blue)
	);
//assign display_wire=DISPLAY;
// VGA controller

endmodule
