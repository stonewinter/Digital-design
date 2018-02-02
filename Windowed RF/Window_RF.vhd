library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.math.all;

entity Final_WinRF is
generic(N_bits : INTEGER;
        N_windows : INTEGER;
        N_block : INTEGER);
port
(
  CLKm, CALLm, RETURNm, RSTm, ENABLEm, RD1m, RD2m, WRm : in STD_LOGIC;
  RD1mADDR, RD2mADDR, WRmADDR : in INTEGER range (4*N_block-1) downto 0 ;
  DATAINm : in STD_LOGIC_VECTOR(N_bits-1 downto 0);
  OUT1m, OUT2m : out STD_LOGIC_VECTOR(N_bits-1 downto 0);
  SPILLm, FILLm : out STD_LOGIC
);
end Final_WinRF;


architecture asd of Final_WinRF is
------ component -------
component WindowRF is
generic(
  Nbr_Windows : INTEGER; -- number of active register windows(GLOBAL block + IN block + LOCAL block + OUT block)
  Nbr_block : INTEGER -- number of regs in the IN/LOCAL/OUT block
);
port
(
  CLK, CALL_ext, RETURN_ext, RST : in STD_LOGIC;
  RD1_ADDR, RD2_ADDR, WR_ADDR : in INTEGER;
  SPILL, FILL : out STD_LOGIC;
  CWP_RD1_physical, CWP_RD2_physical, CWP_WR_physical : out INTEGER;
  SWP_RD1_physical, SWP_RD2_physical, SWP_WR_physical : out INTEGER
);
end component;

component RF_generic is
generic(N_bitsOfREG : INTEGER;
        N_regs : INTEGER);
port(
CLK: 		IN std_logic;
RESET: 	IN std_logic;
ENABLE: 	IN std_logic;
RD1: 		IN std_logic;
RD2: 		IN std_logic;
WR: 		IN std_logic;
ADD_WR: 	IN std_logic_vector(log2(N_regs)-1 downto 0);
ADD_RD1: 	IN std_logic_vector(log2(N_regs)-1 downto 0);
ADD_RD2: 	IN std_logic_vector(log2(N_regs)-1 downto 0);
DATAIN: 	IN std_logic_vector(N_bitsOfREG-1 downto 0);
OUT1: 		OUT std_logic_vector(N_bitsOfREG-1 downto 0);
OUT2: 		OUT std_logic_vector(N_bitsOfREG-1 downto 0)
);
end component;
------------------------  

----- signals-----------
signal intRD1mCWP, intRD2mCWP, intWRmCWP : INTEGER;
signal intRD1mSWP, intRD2mSWP, intWRmSWP : INTEGER;
signal sigRD1mphyCWP, sigRD2mphyCWP, sigWRmphyCWP : STD_LOGIC_VECTOR( log2(2*N_block*N_windows+N_block)-1 downto 0);
signal sigRD1mphySWP, sigRD2mphySWP, sigWRmphySWP : STD_LOGIC_VECTOR( log2(2*N_block*N_windows+N_block)-1 downto 0);
signal selRD1, selRD2, selWR : STD_LOGIC_VECTOR( log2(2*N_block*N_windows+N_block)-1 downto 0);
------------------------
begin
  
  map1: WindowRF generic map(Nbr_Windows=>N_windows, Nbr_block=>N_block)
        port map(
          CLK=>CLKm
        , CALL_ext=>CALLm
        , RETURN_ext=>RETURNm
        , RST=>RSTm
        , RD1_ADDR=>RD1mADDR
        , RD2_ADDR=>RD2mADDR
        , WR_ADDR=>WRmADDR
        , SPILL=>SPILLm
        , FILL=>FILLm
        , CWP_RD1_physical=>intRD1mCWP
        , CWP_RD2_physical=>intRD2mCWP
        , CWP_WR_physical=>intWRmCWP
        , SWP_RD1_physical=>intRD1mSWP
        , SWP_RD2_physical=>intRD2mSWP
        , SWP_WR_physical=>intWRmSWP
        );
  
  
  sigRD1mphyCWP <= std_logic_vector(to_unsigned(intRD1mCWP, log2(2*N_block*N_windows+N_block)));
  sigRD2mphyCWP <= std_logic_vector(to_unsigned(intRD2mCWP, log2(2*N_block*N_windows+N_block)));
  sigWRmphyCWP <= std_logic_vector(to_unsigned(intWRmCWP, log2(2*N_block*N_windows+N_block)));
  sigRD1mphySWP <= std_logic_vector(to_unsigned(intRD1mSWP, log2(2*N_block*N_windows+N_block)));
  sigRD2mphySWP <= std_logic_vector(to_unsigned(intRD2mSWP, log2(2*N_block*N_windows+N_block)));
  sigWRmphySWP <= std_logic_vector(to_unsigned(intWRmSWP, log2(2*N_block*N_windows+N_block)));
          
  
  map2: RF_generic generic map(N_bitsOfREG=>N_bits, N_regs=>(2*N_block*N_windows+N_block))
        port map(
          CLK=>CLKm
        , RESET=>RSTm
        , ENABLE=>ENABLEm
        , RD1=>RD1m
        , RD2=>RD2m
        , WR=>WRm
        , ADD_WR=>selWR
        , ADD_RD1=>selRD1
        , ADD_RD2=>selRD1
        , DATAIN=>DATAINm
        , OUT1=>OUT1m
        , OUT2=>OUT2m
        );

   selRD1 <= sigRD1mphySWP when RETURNm='1' else sigRD1mphyCWP;
   selRD2 <= sigRD2mphySWP when RETURNm='1' else sigRD2mphyCWP;
   selWR <= sigWRmphySWP when RETURNm='1' else sigWRmphyCWP;
             
end asd;
