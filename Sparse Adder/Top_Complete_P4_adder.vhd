library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity Complete_P4_adder is
generic(N : INTEGER);
port
(
  P4_adder_Ain : in STD_LOGIC_VECTOR(N-1 downto 0);
  P4_adder_Bin : in STD_LOGIC_VECTOR(N-1 downto 0);
  P4_adder_Cin : in STD_LOGIC;
  P4_adder_Sout : out STD_LOGIC_VECTOR(N-1 downto 0);
  P4_adder_Cout : out STD_LOGIC
);
end Complete_P4_adder;



architecture P4_arc of  Complete_P4_adder is
------------ internal component -------------
component Sparse_Tree is
generic(INPUTs_Nbr : INTEGER);
port
(
  SPARSE_Ain : in STD_LOGIC_VECTOR(INPUTs_Nbr-1 downto 0);
  SPARSE_Bin : in STD_LOGIC_VECTOR(INPUTs_Nbr-1 downto 0);
  SPARSE_Cout : out STD_LOGIC_VECTOR(INPUTs_Nbr/4-1 downto 0)
);
end component;


component CS_ADDER_generic is 
generic(INPUT_Nbits : INTEGER;
        CS_subBlock_Nbr : INTEGER);
port
(
  AinVec : in STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0);
  BinVec : in STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0);
  CinVec : in STD_LOGIC_VECTOR(CS_subBlock_Nbr-1 downto 0);
  SumVec : out STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0)
);
end component;
---------------------------------------------

--------------- internal signals ---------------
signal SPARSE_Cout_inter, CinVec_inter : STD_LOGIC_VECTOR(N/4-1 downto 0);
------------------------------------------------
begin

------------ internal connections --------------
  Sparse_Tree_Map:
  Sparse_Tree generic map(INPUTs_Nbr=>N)
  port map(SPARSE_Ain=>P4_adder_Ain , SPARSE_Bin=>P4_adder_Bin , SPARSE_Cout=>SPARSE_Cout_inter );
    
  P4_adder_Cout <= SPARSE_Cout_inter(N/4-1);
  CinVec_inter <= SPARSE_Cout_inter(N/4-2 downto 0) & P4_adder_Cin;
    
  CS_ADDER_Map:
  CS_ADDER_generic generic map(INPUT_Nbits=>N, CS_subBlock_Nbr=>N/4)
  port map(AinVec=>P4_adder_Ain
         , BinVec=>P4_adder_Bin
         , CinVec=>CinVec_inter
         , SumVec=>P4_adder_Sout);
------------------------------------------------
  
  
end P4_arc;