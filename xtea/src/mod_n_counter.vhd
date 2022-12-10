-------------------------------------------------------------------------------
-- Title      : Mod-N Counter
-------------------------------------------------------------------------------
-- Entity     : mod_n_counter
-- Created    : 2022-11-26
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the Mod-N Counter
--
--    Code was obtained from :
--    https://people-ece.vse.gmu.edu/coursewebpages/ECE/ECE545/F22/
--    Lecture 9 and 10
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-26      1.0       AT     Initial Version
-- 2022-12-08      1.1       AT     Counter used to auto clear max count was
--                                  reached. Removed the logic so the user
--                                  has more control over the state of the
--                                  counter
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Library Declaration
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Utility Package Declaration
-------------------------------------------------------------------------------
package counter_utils_pkg is

   ----------------------------------------------------------------------------
   -- Returns the width of the vector needed to store the specified natural
   ----------------------------------------------------------------------------
   function log2c (n: integer) return integer;

end package counter_utils_pkg;

-------------------------------------------------------------------------------
-- Package Body
-------------------------------------------------------------------------------
package body counter_utils_pkg is

   ----------------------------------------------------------------------------
   -- Input  : Integer Number
   -- Output : Width needed to represent the specified vector
   -- For example, if the input is 32 then it takes 6bits to represent 32. 
   -- The output will be 6.
   ----------------------------------------------------------------------------
   function log2c(n : integer) return integer is
      variable m, p : integer;
   begin
      m := 0;
      p := 1;
      while p < n loop
         m := m + 1;
         p := p * 2;
      end loop;
      return m;
   end log2c;

end package body counter_utils_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Imports
use work.counter_utils_pkg.all;

-------------------------------------------------------------------------------
-- Component Package Declaration
-------------------------------------------------------------------------------
package mod_n_counter_cmp_pkg is

   component mod_n_counter
      generic(N : natural := 32);
      port(
         clk_i             : in  std_logic;
         srst_i            : in  std_logic;
         en_i              : in  std_logic;
         ld_i              : in  std_logic;
         count_o           : out std_logic_vector(log2c(N) - 1 downto 0);
         count_max_pulse_o : out std_logic
      );
   end component mod_n_counter;

end package mod_n_counter_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.counter_utils_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity mod_n_counter is
   generic(
      -- Counter width
      N : natural := 32
   );
   port(
      -- System Clock
      clk_i             : in  std_logic;

      -- Active High Synchronous Reset
      srst_i            : in  std_logic;

      -- Active High Enable
      en_i              : in  std_logic;

      -- Active High Load
      ld_i              : in  std_logic;

      -- Counter Value
      count_o           : out std_logic_vector(log2c(N) - 1 downto 0);

      -- '1' when counter rolls over. Roll over is count = N - 1
      count_max_pulse_o : out std_logic
   );
end entity mod_n_counter;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture up_arch of mod_n_counter is

   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- Present state register
   signal r_reg  : unsigned(log2c(N) - 1 downto 0);

   -- Next state wire
   signal r_next : unsigned(log2c(N) - 1 downto 0);

-- Start
begin
   ----------------------------------------------------------------------------
   -- Output Logic
   ----------------------------------------------------------------------------

   -- Wire the register value as an output
   count_o <= std_logic_vector(r_reg);

   -- Flag when counter value reaches threshold defined by the generic
   count_max_pulse_o <= '1' when r_reg = N -1 else '0';

   ----------------------------------------------------------------------------
   -- Counter Logic
   ----------------------------------------------------------------------------
 
   ----------------------------------------------------------------------------
   -- Counter Register Logic
   -- Input    : System Clock, Sync Reset, R_next
   -- Output   : Registered Counter Value
   ----------------------------------------------------------------------------
   count_reg_proc : process(clk_i)
   begin
      if rising_edge(clk_i) then

         if (srst_i = '1') then

            r_reg <= (others => '0');

         else
 
            -- Pass the next state to the current state
            r_reg <= r_next;

         end if;
      end if;
   end process count_reg_proc;

   ----------------------------------------------------------------------------
   -- Next State Logic
   -- Input    : enable, load, current count, max threshold
   -- Output   : Add 1 when the enable is 1 and max threshold hasn't been 
   --            reached. If the enable is 0 then r_next will take r_reg 
   --            value. Thus, counter will not increment.
   ----------------------------------------------------------------------------
   next_state_proc : process(en_i,ld_i,r_reg)
   begin
      -- Default condition
      r_next <= r_reg;

      -- Clear when the ld is asserted
      if (ld_i = '1') then

         r_next <= (others => '0');

      else

         if (en_i = '1') then

            -- Update the counter value by adding 1
            r_next <= r_reg + 1;

         end if;
      end if;
   end process next_state_proc;

end architecture up_arch;