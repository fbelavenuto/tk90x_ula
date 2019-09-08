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
 
 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ula is
    port (
        
        OSC         : in   std_logic;                        -- Pino 11 - OSC - entrada de 14.30244 Mhz, vindo do TK
                                                             
        SUBCARRIER  : out  std_logic;                        -- Pino 39 - Subcarrier - 3.575611 Mhz - Subportadora de Croma e
                                                             -- tambem usado para etapa de oscilacao das fonte de +12V e -5V
                                                             
                                                             -- Saida de Video digital
        RED         : out  std_logic;                        -- Pino 21 - Vermelho
        GREEN       : out  std_logic;                        -- Pino 19 - Verde
        BLUE        : out  std_logic;                        -- Pino 22 - Azul
        BRIGHT      : out  std_logic;                        -- Pino 18 - Brilho
        CSYNC       : out  std_logic;                        -- Pino 33 - Sincronismo Composto
        HSYNC       : out  std_logic;                        -- Nao presente no CI original, e a saida de Sincronismo Horizontal
        VSYNC       : out  std_logic;                        -- Nao presente no CI original, e a saida de Sincronismo Vertical
        BURSTGATE   : out  std_logic;                        -- Pino 35 - Marcacao do Color Burst para o CI LM1886
                                                             
                                                             -- interface com o Z80
        A14         : in   std_logic;                        -- Pino 37 - Linha A14 do Z80
        A15         : in   std_logic;                        -- Pino 38 - Linha A15 do Z80
        MREQ        : in   std_logic;                        -- Pino 15 - Linha MREQ do Z80
        WR          : in   std_logic;                        -- Pino 16 - Linha WR do Z80
        RD          : in   std_logic;                        -- Pino 17 - Linha RD do Z80
        CPU         : out  std_logic;                        -- Pino 36 - clock com contencao para o Z80 - 3.57Mhz 
        CS          : in   std_logic;                        -- Pino 2 - Combinacao de IORQ e linha A0 - Monitora o acesso a porta 254
        ULA_D       : in   std_logic_vector ( 7 downto 0 );  -- Pinos 25 a 32 - Entrada de Dados da ULA. 
                                                             
                                                             -- interface com memorias dinamicas
        VRAM_A      : out  std_logic_vector ( 6 downto 0 );  -- Pinos 3 a 9 - Linhas A0 a A6. Sao multiplexadas em linhas em colunas
        VRAM_CAS    : out  std_logic;                        -- Pino 12 - Saida de CAS (selecao de coluna) para as memorias dinamicas
        VRAM_RAS    : out  std_logic;                        -- Pino 13 - Saida de RAS (selecao de linha) para as memorias dinamicas
        VRAM_WR     : out  std_logic;                        -- Pino 14 - Sinal de escrita para as memorias dinamicas
                                                             
        VERT50_60   : in   std_logic;                        -- Pino 1 - Selecao de frequencia vertical entre 50Hz ou 60Hz
        INT         : out  std_logic;                        -- Pino 34 - Interrupcao da CPU. Ocorre a cada 50hz ou 60Hz (Depende de VERT50_60)
                                                             
        KEYBOARD    : out  std_logic;                        -- Pino 10 - Aviso de leitura de teclado e da porta EAR
        SOUND       : out  std_logic;                        -- Pino 24 - Saida de som 1 bit
        MIC         : out  std_logic                         -- Pino 23 - Saida de audio para o gravador cassete
        
    );
end entity;

architecture rtl of ula is

    signal clk7           : std_logic := '0';

    signal hcc            : unsigned ( 9 downto 0 ) := ( OTHERS => '0' );
    signal hc             : unsigned ( 8 downto 0 ) := ( OTHERS => '0' );
    signal vc             : unsigned ( 8 downto 0 ) := ( OTHERS => '0' );

    signal INT_n          : std_logic := '1';

    signal Border_n       : std_logic := '1';
    signal Vout           : std_logic := '1';
    signal Vout_Delayed   : std_logic := '1';
    signal SLoad          : std_logic := '0';
    signal AOLatch_n      : std_logic := '1';
    signal BitmapReg      : std_logic_vector ( 7 downto 0 ) := ( OTHERS => '0' );
    signal SRegister      : std_logic_vector ( 7 downto 0 ) := ( OTHERS => '0' );
    signal AttrReg        : std_logic_vector ( 7 downto 0 ) := ( OTHERS => '0' );
    signal AttrOut        : std_logic_vector ( 7 downto 0 ) := ( OTHERS => '0' );
    signal FlashCnt       : unsigned ( 5 downto 0 ) := ( OTHERS => '0' );
    signal Pixel          : std_logic := '0';
    
    signal rI,rG,rR,rB    : std_logic := '0';
    signal VSync_n        : std_logic := '1';
    signal HSync_n        : std_logic := '1';
    signal VBlank_n       : std_logic := '1';
    signal HBlank_n       : std_logic := '1';
    signal burst          : std_logic := '0';
        
    signal BorderColor    : std_logic_vector ( 2 downto 0 ) := "100";    
    signal rMic           : std_logic := '0';
    signal rSpk           : std_logic := '0';
    
    signal ioreq_n        : std_logic := '0';
    signal CLKContention  : std_logic := '0';
    signal WaitSignal     : std_logic := '0';
    signal cdet1          : std_logic := '0';
    signal cdet2          : std_logic := '0';

    signal ioreqtw3       : std_logic := '0';
    signal mreqt23        : std_logic := '0';
    signal CPUClk         : std_logic := '0';
    signal subc           : std_logic := '0';
    
    signal ram16          : std_logic := '1';

    signal cpubus_en      : std_logic;
    signal vidbus_en      : std_logic;
    
    signal AL1            : std_logic := '1';
    signal AL2            : std_logic := '1';
    signal VCrst          : std_logic := '0';
    
    signal cCAS           : std_logic;
    signal cRAS           : std_logic;
    signal vCAS           : std_logic;
    signal vRAS           : std_logic;
    signal CAS            : std_logic := '1';    
    signal RAS            : std_logic := '1';
    signal RAS_Delayed    : std_logic := '1';
    
    signal cnt_refresh    : unsigned ( 12 downto 0 )         := ( OTHERS => '0' );
    signal VA             : std_logic_vector ( 13 downto 0 ) := ( OTHERS => '0' );
    signal VidClock       : std_logic;    
    
begin
    
    -- Contador Mestre
    process ( OSC )
    begin        
        if rising_edge( OSC ) then
            
            if ( hcc = 911 ) then
            
                hcc <= ( OTHERS => '0' );
                
            else
            
                hcc <= hcc + 1;
                
            end if;
            
        end if;
    end process;
    
    -- OSC esta a 14Mhz, logo o bit 0 sera o nosso clock de 7Mhz necessario em algumas partes da ULA   
    clk7 <= not hcc( 0 ); 
    
    -- Os demais bits fazem o contador horizontal de 0 a 455
    -- Na pratica ele tambem pulsa a 7Mhz porque o bit 0 foi descartado
    hc( 8 downto 0 ) <= hcc( 9 downto 1 );

    -- contador Vertical
    process( clk7 )
    begin
        if falling_edge( clk7 ) then

            VCrst <= '0';

            if ( hc = 455 ) then
                if ( ( vc = 261 and VERT50_60 = '1' ) or
                     ( vc = 311 and VERT50_60 = '0' ) ) then
                      
                    vc <= ( OTHERS => '0' );
                    VCrst <= '1';
                    
                else
                
                    vc <= vc + 1;
                    
                end if;
            end if;

        end if;
    end process;
    
    -- HBlank - Periodo entre uma linha e outra. Nas TVs antigas era o tempo necessario para reposicionar o feixe de eletrons no comeco da nova linha.
	-- Tem duracao de 96 ciclos de clock (13,2us)
    process( clk7 )
    begin        
        if falling_edge( clk7 ) then

            if ( hc = 320 ) then
            
                HBlank_n <= '0';
                
            elsif ( hc = 416 ) then
            
                HBlank_n <= '1';
                
            end if;

        end if;
    end process;

    -- HSync - Ocorre dentro do HBlank e informa o comeco de uma nova linha
	-- Tem duracao de 32 ciclos (4,4us)
    process( clk7 )
    begin
        if falling_edge( clk7 ) then

            if ( hc = 340 ) then
            
                HSync_n <= '0';
                
            elsif ( hc = 372 ) then
            
                HSync_n <= '1';
                
            end if;

        end if;
    end process;

    -- Burstgate - Ocorre logo após o HSync
	-- Tem duracao de 32 ciclos (4,4us)
    process( clk7 )
    begin        
        if falling_edge( clk7 ) then

            if ( hc = 372 ) then
            
                burst <= '1';
                
            elsif ( hc = 404 ) then
            
                burst <= '0';
                
            end if;

        end if;
    end process;

    -- VBlank - Nas TVs antigas, periodo que o feixe de eletrons era reposicionado no comeco da tela para um novo quadro da imagem
	-- O pino de selecao de frequencia da ULA e levado em conta para acertar a temporizacao
    process( clk7 )
    begin
        if falling_edge( clk7 ) then

            if ( ( vc = 224 and VERT50_60 = '1' ) or
                 ( vc = 248 and VERT50_60 = '0' )) then
                 
                VBlank_n <= '0';
                
            elsif ( ( vc = 232 and VERT50_60 = '1' ) or
                    ( vc = 256 and VERT50_60 = '0' )) then
                     
                VBlank_n <= '1';
                
            end if;

        end if;
    end process;
    
    -- VSync - Pulso que indica um novo quadro de imagem
    -- O pino de selecao de frequencia da ULA e levado em conta para acertar a temporizacao
    process( clk7 )
    begin
        if falling_edge( clk7 ) then
            
            if ( ( vc = 224 and VERT50_60 = '1' ) or
                 ( vc = 248 and VERT50_60 = '0' )) then
                 
                VSync_n <= '0';
                
            elsif ( ( vc = 228 and VERT50_60 = '1' ) or
                    ( vc = 252 and VERT50_60 = '0' )) then
                     
                VSync_n <= '1';
                
            end if;
            
        end if;
    end process;
        
    -- INT ocorre a cada 50 ou 60Hz, dependendo da selecao de frequencia
    process( clk7 )
    begin
        if falling_edge( clk7 ) then

            if ( ( vc = 223 and hc = 275 and VERT50_60 = '1' ) or 
                 ( vc = 247 and hc = 275 and VERT50_60 = '0' )) then
                 
                INT_n <= '0';
                
            elsif ( ( vc = 223 and  hc = 338 and VERT50_60 = '1' ) or
                    ( vc = 247 and  hc = 338 and VERT50_60 = '0' )) then
                     
                INT_n <= '1';
                
            end if;

        end if;
    end process;

    --Gera o sinal RAM16, quando a CPU quer fazer um acesso nos primeiros 16Kb de RAM que e controlado pela ULA
    ram16 <= '0' when MREQ = '0' and A14 = '1' and A15 = '0' else '1';

    -- Sinal de Border (1 quando esta desenhamdo um pixel do "miolo", 0 quando desenha um pixel da borda)
    process( clk7 )
    begin
        if falling_edge( clk7 ) then
        
            if ( ( vc( 7 ) = '1' and vc( 6 ) = '1' ) or 
				 vc( 8 ) = '1' or 
				 hc( 8 ) = '1'
				) then
            
                Border_n <= '0';
                
            else
            
                Border_n <= '1';
                
            end if;
            
        end if;
    end process;

    -- Geracao do Vout ( Mudanca entre borda e "miolo" )
	-- Se Vout = 0, estamos dentro da tela
    process ( VC, hc )
    begin
        if ( vc( 7 ) = '1' and vc( 6 ) = '1' ) or vc( 8 ) = '1' then     -- Borda vertical
        
            Vout <= '1';
            
        elsif ( hc >= "000001011" and hc < "100001100" ) then
        
            Vout <= '0';
            
        else
        
            Vout <= '1';
            
        end if;
    end process;
	
    -- Geramos o sinal de Vout com atraso
    process ( OSC )
    begin
        if rising_edge( OSC ) then
        
            Vout_delayed <= Vout;
            
        end if;
    end process;

    
    -- AOLatch
    AOLatch_n <= '0' when hc( 2 downto 0 ) = "101" else '1';            -- ciclos de refresh 5 e 13
	
	-- AL1 e AL2 - Durante o refresh das memorias dinamicas, tambem devem ser lidos os bytes para os pixels (AL1) e os bytes para os atributos (AL2)
    AL1 <= '0' when Border_n = '1' and ( hc( 3 downto 1 ) = "100" or hc( 3 downto 1 ) = "110" ) else '1';
    AL2 <= '0' when Border_n = '1' and ( hc( 3 downto 1 ) = "101" or hc( 3 downto 1 ) = "111" ) else '1';

    -- Buffer para os Pixels - Fazemos uma cópia para usar posteriormente durante o envio para a saida RGB
    process( AL1 )
    begin
        if rising_edge( AL1 ) then
        
            BitmapReg <= ULA_D;
            
        end if;
    end process;
	
	-- Buffer para os Atributos - Fazemos uma cópia para usar posteriormente durante o envio para a saida RGB
    process( AL2 )
    begin
        if rising_edge( AL2 ) then
        
            AttrReg <= ULA_D;
            
        end if;
    end process;
	
	-- SLoad - Em alguns ciclos de refresh das memorias dinamicas os bits devem ser enviados a tela um a um. 
    -- Este sinal avisa quando o proximo byte esta pronto pra ser enviado	
    process( clk7 )
    begin
        if falling_edge( clk7 ) then
        
            if ( hc( 2 ) = '1' and hc( 1 ) = '0' and hc( 0 ) = '0' and Vout = '0' ) then            -- ciclos de refresh 4 e 12
            
                SLoad <= '1';
                
            else
            
                SLoad <= '0';
                
            end if;
            
        end if;
    end process;

    -- Shift - Pega o byte (que pode ser um pixel ou um atributo) e empurra um bit (shift) para a esquerda.
    process( clk7 )
    begin
        if rising_edge( clk7 ) then
        
            if ( SLoad = '1' ) then
            
                SRegister <= BitmapReg;
            else
            
                SRegister <= SRegister( 6 downto 0 ) & '0';
                
            end if;
            
        end if;
    end process;
	

    -- Delay para o buffer dos atributos
    process( Vout_delayed, AOLatch_n, BorderColor )
    begin
    
        if Vout_delayed = '1' then
        
            AttrOut <= "00" & BorderColor & BorderColor;
            
        elsif falling_edge( AOLatch_n ) then
        
            AttrOut <= AttrReg;
            
        end if;
        
    end process;

    -- Contador do Flash. Usado para calcular a velocidade que pisca 
    process( VSync_n )
    begin
        if falling_edge( VSync_n ) then
        
            FlashCnt <= FlashCnt + 1;
            
        end if;
    end process;
    
	
  	 -- Testa se o byte lido e "paper" (Pixel=0) ou "ink" (Pixel=1). 
	 -- Somente o bit 7 (mais a esquerda) e colocado na tela. Os proximos aguardam o shift acontecer 
	 -- Notar que o FlashCnt inverte a condicao quanto e a hora de piscar
    Pixel <= SRegister( 7 ) xor ( AttrOut( 7 ) and FlashCnt( 5 ) );


	-- Colocarmos as informacoes nas variaveis de RGB
    process( HBlank_n, VBlank_n, Pixel, AttrOut )
    begin
        if ( HBlank_n = '1' and VBlank_n = '1' ) then
            if ( Pixel = '1' ) then --Se e ink
            
                rI <= AttrOut( 6 );
                rG <= AttrOut( 2 );
                rR <= AttrOut( 1 );
                rB <= AttrOut( 0 );
                
            else --se e paper
            
                rI <= AttrOut( 6 );
                rG <= AttrOut( 5 );
                rR <= AttrOut( 4 );
                rB <= AttrOut( 3 );
                
            end if;
        else -- esta fora da tela (periodos de "blank"), entao, preto
        
            rI <= '0';
            rG <= '0';
            rR <= '0';
            rB <= '0';
            
        end if;
    end process;
    
    

    -- Em alguns ciclos de refresh o acesso as memorias dinamicas deve ser feito pela ULA
    vidbus_en <=   '1' when Border_n = '1' and hc( 3 downto 0 ) = "0000" else
                   '0' when Border_n = '1' and hc( 3 downto 0 ) = "1000";
             
	-- Quando a ULA nao acessa as memorias dinamicas, a vez e da CPU
    cpubus_en <= not vidbus_en;
    

    ------------------------------------------------------------------
    --                                                              --
    --           Geracao da contencao de clock da CPU               --
    --                                                              --
    ------------------------------------------------------------------
    
    -- Para ficar mais claro no codigo, atribuimos o pino de acesso da ULA a uma variavel
    ioreq_n <= CS;
    
    -- Gera os sinais de IORQ e MREQ atrasados, necessarios para a verificacao da contencao da CPU
    process( CPUClk )
    begin        
        if rising_edge( CPUClk ) then
        
            ioreqtw3 <= ioreq_n;
            mreqt23  <= MREQ;
            
        end if;
    end process;
    
    process ( CLK7 )
    begin
        if falling_edge( CLK7 ) then
        
            if Border_n = '1' and ( hc( 3 downto 0 ) >= "0011" and hc( 3 downto 0 ) <= "1110" ) then
            
                WaitSignal <= '0';
                
            else
            
                WaitSignal <= '1';
                
            end if;
            
        end if;
    end process;

    cdet1         <= ( A15 or not A14 ) and ioreq_n;         -- =0 se A15 e A14 forem nivel alto ou se houve um acesso na porta 254 da ULA
    cdet2         <= not ( ioreqtw3 and mreqt23 );           -- =0 quando ioreqtw3(IOREQ atrasado) e mreqt23(MREQ atrasado) forem 1
    CLKContention <= not ( WaitSignal or cdet1 or cdet2 );   -- =1 (contencao) quando todos os sinais forem 0

    process( OSC )
    begin        
        if rising_edge( OSC ) then
        
            -- Clock para a CPU. 
            -- Pulsa a 3.5 Mhz com hc(0), porem se existe contencao, ela fica em nivel alto. 
            CPUClk  <= CLKContention or hc( 0 );

            -- Gera o subcarrier. Aqui pegamos apenas o clock de 3.5Mhz, porque o subcarrier não pode parar.
            subc    <= hc( 0 ); 

        end if;
    end process;


    ------------------------------------------------------------------
    --                                                              --
    --                   Interface da Porta 254                     --
    --                                                              --
    ------------------------------------------------------------------
    process( clk7 )
    begin        
        if falling_edge( clk7 ) then
        
            -- Se a ULA foi selecionada e e uma operacao de escrita
            if ( CS = '0' and WR = '0' and vidbus_en = '1') then
            
                rSpk        <= ULA_D( 4 );              -- Escreve bit 4 na saida de som 
                rMic        <= ULA_D( 3 );              -- Escreve bit 3 na saida Mic
                BorderColor <= ULA_D( 2 downto 0 );     -- Guarda os bits de 0 a 2 como cor da borda
                
            end if;
            
            -- Se a ULA foi selecionada e e uma operacao de leitura
            if ( CS = '0' and RD = '0' and vidbus_en = '1') then
            
                KEYBOARD <= '0'; -- ativa o pino "KEYBOARD", dizendo para a ROM que e hora de ler o teclado e a porta EAR 
            
            else
            
                KEYBOARD <= '1'; -- saida "KEYBOARD" inativa    
                
            end if;
            
        end if;    
    end process;
    
    ------------------------------------------------------------------
    --                                                              --
    --                Gerador de Refresh da DRAM                    --
    --                                                              --
    ------------------------------------------------------------------

    process (VidClock, VCrst)
    begin
    
        if( VCrst = '1' ) then
        
            cnt_refresh <= ( OTHERS => '0' );
            
        elsif falling_edge( VidClock ) then
        
            cnt_refresh <= cnt_refresh + 1;
            
        end if;
        
    end process;

    process ( vidbus_en, AL2, cnt_refresh )
    begin
    
        if vidbus_en = '0' then                        -- Fase da ULA
        
            VA( 0 ) <= cnt_refresh( 0 );
            VA( 1 ) <= cnt_refresh( 1 );
            VA( 2 ) <= cnt_refresh( 2 );
            VA( 3 ) <= cnt_refresh( 3 );
            VA( 4 ) <= cnt_refresh( 4 );
            VA( 5 ) <= cnt_refresh( 8 );
            VA( 6 ) <= cnt_refresh( 9 );
            VA( 7 ) <= cnt_refresh( 10 );

            if ( AL2 = '0' ) then
            
                VA( 8 )  <= cnt_refresh(11);
                VA( 9 )  <= cnt_refresh(12);
                VA( 10 ) <= '0';
                VA( 11 ) <= '1';
                VA( 12 ) <= '1';
                VA( 13 ) <= '0';
                
            else
            
                VA( 8 )  <= cnt_refresh( 5 );
                VA( 9 )  <= cnt_refresh( 6 );
                VA( 10 ) <= cnt_refresh( 7 );
                VA( 11 ) <= cnt_refresh( 11 );
                VA( 12 ) <= cnt_refresh( 12 );
                VA( 13 ) <= '0';
                
            end if;
        else
            VA( 13 downto 0 ) <= ( OTHERS => 'Z' );        -- Fase da CPU, entao libera o barramento de enderecos para o Z80
        end if;

    end process;

    
    process ( OSC )
    begin
        if rising_edge( OSC ) then
        
            -- Gera o sinal de RAS com atraso  
            RAS_Delayed <= RAS;
            
        end if;
    end process;

    process ( RAS_Delayed, vidbus_en, VA )
    begin
    
        if vidbus_en = '1' then                -- E a vez da CPU usar as memorias dinamicas
                                               
            VRAM_A <= ( OTHERS => 'Z' );       -- entao liberamos os pinos 
                                               
        else                                   -- E a vez da ULA usar
                                               
            if ( RAS_Delayed = '0' ) then      -- A linha ja foi posicionada?
                                               
                VRAM_A <= VA( 13 downto 7 );   -- posiciona a coluna
                                               
            else                                      
                                               
                VRAM_A <= VA( 6 downto 0 );    -- posiciona a linha
                                               
            end if;
        end if;
        
    end process;

    --
    -- Geradores do RAS e CAS
    --
    
    -- Geracao do cRAS
    process ( OSC )
    begin
        
        if ( falling_edge( OSC )) then
        
            -- O RAS vindo da CPU e gerado quando existe um acesso nos primeiros 16KB de RAM, que e controlada pela ULA
            cRAS <= ram16; 
            
        end if;
    
    end process;
    
    -- Geracao do cCAS
    process ( OSC )
    begin
        if ( falling_edge( OSC )) then
        
            -- O CAS da CPU acontece quando ja existe cRAS e e definida uma operacao de leitura ou escrita
            cCAS <= ( WR and RD ) or cRAS;
            
        end if;
    end process;

    -- Geracao do vRAS
    process ( OSC )
    begin
        if ( falling_edge( OSC )) then
        
            vRAS <= cpubus_en nand (( hc( 0 ) ) nand AL1 );
            
        end if;
    end process;

    -- Geracao do vCAS
    vCAS <= cpubus_en nand ( not ( hc( 0 ) ) nand clk7 );

    -- Clock para o contador de Refresh das memorias dinamicas
    VidClock <= not ( vRAS );

    RAS <= cRAS and vRAS; -- Combina o cRAS e o vRAS para formar o RAS final 
    CAS <= cCAS and vCAS; -- Combina o cCAS e o vCAS para formar o CAS final
    

    ------------------------------------------------------------------
    --                                                              --
    --      Conexao dos sinais com os pinos de saida do CPLD        --
    --                                                              --
    ------------------------------------------------------------------
    
    -- Contencao da CPU
    -- Lembrando que no TK existe um transistor que inverte essa saida antes do Z80, logo temos que sair invertido aqui
    CPU <= not CPUClk;
    
    -- Pinos para as memorias dinamicas
    VRAM_RAS <= RAS; 
    VRAM_CAS <= CAS;
    VRAM_WR  <= cpubus_en or WR; -- Se e a vez da CPU usar a memoria e se houve uma operacao de escrita, ativa o sinal.
                                 -- A ULA na pratica nunca escreve nas memorias dinamicas, apenas le o seu conteudo e monta a tela. 
    
    -- Saida de video
    RED    <= rR;
    GREEN  <= rG;
    BLUE   <= rB;
    BRIGHT <= rI and ( rR or rg or rB );   -- Saida de Bright. Temos que combinar com os bits de cor para evita bright no preto
    CSYNC  <= HSync_n and VSync_n;
    HSYNC  <= HSync_n;
    VSYNC  <= VSync_n;


    -- outros pinos    
    BURSTGATE   <= burst;
    SUBCARRIER  <= subc;
    MIC         <= rMic;
    SOUND       <= rSpk;
    INT         <= INT_n;
    
    
end architecture;
