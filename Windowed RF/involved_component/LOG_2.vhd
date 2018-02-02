library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package math is
function log2 (Arg : positive) return natural;    
end package math;



package body math is 
    
function log2 (Arg : positive) return natural is
  variable temp    : integer := Arg;
  variable ret_val : integer := 0; --log2 of 0 should equal 1 because you still need 1 bit to represent 0
  begin    
               
  while temp > 0 loop
    ret_val := ret_val + 1;
    temp    := temp / 2;  
  end loop;
  
  return ret_val;
end function log2;

end package body math;
