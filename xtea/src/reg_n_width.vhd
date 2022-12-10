-------------------------------------------------------------------------------
-- Title      : N-Wide Register
-------------------------------------------------------------------------------
-- Entity     : reg_n_width
-- Created    : 2022-11-25
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a N-wide register block.
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-25      1.0       AT     Initial Version
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
package reg_n_width_cmp_pkg is

   component reg_n_width
      generic(N : natural := 32);
      port(
         clk_i     : in  std_logic;
         srst_i    : in  std_logic;
         ld_i      : in  std_logic;
         en_i      : in  std_logic;
         din_i     : in  std_logic_vector(N - 1 downto 0);
         ld_data_i : in  std_logic_vector(N - 1 downto 0);
         dout_o    : out std_logic_vector(N - 1 downto 0)
      );
   end component reg_n_width;

end package reg_n_width_cmp_pkg;


-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity reg_n_width is
    generic(
      -- Register Data width
      N : natural := 32
   );
   port(
      -- System Clock
      clk_i     : in  std_logic;

      -- Active High Synchronous Reset
      srst_i    : in  std_logic;

      -- Load din_i when '1'
      ld_i      : in  std_logic;

      -- Enable register update when '1'
      en_i      : in  std_logic;

      -- Load din when enable = '1' and ld = '0'
      din_i     : in  std_logic_vector(N - 1 downto 0);

      -- N-bit parallel load when enable = '1' and ld = '1'
      ld_data_i : in  std_logic_vector(N - 1 downto 0);

      -- Registered Output
      dout_o    : out std_logic_vector(N - 1 downto 0)
   );
end entity reg_n_width;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture RTL of reg_n_width is

-- Start
begin
   ----------------------------------------------------------------------------
   -- Register Logic
   -- Input    : System Clock, load, ld_data, enable and datain
   -- Output   : Registered output
   ----------------------------------------------------------------------------
   nbit_reg_proc : process(clk_i)
   begin
      if rising_edge(clk_i) then

         -- Enable Register
         if (en_i = '1') then

            -- Load the ld_data_i when ld_i = '1'
            if (ld_i = '1') then

               dout_o <= ld_data_i;

            else

               dout_o <= din_i;

            end if;
         end if;

         ----------------------------------------------------------------------
         -- Synchronous Reset
         ----------------------------------------------------------------------
         if (srst_i = '1') then

            dout_o <= (others => '0');

         end if;

      end if;
   end process nbit_reg_proc;

end architecture RTL;