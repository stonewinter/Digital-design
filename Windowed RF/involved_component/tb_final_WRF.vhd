library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.math.all;

entity tb_final is
end tb_final;

architecture asd of tb_final is
------- sim component -----
component Final_WinRF is
generic(N_bits : INTEGER;
        N_windows : INTEGER;
        N_block : INTEGER);
port
(
  CLKm, CALLm, RETURNm, RSTm, ENABLEm, RD1m, RD2m, WRm : in STD_LOGIC;
  RD1mADDR, RD2mADDR, WRmADDR : in INTEGER range (2*N_windows*N_block-1) downto 0 ;
  DATAINm : in STD_LOGIC_VECTOR(N_bits-1 downto 0);
  OUT1m, OUT2m : out STD_LOGIC_VECTOR(N_bits-1 downto 0);
  SPILLm, FILLm : out STD_LOGIC
);
end component;
---------------------------

------- sim signals -----------
constant c_N_bits : INTEGER := 16;
constant c_N_windows : INTEGER := 8;
constant c_N_block : INTEGER := 8;

signal sim_CLKm : std_logic := '1';
signal sim_CALLm, sim_RETURNm, sim_RSTm, sim_ENABLEm, sim_RD1m, sim_RD2m, sim_WRm : STD_LOGIC;
signal sim_RD1mADDR, sim_RD2mADDR, sim_WRmADDR : INTEGER range (4*c_N_block-1) downto 0 ;
signal sim_DATAINm : STD_LOGIC_VECTOR(c_N_bits-1 downto 0);
signal sim_OUT1m, sim_OUT2m : STD_LOGIC_VECTOR(c_N_bits-1 downto 0);
signal sim_SPILLm, sim_FILLm : STD_LOGIC;
-------------------------------
begin
  
  simMap: Final_WinRF generic map(N_bits=>c_N_bits, N_windows=>c_N_windows, N_block=>c_N_block)
          port map(
            sim_CLKm
          , sim_CALLm
          , sim_RETURNm
          , sim_RSTm
          , sim_ENABLEm
          , sim_RD1m
          , sim_RD2m
          , sim_WRm
          , sim_RD1mADDR
          , sim_RD2mADDR
          , sim_WRmADDR
          , sim_DATAINm
          , sim_OUT1m
          , sim_OUT2m
          , sim_SPILLm
          , sim_FILLm
          );
          
          
  CLK_process: process
               begin
                 sim_CLKm <= not sim_CLKm;
                 wait for 2 ns;
               end process;
               
  sim_process: process
               begin
                 sim_CALLm <= '0';
                 sim_RETURNm <= '0';
                 sim_RSTm <= '0';
                 sim_ENABLEm <= '0';
                 sim_RD1m <= '0';
                 sim_RD2m <= '0';
                 sim_WRm <= '0';
                 sim_RD1mADDR <= 0;
                 sim_RD2mADDR <= 0;
                 sim_WRmADDR <= 0;
                 sim_DATAINm <= (others=>'1');
                 wait for 1 ns;
                 
                 sim_CALLm <= '0';
                 sim_RETURNm <= '0';
                 sim_RSTm <= '1';
                 sim_ENABLEm <= '0';
                 sim_RD1m <= '0';
                 sim_RD2m <= '0';
                 sim_WRm <= '1';
                 sim_RD1mADDR <= 0;
                 sim_RD2mADDR <= 0;
                 sim_WRmADDR <= 0;                 
                 sim_DATAINm <= (others=>'1');
                 wait for 5 ns;
                 
                 sim_CALLm <= '0';
                 sim_RETURNm <= '0';
                 sim_RSTm <= '0';
                 sim_ENABLEm <= '1';
                 sim_RD1m <= '0';
                 sim_RD2m <= '0';
                 sim_WRm <= '1';
                 sim_RD1mADDR <= 0;
                 sim_RD2mADDR <= 0;
                 sim_WRmADDR <= 0;                 
                 sim_DATAINm <= (others=>'1');
                 wait for 5 ns;
                 
                 loop_sim_WR_call:
                 for i in 0 to (4*c_N_block-1) loop
                   sim_CALLm <= '1';
                   sim_RETURNm <= '0';
                   sim_ENABLEm <= '1';
                   sim_RD1m <= '0';
                   sim_RD2m <= '0';
                   sim_WRm <= '1';
                   sim_WRmADDR <= i;
                   sim_DATAINm <= (others=>'1');
                   wait for 8 ns;
                 end loop;
                 
                 
                 loop_sim_RD_call:
                 for i in 0 to (4*c_N_block-1) loop
                   sim_CALLm <= '1';
                   sim_RETURNm <= '0';
                   sim_ENABLEm <= '1';
                   sim_RD1m <= '1';
                   sim_RD2m <= '1';
                   sim_WRm <= '0';
                   sim_RD1mADDR <= i;
                   sim_RD2mADDR <= i;
                   wait for 8 ns;
                 end loop;
                 
                 
                 loop_sim_WR_return:
                 for i in 0 to (4*c_N_block-1) loop
                   sim_CALLm <= '0';
                   sim_RETURNm <= '1';
                   sim_ENABLEm <= '1';
                   sim_RD1m <= '0';
                   sim_RD2m <= '0';
                   sim_WRm <= '1';
                   sim_WRmADDR <= i;
                   sim_DATAINm <= (others=>'1');
                   wait for 8 ns;
                 end loop;
                 
                 
                 loop_sim_RD_return:
                 for i in 0 to (4*c_N_block-1) loop
                   sim_CALLm <= '0';
                   sim_RETURNm <= '1';
                   sim_ENABLEm <= '1';
                   sim_RD1m <= '1';
                   sim_RD2m <= '1';
                   sim_WRm <= '0';
                   sim_RD1mADDR <= i;
                   sim_RD2mADDR <= i;
                   wait for 8 ns;
                 end loop;
                 

               end process;
end asd;
