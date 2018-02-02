library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.math.all;

entity RF_generic is
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
end RF_generic;

architecture asd of RF_generic is
  -- subtype define address
  subtype REG_INDEX is natural range (N_regs-1) downto 0;
  -- define register file
	type REG_FILE is array(REG_INDEX) of std_logic_vector(N_bitsOfREG-1 downto 0); -- define an array having 1-32 elements which has 64 bits
	signal REGISTERS : REG_FILE; 
  signal ADD_WR_sig, ADD_RD1_sig, ADD_RD2_sig : REG_INDEX;
  
begin
  ADD_WR_sig <= to_integer(unsigned(ADD_WR));
  ADD_RD1_sig <= to_integer(unsigned(ADD_RD1));
  ADD_RD2_sig <= to_integer(unsigned(ADD_RD2));
  
  CTRL_process: process(CLK, RESET, ENABLE)
                begin
                  if rising_edge(CLK) then
                      if RESET = '1' then
                          OUT1 <= (others=>'0');
                          OUT2 <= (others=>'0');
                      elsif ENABLE = '1' then
                          if WR = '1' then
                              REGISTERS(ADD_WR_sig) <= DATAIN;
                          end if;
                          if RD1 = '1' then
                              OUT1 <= REGISTERS(ADD_RD1_sig);
                          end if;
                          if RD2 = '1' then
                              OUT2 <= REGISTERS(ADD_RD2_sig);
                          end if;
                      end if;
                  end if;
                
                end process;
  
end asd;
