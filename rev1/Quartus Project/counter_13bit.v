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

module counter_13bit(
	input clock,
	input reset,
	output reg [12:0] cnt
);
 
always@(negedge clock or posedge reset) begin
 if(reset)
  cnt <= 0;
 else
  cnt <= cnt + 1'b1;
end
 
endmodule