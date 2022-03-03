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
    input btnd,
	input btnr,
    input btnl,
    input btnu,
	input [2:0] colIn,
    input [7:0] rowValues [0:4],
    output columnOut,
    output submitted,
	output value
	);

    wire left;
    wire right;
    wire up;
    wire down;
    reg submit=0;
	 debouncer LeftDebouncer(.clk_sys(clk), .button(btnl), .button_output(left));
    debouncer RightDebouncer(.clk_sys(clk), .button(btnr), .button_output(right));
    debouncer UpDebouncer(.clk_sys(clk), .button(btnu), .button_output(up));
    debouncer DownDebouncer(.clk_sys(clk), .button(btnd), .button_output(down));
    reg [2:0] column;
	 //letter color row column 
    //combine letter and color - last 5 bits are letter, 1st and 2nd are color 
    //instantiate as all empty, grey 
    //blank = 0, grey = 0, yellow=1, green= 2
    //A=1, B=2, C=3, ...
    reg [6:0] currentValue = 7'b0000001; //letter A in grey
	 always @(posedge clk) begin //always gonna be grey here
			column<=colIn;
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
            currentValue<=currentValue-1'b1;
        end
        else if(btnr) begin
            if(column==4) begin
                submit<=1;
            end
            else begin
                column<=column+1;
                currentValue<=rowValues[column];
            end  
        end
		  else if(btnl) begin
            if(column!=0) begin
                column<=column-1;
					 currentValue<=rowValues[column];
            end
        end
    end
    assign submitted=submit;
    assign columnOut=column;
    assign value=currentValue;
endmodule