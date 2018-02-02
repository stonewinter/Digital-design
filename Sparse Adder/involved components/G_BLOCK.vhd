library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity G_Block is
port
(
  G_in : in STD_LOGIC_VECTOR(1 downto 0);
  P_in : in STD_LOGIC;
  G_out : out STD_LOGIC
);
end G_Block;


architecture G_Block_arc of G_Block is
begin  
  G_out <= G_in(1) or (P_in and G_in(0));
end G_Block_arc;