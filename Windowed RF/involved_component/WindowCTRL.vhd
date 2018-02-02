library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.math.all;

-- This window CTRL can deal with the a generic number of RF windows indicated by users
-- The SPILL signal indicates the situation where the RF is going to spill out if call subroutine agian.
-- The FILL signal indicates the situation where the RF is ready to accept the external stack to push back.
-- CALL_ext and RETURN_ext represents the external requesting signals.


entity WindowRF is
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
end WindowRF;


architecture asd of WindowRF is
--------- internal signals ---------------
-- CANSAVE represents the number of RF window available in RF. In those available spaces, the spill
-- won't occur if call the subroutine again.
-- CANRESTORE represents the number of RF window that can be returned by assigning the RETURN_ext signal to '1'.
-- CWP and SWP represent the pointer of current window and stack purpose-pushing-back window respectively.
signal CANSAVE, CANRESTORE, CWP, SWP : INTEGER;

begin
  
  SP_FI_PROCESS: process(CANSAVE, CANRESTORE, SWP, CWP)
                 --- combinational ----
                 --- SPILL & FILL can be simply managed in the combinational way
                 --- depending on the concurrent status of internal signals.
                 begin
                    ----------- SPILL -----------
                    if (CANSAVE = 0) then
                      SPILL <= '1';
                    else
                      SPILL <= '0';
                    end if;
                    ----------- SPILL -----------
                    
                    ----------- FILL -----------
                    if ((CANRESTORE /= 0) and (SWP = CWP)) then
                      FILL <= '1';
                    else
                      FILL <= '0';
                    end if;
                    ----------- FILL -----------
                 end process;

  
  CANSAVE_PROCESS: process(CANRESTORE)
                   ------ combinational ------
                   -- CANSAVE signal is related to the CANRESTORE signal in
                   -- terms of the number of RF windows. Thus, it can be managed
                   -- in the combinational way as well.
                   begin
                     --------- CANSAVE ----------
                     if (CANRESTORE <= Nbr_Windows-1) then
                       CANSAVE <= Nbr_Windows - CANRESTORE - 1;
                     else
                       CANSAVE <= 0;
                     end if;
                     --------- CANSAVE ----------
                   end process;
  
  
  CTRL_PROCESS: process(CLK, RST, CALL_ext, RETURN_ext)
                begin
                  if (RST = '1') then  -- reset procedure
                    CWP <= 0;
                    SWP <= 0;
                    CANRESTORE <= 0;
                  elsif rising_edge(CLK) then  
                 -------------- caling procedure --------------                 
                      if (CALL_ext = '1') then
                        CANRESTORE <= CANRESTORE + 1; -- In calling procedure, CANRESTORE can only be increased at a time since it records the # of 'restorable' windows
                        ------- CWP in calling ------
                        if (CWP >= Nbr_Windows-1) then -- In calling procedure, CWP is in a circular increment mode.
                          CWP <= 0;
                        else
                          CWP <= CWP + 1;
                        end if;
                        ------- CWP in calling ------
                        
                        ------- SWP in calling ------
                        if (SWP >= Nbr_Windows-1) then -- In calling procedure, SWP will be in circular once there's no RF window available.
                          SWP <= 0;
                        elsif (CANSAVE = 0) then
                          SWP <= SWP + 1;
                        end if;
                        ------- SWP in calling ------   
                 -------------- caling procedure --------------
                 
                 -------------- return procedure --------------
                      elsif (RETURN_ext = '1') then -- contrary to calling procedure, CANSTORE decreases in returning procedure.
                        if (CANRESTORE <= 0) then
                          CANRESTORE <= 0;
                        else
                          CANRESTORE <= CANRESTORE - 1;
                        end if;
                        ------- CWP in return -------
                        if (CWP <= 0) then            -- contrary to calling procedure, CWP is in a dcrease-circular mode in returning procedure.
                          if (CANRESTORE = 0) then
                            CWP <= 0;
                          else
                            CWP <= Nbr_Windows-1;
                          end if;
                        elsif (CANRESTORE /= 0) then
                          CWP <= CWP - 1;
                        end if;
                        ------- CWP in return -------
                        
                        ------- SWP in return -------
                        if (SWP <= 0) then         -- In returnning procedure, SWP will wait untill CWP compensates the ahead RF windows.
                          if (CANRESTORE = 0) then
                            SWP <= 0;
                          elsif (CWP = SWP) then
                            SWP <= Nbr_Windows-1;
                          end if;
                        elsif (CWP = SWP) then
                          SWP <= SWP - 1;
                        end if;
                        ------- SWP in return -------
                 -------------- return procedure -------------- 
                      end if;
                  end if;
                end process;
                
                
              
  
  ADDR_TRANS_PROC: process(SWP, CWP, RD1_ADDR, RD2_ADDR, WR_ADDR)
                   --- CWP can be decoded as a base address of each active window. It can be interpreted according to the assigned number of regs for each block.
                   --- RD1,RD2,WR input address are working like a offset within the active window.
                   --- The 1st block in physical addressable space is used for GLOBAL block.
                   --- As long as the input address indicates the last block in active window, it actually
                   --- visits the GLOBAL block. In this case, the physical address needs to be adjusted.
                   begin
                    
                   if (RD1_ADDR >= 3*Nbr_block) then
                     --- visit GLOBAL ---
                     CWP_RD1_physical <= RD1_ADDR - 3*Nbr_block;
                     SWP_RD1_physical <= RD1_ADDR - 3*Nbr_block;
                   elsif (RD1_ADDR >= 2*Nbr_block) then
                     --- circular move ---
                     if (CWP = Nbr_Windows-1 ) then
                       CWP_RD1_physical <= RD1_ADDR - Nbr_block;
                     else
                       CWP_RD1_physical <= (2*CWP+1)*Nbr_block + RD1_ADDR;
                     end if; 
                     
                     if (SWP = Nbr_Windows-1 ) then
                       SWP_RD1_physical <= RD1_ADDR - Nbr_block;
                     else
                       SWP_RD1_physical <= (2*SWP+1)*Nbr_block + RD1_ADDR;
                     end if; 
                   else
                     --- visit active window ---
                     CWP_RD1_physical <= (2*CWP+1)*Nbr_block + RD1_ADDR;
                     SWP_RD1_physical <= (2*SWP+1)*Nbr_block + RD1_ADDR;
                   end if;
                   
                   
                   if (RD2_ADDR >= 3*Nbr_block) then
                     --- visit GLOBAL ---
                     CWP_RD2_physical <= RD2_ADDR - 3*Nbr_block;
                     SWP_RD2_physical <= RD2_ADDR - 3*Nbr_block;
                   elsif (RD2_ADDR >= 2*Nbr_block) then
                     --- circular move ---
                     if (CWP = Nbr_Windows-1 ) then
                       CWP_RD2_physical <= RD2_ADDR - Nbr_block;
                     else
                       CWP_RD2_physical <= (2*CWP+1)*Nbr_block + RD2_ADDR;
                     end if; 
                     
                     if (SWP = Nbr_Windows-1 ) then
                       SWP_RD2_physical <= RD2_ADDR - Nbr_block;
                     else
                       SWP_RD2_physical <= (2*SWP+1)*Nbr_block + RD2_ADDR;
                     end if; 
                   else
                     --- visit active window ---
                     CWP_RD2_physical <= (2*CWP+1)*Nbr_block + RD2_ADDR;
                     SWP_RD2_physical <= (2*SWP+1)*Nbr_block + RD2_ADDR;
                   end if;
                   
                   
                   if (WR_ADDR >= 3*Nbr_block) then
                     --- visit GLOBAL ---
                     CWP_WR_physical <= WR_ADDR - 3*Nbr_block;
                     SWP_WR_physical <= WR_ADDR - 3*Nbr_block;
                   elsif (WR_ADDR >= 2*Nbr_block) then
                     --- circular move ---
                     if (CWP = Nbr_Windows-1 ) then
                       CWP_WR_physical <= WR_ADDR - Nbr_block;
                     else
                       CWP_WR_physical <= (2*CWP+1)*Nbr_block + WR_ADDR;
                     end if; 
                     
                     if (SWP = Nbr_Windows-1 ) then
                       SWP_WR_physical <= WR_ADDR - Nbr_block;
                     else
                       SWP_WR_physical <= (2*SWP+1)*Nbr_block + WR_ADDR;
                     end if; 
                   else
                     --- visit active window ---
                     CWP_WR_physical <= (2*CWP+1)*Nbr_block + WR_ADDR;
                     SWP_WR_physical <= (2*SWP+1)*Nbr_block + WR_ADDR;
                   end if;   
                                              
                   end process;         
  
end asd;