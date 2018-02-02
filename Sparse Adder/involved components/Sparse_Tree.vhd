library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;



entity Sparse_Tree is
generic(INPUTs_Nbr : INTEGER);
port
(
  SPARSE_Ain : in STD_LOGIC_VECTOR(INPUTs_Nbr-1 downto 0);
  SPARSE_Bin : in STD_LOGIC_VECTOR(INPUTs_Nbr-1 downto 0);
  SPARSE_Cout : out STD_LOGIC_VECTOR(INPUTs_Nbr/4-1 downto 0)
);
end Sparse_Tree;




architecture Sparse_Tree_arc of Sparse_Tree is
  
type SigMatrix is array(INPUTs_Nbr-1 downto 0) of STD_LOGIC_VECTOR(INPUTs_Nbr-1 downto 0);

------------ internal components -------------
component PG is 
port
(
  A, B : in STD_LOGIC;
  P, G : out STD_LOGIC
);
end component;


component PG_Block is
port
(
  P_in, G_in : in STD_LOGIC_VECTOR(1 downto 0);
  P_out, G_out : out STD_LOGIC
);
end component;


component G_Block is
port
(
  G_in : in STD_LOGIC_VECTOR(1 downto 0);
  P_in : in STD_LOGIC;
  G_out : out STD_LOGIC
);
end component;
----------------------------------------------

-------------- internal signals --------------
signal P_inter, G_inter : SigMatrix;
----------------------------------------------

begin
  
---------- internal connnection --------------
  PG_Network:
  for i in 0 to INPUTs_Nbr-1 generate
  PG_Map: PG
  port map(A => SPARSE_Ain(i)
         , B => SPARSE_Bin(i)
         , P => P_inter(i)(i)
         , G => G_inter(i)(i) );
  end generate;
  
  PG_Block_generate_1st_Row:
  for i in 0 to (INPUTs_Nbr/2)-2 generate
  PG_Block_Map: PG_Block
  port map(P_in(1) => P_inter(2*i+3)(2*i+3)
         , P_in(0) => P_inter(2*i+2)(2*i+2)
         , G_in(1) => G_inter(2*i+3)(2*i+3)
         , G_in(0) => G_inter(2*i+2)(2*i+2)
         , P_out => P_inter(2*i+3)(2*i+2)
         , G_out => G_inter(2*i+3)(2*i+2) );
  end generate;
  
  PG_Block_generate_2nd_Row:
  for i in 0 to (INPUTs_Nbr/4)-2 generate
  PG_Block_Map: PG_Block
  port map(P_in(1) => P_inter(4*i+7)(4*i+6)
         , P_in(0) => P_inter(4*i+5)(4*i+4)
         , G_in(1) => G_inter(4*i+7)(4*i+6)
         , G_in(0) => G_inter(4*i+5)(4*i+4)
         , P_out => P_inter(4*i+7)(4*i+4)
         , G_out => G_inter(4*i+7)(4*i+4) );
  end generate;
  
  PG_Block_generate_3rd_Row:
  for i in 0 to (INPUTs_Nbr/8)-2 generate
  PG_Block_Map: PG_Block
  port map(P_in(1) => P_inter(8*i+15)(8*i+12)
         , P_in(0) => P_inter(8*i+11)(8*i+8)
         , G_in(1) => G_inter(8*i+15)(8*i+12)
         , G_in(0) => G_inter(8*i+11)(8*i+8)
         , P_out => P_inter(8*i+15)(8*i+8)
         , G_out => G_inter(8*i+15)(8*i+8) );
  end generate;  
  
  PG_Block_generate_4th_Row_map1:
  PG_Block  port map(P_in(1) => P_inter(27)(24)
                   , P_in(0) => P_inter(23)(16)
                   , G_in(1) => G_inter(27)(24)
                   , G_in(0) => G_inter(23)(16)
                   , P_out => P_inter(27)(16)
                   , G_out => G_inter(27)(16) );
                   
  
  PG_Block_generate_4th_Row_map2:
  PG_Block  port map(P_in(1) => P_inter(31)(24)
                   , P_in(0) => P_inter(23)(16)
                   , G_in(1) => G_inter(31)(24)
                   , G_in(0) => G_inter(23)(16)
                   , P_out => P_inter(31)(16)
                   , G_out => G_inter(31)(16) );
                   
  
  G_Block_map1: G_Block port map(G_in(1) => G_inter(1)(1)
                               , G_in(0) => G_inter(0)(0)
                               , P_in => P_inter(1)(1)
                               , G_out => G_inter(1)(0));
                               
  G_Block_map2: G_Block port map(G_in(1) => G_inter(3)(2)
                               , G_in(0) => G_inter(1)(0)
                               , P_in => P_inter(3)(2)
                               , G_out => G_inter(3)(0));
                               
  G_Block_map3: G_Block port map(G_in(1) => G_inter(7)(4)
                               , G_in(0) => G_inter(3)(0)
                               , P_in => P_inter(7)(4)
                               , G_out => G_inter(7)(0));
                               
  G_Block_map4: G_Block port map(G_in(1) => G_inter(11)(8)
                               , G_in(0) => G_inter(7)(0)
                               , P_in => P_inter(11)(8)
                               , G_out => G_inter(11)(0));  
                               
  G_Block_map5: G_Block port map(G_in(1) => G_inter(15)(8)
                               , G_in(0) => G_inter(7)(0)
                               , P_in => P_inter(15)(8)
                               , G_out => G_inter(15)(0));
                               
  G_Block_generate_Last_Row:
  for i in 1 to 4 generate
  G_Block_Generate_Map: G_Block
  port map(G_in(1) => G_inter(20+4*i-5)(16)
         , G_in(0) => G_inter(15)(0)
         , P_in => P_inter(20+4*i-5)(16)
         , G_out => G_inter(20+4*i-5)(0));
  end generate;                   
  
  
  Cout_generate:
  for i in 0 to (INPUTs_Nbr/4)-1 generate
  SPARSE_Cout(i) <= G_inter(4*i+3)(0);
  end generate;   
                                                                                                     
----------------------------------------------  
  
end Sparse_Tree_arc;