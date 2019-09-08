-------------------------------------------------------------------------------
--  Projeto ULA CPLD - Clone da ULA do TK90X/TK95.                           --
--                                                                           --
--  Chris Smith - Estudo e engenharia reversa da ULA do ZX Spectrum          --
--  Miguel Angel Rodriguez Jodar - Verilog original da ULA do ZX Spectrum    --
--  Victor Trucco - versao em VHDL da ULA do TK                              --
--  Fabio Belavenuto - versao em VHDL da ULA do TK e correcao de bugs        --
--                                                                           --
--  Dezembro de 2013                                                         --
--                                                                           --
--  Maiores informacoes sobre a ULA do TK                                    --
--  http://victortrucco.com/TK/DossieULA/DossieULA.asp                       --
--  http://www.victortrucco.com/TK/ULATKCPLD/ULATKCPLD.asp                   --
--                                                                           --
--  Site do Chris Smith                                                      --
--  http://www.zxdesign.info/book/                                           --
--                                                                           --
--  Versão 001 - 05/12/2013 - Release inicial                                --
--                                                                           --
-------------------------------------------------------------------------------
--                                                                           --
--  This file is part of ULA CPLD.                                           --
--                                                                           --
--  ULA CPLD is free software: you can redistribute it and/or modify         --
--  it under the terms of the GNU General Public License as published by     --
--  the Free Software Foundation, either version 3 of the License, or        --
--  (at your option) any later version.                                      --
--                                                                           --
--  ULA CPLD is distributed in the hope that it will be useful,              --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of           --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            --
--  GNU General Public License for more details.                             --
--                                                                           --
--  You should have received a copy of the GNU General Public License        --
--  along with ULA CPLD.  If not, see <http://www.gnu.org/licenses/>         --
--                                                                           --
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;


entity top is
    port (
    
        iOSC         : in   std_logic;                             -- Pino 11 - OSC - entrada de 14.30244 Mhz, vindo do TK
                                                                  
        oSUBCARRIER  : out  std_logic;                             -- Pino 39 - Subcarrier - 3.575611 Mhz - Subportadora de Croma e
                                                                   -- tambem usado para etapa de oscilacao das fonte de +12V e -5V
                                     
                                                                   -- Saida de Video digital
        oRED         : out  std_logic;                             -- Pino 21 - Vermelho
        oGREEN       : out  std_logic;                             -- Pino 19 - Verde
        oBLUE        : out  std_logic;                             -- Pino 22 - Azul
        oBRIGHT      : out  std_logic;                             -- Pino 18 - Brilho
        oCSYNC       : out  std_logic;                             -- Pino 33 - Sincronismo Composto
		oCSYNC2      : out  std_logic;                             -- Cópia do pino 33
		oHSYNC       : out  std_logic;							   -- Nao presente no CI original, e a saida de Sincronismo Horizontal
        oVSYNC       : out  std_logic;                             -- Nao presente no CI original, e a saida de Sincronismo Vertical
        oBURSTGATE   : out  std_logic;                             -- Pino 35 - Marcacao do Color Burst para o CI LM1886
                                     
                                                                   -- interface com o Z80
        iA14         : in   std_logic;                             -- Pino 37 - Linha A14 do Z80
        iA15         : in   std_logic;                             -- Pino 38 - Linha A15 do Z80
        iMREQ        : in   std_logic;                             -- Pino 15 - Linha MREQ do Z80
        iWR          : in   std_logic;                             -- Pino 16 - Linha WR do Z80
        iRD          : in   std_logic;                             -- Pino 17 - Linha RD do Z80
        oCPU         : out  std_logic;                             -- Pino 36 - clock com contencao para o Z80 - 3.57Mhz 
        iCS          : in   std_logic;                             -- Pino 2 - Combinacao de IORQ e linha A0 - Monitora o acesso a porta 254
        iULA_D       : in   std_logic_vector (7 downto 0);         -- Pinos 25 a 32 - Entrada de Dados da ULA. 
                
                                                                   -- interface com memorias dinamicas
        oVRAM_A      : out  std_logic_vector (6 downto 0);         -- Pinos 3 a 9 - Linhas A0 a A6. Sao multiplexadas em linhas em colunas
        oVRAM_CAS    : out  std_logic;                             -- Pino 12 - Saida de CAS (selecao de coluna) para as memorias dinamicas
        oVRAM_RAS    : out  std_logic;                             -- Pino 13 - Saida de RAS (selecao de linha) para as memorias dinamicas
        oVRAM_WR     : out  std_logic;                             -- Pino 14 - Sinal de escrita para as memorias dinamicas
                                                                  
        iVERT50_60   : in   std_logic;                             -- Pino 1 - Selecao de frequencia vertical entre 50Hz ou 60Hz
        oINT         : out  std_logic;                             -- Pino 34 - Interrupcao da CPU. Ocorre a cada 50hz ou 60Hz (Depende de VERT50_60)
                                     
        oKEYBOARD    : out  std_logic;                             -- Pino 10 - Aviso de leitura de teclado e da porta EAR
        oSOUND       : out  std_logic;                             -- Pino 24 - Saida de som 1 bit
        oMIC         : out  std_logic                              -- Pino 23 - Saida de audio para o gravador cassete
                            
                                                           
    );                       
end entity;
        
architecture behavior of top is

    signal s_CompSync            : std_logic;
   
begin

   ula1: entity work.ula 
	port map 
	(
        OSC        => iOSC,         
                    
        CPU        => oCPU,        
                    
        SUBCARRIER => oSUBCARRIER,     
                    
        RED        => oRED,          
        GREEN      => oGREEN,         
        BLUE       => oBLUE,         
        BRIGHT     => oBRIGHT,        
        CSYNC      => s_CompSync,        
        HSYNC      => oHSYNC, 
        VSYNC      => oVSYNC, 
        BURSTGATE  => oBURSTGATE,    
                    
        A14        => iA14,            
        A15        => iA15,            
        MREQ       => iMREQ,        
        WR         => iWR,            
        RD         => iRD,            
                    
        VRAM_A     => oVRAM_A,         
        VRAM_CAS   => oVRAM_CAS,     
        VRAM_RAS   => oVRAM_RAS,     
        VRAM_WR    => oVRAM_WR,     
                    
        ULA_D      => iULA_D,         
                    
        VERT50_60  => iVERT50_60,     
                    
        INT        => oINT,            
                    
        CS         => iCS,            
                    
        KEYBOARD   => oKEYBOARD,    
        SOUND      => oSOUND,         
        MIC        => oMIC         
        
    );
    
    oCSYNC  <= s_CompSync;
    oCSYNC2 <= s_CompSync;


end architecture;
