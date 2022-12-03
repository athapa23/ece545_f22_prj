-------------------------------------------------------------------------------
-- Title      : Left Shift Register
-------------------------------------------------------------------------------
-- Entity     : shift_pl
-- Created    : 2022-11-03
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the shift register block.
--    The block performs a left-shift for a 4-bit signal.
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-03      1.0       AT     Initial Version
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Library Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Component Package Declarations
-------------------------------------------------------------------------------
package shift_pl_cmp_pkg is

   component shift_pl
      port(
         clk_i   : in  std_logic;
         din_i   : in  std_logic_vector(3 downto 0);
         ld_i    : in  std_logic;
         en_i    : in  std_logic;
         sin_i   : in  std_logic;
         shreg_o : out std_logic_vector(3 downto 0)
      );
   end component shift_pl;

end package shift_pl_cmp_pkg;


-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declarations
-------------------------------------------------------------------------------
entity shift_pl is
   port(
      -- System Clock
      clk_i   : in  std_logic;

      -- 4-bit parallel load
      din_i   : in  std_logic_vector(3 downto 0);

      -- Load din_i when '1'
      ld_i    : in  std_logic;

      -- Enable shift when '1'
      en_i    : in  std_logic;

      -- Shift in bit. When enable is '1', sin_i will be loaded to LSB
      sin_i   : in  std_logic;

      -- Output of the shift register
      shreg_o : out std_logic_vector(3 downto 0)
   );
end entity shift_pl;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declarations
-------------------------------------------------------------------------------
architecture RTL of shift_pl is

   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- Intermediate signal for the shift register
   signal q_temp : std_logic_vector(3 downto 0);

-- Start
begin
   ----------------------------------------------------------------------------
   -- Outputs
   ----------------------------------------------------------------------------
   shreg_o <= q_temp;

   ----------------------------------------------------------------------------
   -- Shift Register Logic
   -- Input    : System Clock, datain, load, enable and shift in
   -- Output   : 4-bit register w/ shift in loaded to LSB when enable = '1'
   ----------------------------------------------------------------------------
   shreg_proc : process(clk_i)
   begin

      if rising_edge(clk_i) then

         -- Load the din_i when ld_i = '1'
         if (ld_i = '1') then

            q_temp <= din_i;

         else

            -- Enable Shift Register
            if (en_i = '1') then

               q_temp <= q_temp(2 downto 0) & sin_i;

            end if;

         end if;
      end if;
   end process;

end architecture RTL;