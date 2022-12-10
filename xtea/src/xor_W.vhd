-------------------------------------------------------------------------------
-- Title      : XOR 
-------------------------------------------------------------------------------
-- Entity     : xor_W
-- Created    : 2022-11-25
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the XOR Block
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
package xor_W_cmp_pkg is

   component xor_W
      generic(W : natural := 32);
      port(
         x : in  std_logic_vector(W - 1 downto 0);
         y : in  std_logic_vector(W - 1 downto 0);
         s : out std_logic_vector(W - 1 downto 0)
      );
   end component xor_W;

end package xor_W_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity xor_W is
   generic(
      -- XOR Input Data width
      W : natural := 32
   );
   port(x : in  std_logic_vector(W - 1 downto 0); -- Input A
        y : in  std_logic_vector(W - 1 downto 0); -- Input B
        s : out std_logic_vector(W - 1 downto 0)  -- Bitwise XOR
       );
end entity xor_W;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture dataflow of xor_W is

-- Start
begin
   ----------------------------------------------------------------------------
   -- XOR output
   -------------------------------------------------------------------------------

   -- Perform bitwise XOR
   s <= x xor y;

end dataflow;