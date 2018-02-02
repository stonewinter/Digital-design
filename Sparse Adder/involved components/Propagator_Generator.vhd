library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity PG is 
port
(
  A, B : in STD_LOGIC;
  P, G : out STD_LOGIC
);
end PG;

architecture arc of PG is
begin
  P <= A xor B;
  G <= A and B;
end arc;