library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity CS_ADDER_generic is 
generic(INPUT_Nbits : INTEGER;
        CS_subBlock_Nbr : INTEGER);
port
(
  AinVec : in STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0);
  BinVec : in STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0);
  CinVec : in STD_LOGIC_VECTOR(CS_subBlock_Nbr-1 downto 0);
  SumVec : out STD_LOGIC_VECTOR(INPUT_Nbits-1 downto 0)
);
end CS_ADDER_generic;



architecture STRUC of CS_ADDER_generic is
-------------- internal components --------------
component CS_Block is 
generic(CSB_Nbr : INTEGER);
port
(
  A_Block : in STD_LOGIC_VECTOR(CSB_Nbr-1 downto 0);
  B_Block : in STD_LOGIC_VECTOR(CSB_Nbr-1 downto 0);
  Cin_Block : in STD_LOGIC;
  Sum_Block : out STD_LOGIC_VECTOR(CSB_Nbr-1 downto 0);
  Cout_Block : out STD_LOGIC
);
end component;
-------------------------------------------------

----------- internal signals ------------------
signal Cout_Block_inter : STD_LOGIC;
-----------------------------------------------

begin  

-------------- internal connection --------------
  blockGenerate:
  for i in 0 to CS_subBlock_Nbr-1 generate
    blockMap: 
    CS_Block generic map(CSB_Nbr=>(INPUT_Nbits/CS_subBlock_Nbr))
    port map(
              A_Block => AinVec( (i+1)*(INPUT_Nbits/CS_subBlock_Nbr)-1 downto i*(INPUT_Nbits/CS_subBlock_Nbr) )
            , B_Block => BinVec( (i+1)*(INPUT_Nbits/CS_subBlock_Nbr)-1 downto i*(INPUT_Nbits/CS_subBlock_Nbr) ) 
            , Cin_Block => CinVec(i)
            , Sum_Block => SumVec( (i+1)*(INPUT_Nbits/CS_subBlock_Nbr)-1 downto i*(INPUT_Nbits/CS_subBlock_Nbr) )
            , Cout_Block => Cout_Block_inter
            );
  end generate;
-------------------------------------------------  
end STRUC;