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
reg [4:0] count=5'b00000; 
reg button_output_reg;
wire [3:0] count_sum;

reg [17:0] clk_divider;

always @(posedge clk_sys) clk_divider = clk_divider+1;

assign clk = clk_divider[17];

reg [1:0] button_input_ff;

/*
always @(posedge clk or posedge button) begin
if (button)
button_input_ff <= 2'b11;
else
button_input_ff <= {1'b0,button_input_ff[1]};
end
	
*/

always @(posedge clk) begin
    if(button==0)
        count<=(count << 1);
    else
    begin
        count<=(count<<1)|1;
    end
end

always @(posedge clk) begin
        if(count_sum<=1) begin
            button_output_reg<=0;
        end else if (count_sum==5)
        begin
            button_output_reg<=1;
        end
end

    assign count_sum= count[4]+count[3]+count[2]+count[1]+count[0];
    assign button_output=button_output_reg;

endmodule 
