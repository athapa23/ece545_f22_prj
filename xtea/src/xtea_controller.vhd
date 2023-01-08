-------------------------------------------------------------------------------
-- Title      : XTEA Controller
-------------------------------------------------------------------------------
-- Entity     : xtea_controller
-- Created    : 2022-12-08
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Outputs control signal to execute the algorithm.
--    It takes two cycle to complete the xtea algorithm
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-12-08      1.0       AT     Initial Version
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Library Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Component Package Declaration
-------------------------------------------------------------------------------
package xtea_controller_cmp_pkg is

   component xtea_controller
      port(
         clk      : in  std_logic;
         reset    : in  std_logic;
         write_M  : in  std_logic;
         en_v0    : out std_logic;
         en_v1    : out std_logic;
         en_sum   : out std_logic;
         ld_j     : out std_logic;
         en_j     : out std_logic;
         zj       : in  std_logic;
         cyclenum : out std_logic;
         enC      : out std_logic;
         done     : out std_logic
      );
   end component xtea_controller;

end package xtea_controller_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity xtea_controller is

   port(
      -- System Clock
      clk      : in  std_logic;

      -- Active High Synchronous Reset
      reset    : in  std_logic;

      -- Synchronous write control signal for the message block M
      -- After the block M is written to the XTEA unit, the encryption
      -- of M starts automatically
      write_M  : in  std_logic;

      -- Active High Enable for V0 Register
      en_v0    : out std_logic;

      -- Active High Enable for V1 Register
      en_v1    : out std_logic;

      -- Active High Enable for Sum Register
      en_sum   : out std_logic;

      -- Active High Load for Counter Register
      ld_j     : out std_logic;

      -- Active High Enable for Counter Register
      en_j     : out std_logic;

      -- Active High Counter Max Indicator
      zj       : in  std_logic;

      -- Cycle 1 or 2 Stage indicator
      cyclenum : out std_logic;

      -- Output Enable
      enC      : out std_logic;

      -- Asserted when ciphertext is ready and available at the output
      done     : out std_logic

   );
end entity xtea_controller;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture RTL of xtea_controller is

   ----------------------------------------------------------------------------
   -- Type Declaration
   ----------------------------------------------------------------------------

   -- State Type
   type fsm_type is (
      S_WAITING,
      S_FIRST_HALF,
      S_SECOND_HALF,
      S_DONE);

   ----------------------------------------------------------------------------
   -- Signal Declaration
   ----------------------------------------------------------------------------

   -- Next State Signal
   signal next_state    : fsm_type;

   -- Next Present State Signal
   signal present_state : fsm_type;

-- Start
begin

   ----------------------------------------------------------------------------
   -- Reset Process for FSM
   ----------------------------------------------------------------------------
   reset_fsm_proc : process(clk)
   begin
      if rising_edge(clk) then

         if (reset = '1') then
            present_state <= S_WAITING;
         else
            present_state <= next_state;
         end if;

      end if;
   end process reset_fsm_proc;

   ----------------------------------------------------------------------------
   -- Controller State Machine
   ----------------------------------------------------------------------------
   -- The following FSM starts encryption when the message block M is loaded
   -- After the encryption of each block is completed, signal Done becomes
   -- active for one clock cycle
   ----------------------------------------------------------------------------
   controller_fsm_proc : process(present_state,
                                 write_M,
                                 zj)
   begin

      -- Default all outputs to be inactive
      en_v0      <= '0';
      en_v1      <= '0';
      en_sum     <= '0';
      ld_j       <= '0';
      en_j       <= '0';
      enC        <= '0';
      cyclenum   <= '0';
      done       <= '0';
      next_state <= present_state;

      case present_state is

         ----------------------------------------------------------------------
         -- S_WAITING : Wait until a new message is loaded
         ----------------------------------------------------------------------
         when S_WAITING =>

            -- When a new message is valid, enable V0,V1, Sum Reg, load counter
            if (write_M = '1') then

               en_v0      <= '1';
               en_v1      <= '1';
               en_sum     <= '1';
               ld_j       <= '1';
               next_state <= S_FIRST_HALF;

            end if;

         ----------------------------------------------------------------------
         -- S_FIRST_HALF : 1st Cycle; Update V0 and Sum Register
         ----------------------------------------------------------------------
         when S_FIRST_HALF =>

            en_v0      <= '1';
            en_sum     <= '1';
            next_state <= S_SECOND_HALF;

         ----------------------------------------------------------------------
         -- S_SECOND_HALF : Enable V1 Reg; Loop if max iteration has not been
         --                 reached.
         ----------------------------------------------------------------------
         when S_SECOND_HALF =>

            en_v1    <= '1';
            cyclenum <= '1';

            -- Capture output when it is end of the round (i.e., max iter)
            if (zj = '1') then

               enC        <= '1';
               next_state <= S_DONE;

            -- Else, Increment the counter and loop one more time
            else

               en_j       <= '1';
               next_state <= S_FIRST_HALF;

            end if;

         ----------------------------------------------------------------------
         -- S_DONE : Assert done to indicate ciphertext is ready and available
         --          at the output
         ----------------------------------------------------------------------
         when S_DONE =>

            done       <= '1';
            next_state <= S_WAITING;

         ----------------------------------------------------------------------
         -- Safety State : Unreachable
         ----------------------------------------------------------------------

         -- coverage off
         when others => -- @suppress "Case statement contains all choices explicitly. You can safely remove the redundant 'others'"

            next_state <= S_WAITING;

         -- coverage on

      end case;
   end process controller_fsm_proc;
end RTL;
