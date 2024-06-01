/* 
Projeto ULA CPLD - Clone da ULA do TK90X/TK95.
Copyright Fábio Belavenuto 2012.
Copyright Victor Trucco 2012.

This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
You may redistribute and modify this documentation under the terms of the
CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
Please see the CERN OHL v.1.1 for applicable conditions
*/

module interrupcao2(
	input			clk14,
	input [8:0] VC,
	input [8:0] HC,
	input       F60_50,
	output reg  int_n
);

//wire CLKs = clk14 | clk7;
wire [8:0] VC1 = F60_50 ? 9'd223 : 9'd247;
wire [8:0] VC2 = F60_50 ? 9'd224 : 9'd248;

always @(negedge clk14) begin
	if (
		((VC == VC1 && HC >= 267 && HC < 320) ||
		 (VC == VC2 && HC >= 320 && HC < 331))
	)
		int_n <= 0;
	else
		int_n <= 1;
end

endmodule
	