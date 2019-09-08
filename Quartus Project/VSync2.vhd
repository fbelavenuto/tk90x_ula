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

entity VSync2 is
	port (
		SelFreq   : in   std_logic;
		HBlank    : in   std_logic;
		VSyncEn   : out  std_logic;
		VSync     : out  std_logic;
		VBorder   : out  std_logic;
		VCrst     : out  std_logic;
		VC        : out  std_logic_vector(8 downto 0)
	);

end VSync2;

architecture Behavioral of VSync2 is

	signal rst : std_logic;
	signal cnt : std_logic_vector(8 downto 0);
	
begin

	VC    <= cnt;
	VCrst <= rst;
	rst   <= '1' when (SelFreq = '1' and cnt = 262) else
	         '1' when (SelFreq = '0' and cnt = 312) else
	         '0';

	process (HBlank, rst)
	begin
		if (rst = '1') then
			cnt <= (others => '0');
		elsif (falling_edge(HBlank)) then
			cnt <= cnt + 1;
		end if;
	end process;

	VSyncEn <= '0' when (SelFreq = '1' and cnt >= 224 and cnt < 232) else
	           '0' when (SelFreq = '0' and cnt >= 248 and cnt < 256) else
	           '1';

	VSync   <= '0' when (SelFreq = '1' and cnt >= 224 and cnt < 228) else
	           '0' when (SelFreq = '0' and cnt >= 248 and cnt < 252) else
	           '1';

	VBorder <= '0' when (cnt < 192) else
	           '1';

end Behavioral;