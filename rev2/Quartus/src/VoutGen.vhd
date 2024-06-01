-- Projeto ULA CPLD - Clone da ULA do TK90X/TK95.
-- Copyright Fábio Belavenuto 2012.
-- Copyright Victor Trucco 2012.

-- This documentation describes Open Hardware and is licensed under the CERN OHL v. 1.1.
-- You may redistribute and modify this documentation under the terms of the
-- CERN OHL v.1.1. (http://ohwr.org/cernohl). This documentation is distributed
-- WITHOUT ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING OF MERCHANTABILITY,
-- SATISFACTORY QUALITY AND FITNESS FOR A PARTICULAR PURPOSE.
-- Please see the CERN OHL v.1.1 for applicable conditions


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VoutGen is
	port(
		CNT      : in  std_logic_vector(9 downto 0);
		VBorder  : in  std_logic;
		Vout     : out std_logic
	);

end VoutGen;

architecture Behavioral of VoutGen is


begin

	process (CNT, VBorder)
	begin
		if (CNT >= "0000010110" and CNT < "1000010100" and VBorder = '0') then
			Vout <= '0';
		else
			Vout <= '1';
		end if;
	end process;

end Behavioral;