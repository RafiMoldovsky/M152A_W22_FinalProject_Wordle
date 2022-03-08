`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:38:33 02/08/2022 
// Design Name: 
// Module Name:    debouncer
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
module debouncer(
    input logicclk,
    input button,
	 input clr,
	 input [6:0] timeToFirstPress,
    output button_output
);
reg [6:0] count; 
reg button_output_reg;
wire [3:0] count_sum;

/*
always @(posedge clk or posedge button) begin
if (button)
button_input_ff <= 2'b11;
else
button_input_ff <= {1'b0,button_input_ff[1]};
end
	
*/

always @(posedge logicclk or posedge clr) begin
if (clr) begin
	count <= 7'b0;
end else begin
    if(button==0)
        count<=7'b0;
    else
    begin
        count<=count+1;
    end
end
end

assign button_output=(count==timeToFirstPress);

endmodule 
