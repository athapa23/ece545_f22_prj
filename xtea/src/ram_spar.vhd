-------------------------------------------------------------------------------
-- Title      : Single-port RAM with asynchronous read
-------------------------------------------------------------------------------
-- Entity     : ram_spar
-- Created    : 2022-11-25
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Single-port RAM with asynchronous read
--
--    Code was obtained from :
--    https://people-ece.vse.gmu.edu/coursewebpages/ECE/ECE545/F22/
--    Lecture 10
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
-- Component Package Declarations
-------------------------------------------------------------------------------
package ram_spar_cmp_pkg is

   component ram_spar
      generic(
         DATA_WIDTH : integer := 32;
         ADDR_WIDTH : integer := 6
      );
      port(
         clk_i  : in  std_logic;
         we_i   : in  std_logic;
         addr_i : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);
         dia_i  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);
         doa_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
      );
   end component ram_spar;

end package ram_spar_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declarations
-------------------------------------------------------------------------------
entity ram_spar is
   generic(
      -- number of bits per RAM word
      DATA_WIDTH : integer := 32;
 
      -- 2^ADDR_WIDTH = number of words in RAM
      ADDR_WIDTH : integer := 6);
   port(
      -- System Clock
      clk_i  : in  std_logic;

      --Active High Write Enable for the synchronous write
      we_i   : in  std_logic;

      -- Address for Read (Async) and Write(Sync)
      addr_i : in  std_logic_vector(ADDR_WIDTH - 1 downto 0);

      -- RAM Data in
      dia_i  : in  std_logic_vector(DATA_WIDTH - 1 downto 0);

      -- RAM Data out
      doa_o  : out std_logic_vector(DATA_WIDTH - 1 downto 0)
   );
end entity ram_spar;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declarations
-------------------------------------------------------------------------------
architecture RTL of ram_spar is
   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- RAM Type declaration
   type ram_type is array (0 to 2 ** ADDR_WIDTH - 1)
         of std_logic_vector(DATA_WIDTH - 1 downto 0);

   -- RAM Signal
   signal RAM : ram_type := (others => (others => '0'));

-- Start
begin
   ----------------------------------------------------------------------------
   -- Output
   ----------------------------------------------------------------------------

   -- Asynchronous Read
   doa_o <= RAM(to_integer(unsigned(addr_i)));

   ----------------------------------------------------------------------------
   -- RAM Write Process
   ----------------------------------------------------------------------------
   ram_wr_proc : process(clk_i)
   begin

      if rising_edge(clk_i) then

         -- Write to the RAM when '1'
         if (we_i = '1') then

            RAM(to_integer(unsigned(addr_i))) <= dia_i;

         end if;
      end if;
   end process ram_wr_proc;

end architecture RTL;