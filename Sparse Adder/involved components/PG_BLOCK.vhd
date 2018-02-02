library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity PG_Block is
port
(
  P_in, G_in : in STD_LOGIC_VECTOR(1 downto 0);
  P_out, G_out : out STD_LOGIC
);
end PG_Block;



architecture arc_PG_Block of PG_Block is
begin
  P_out <= P_in(1) and P_in(0);
  G_out <= G_in(1) or ( P_in(1) and G_in(0) );
end arc_PG_Block;
