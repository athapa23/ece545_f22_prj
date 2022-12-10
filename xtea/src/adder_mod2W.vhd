-------------------------------------------------------------------------------
-- Title      : Adder mod 2^W
-------------------------------------------------------------------------------
-- Entity     : adder_mod2W
-- Created    : 2022-11-25
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the Adder Block
--
--    Code was obtained from :
--    https://people-ece.vse.gmu.edu/coursewebpages/ECE/ECE545/F22/
--    Lecture 9
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
package adder_mod2W_cmp_pkg is

   component adder_mod2W
      generic(W : natural := 32);
      port(
         x : in  std_logic_vector(W - 1 downto 0);
         y : in  std_logic_vector(W - 1 downto 0);
         s : out std_logic_vector(W - 1 downto 0)
      );
   end component adder_mod2W;

end package adder_mod2W_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity adder_mod2W is
   generic(
      -- Input Data width
      W : natural := 32
   );
   port(x : in  std_logic_vector(W - 1 downto 0); -- Input A
        y : in  std_logic_vector(W - 1 downto 0); -- Input B
        s : out std_logic_vector(W - 1 downto 0)  -- Sum = Input A + Input B
       );
end entity adder_mod2W;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture dataflow of adder_mod2W is

-- Start
begin
   ----------------------------------------------------------------------------
   -- Sum output
   ----------------------------------------------------------------------------

   -- Add
   s <= std_logic_vector(unsigned(x) + unsigned(y));

end dataflow;