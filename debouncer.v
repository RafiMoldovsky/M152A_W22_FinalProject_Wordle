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
    input clk_sys,
    input button,
    output button_output
);

// at 100Mhz, this corresponds to ~6 presses read per second
reg [23:0] count;

/*
always @(posedge clk or posedge button) begin
if (button)
button_input_ff <= 2'b11;
else
button_input_ff <= {1'b0,button_input_ff[1]};
end
	
*/

// can speed up initial press / slow down following presses if this is too annoying

always @(posedge clk_sys) begin
    if(button==0)
        count <= 0;
    else
    begin
        count<= count+1;
    end
end

assign button_output=&count;

endmodule 
