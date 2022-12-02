-------------------------------------------------------------------------------
-- Title      : Multiplication by Squaring
-------------------------------------------------------------------------------
-- Entity     : multiply_by_squaring
-- Created    : 2022-11-01
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the Multiplication by Squaring unit,
--    for the case of 3-bit signed integers
--
--                          ((a+x)^2 - (a-x)^2)
--    Eqn  =>  p = a * x =  ------------------
--                                  4
--    For each input, it pass thru a signed extenstion block before 
--    performing addition or subtraction. The result of the addtion and 
--    subtraction is then used as address for the DPROM.
--    The DPROM contains squared result for a given 4 bit input (address)
-- 
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-01      1.0       AT     Initial Version
-- 2022-12-02      1.1       AT     Used entity based instantiation for ROM
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
package multiply_by_squaring_cmp_pkg is

   component multiply_by_squaring
      port(
         a_i       : in  std_logic_vector(2 downto 0);
         x_i       : in  std_logic_vector(2 downto 0);
         product_o : out std_logic_vector(7 downto 0)
      );
   end component multiply_by_squaring;

end package multiply_by_squaring_cmp_pkg;


-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declarations
-------------------------------------------------------------------------------
entity multiply_by_squaring is
   port(
      -- Input A
      a_i       : in  std_logic_vector(2 downto 0);
 
      -- Input B
      x_i       : in  std_logic_vector(2 downto 0);

      -- Output = a_i * b_i
      product_o : out std_logic_vector(7 downto 0)
   );
end entity multiply_by_squaring;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declarations
-------------------------------------------------------------------------------
architecture RTL of multiply_by_squaring is

   ----------------------------------------------------------------------------
   -- Constant Declarations
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- Signed extended signal for a input
   signal sg_ext_a  : std_logic_vector(3 downto 0);

   -- Signed extended signal for x input
   signal sg_ext_x  : std_logic_vector(3 downto 0);

   -- Signal for a+x signal or addra for DPROM
   signal addra     : std_logic_vector(3 downto 0);

   -- Signal for a-x signal or addrb for DPROM
   signal addrb     : std_logic_vector(3 downto 0);

   -- Signals for (a+x)^2 from dprom port a
   signal douta     : std_logic_vector(6 downto 0);

   -- Signals for (a-x)^2 from dprom port b
   signal doutb     : std_logic_vector(6 downto 0);

   -- Signal to store (a+x)^2 - (a-x)^2 (or douta-doutb)
   signal douta_b   : std_logic_vector(7 downto 0);

   -- Signal for divide by 4 (Shift right by 2 bits)
   signal div4      : std_logic_vector(7 downto 0);

-- Start
begin

   ----------------------------------------------------------------------------
   -- Output
   ----------------------------------------------------------------------------
   product_o <= div4;

   ----------------------------------------------------------------------------
   -- Component Instantiations
   ----------------------------------------------------------------------------

   -- DualPort ROM
   inst_square_block : entity work.dp_rom
      port map(
         addra_i => addra,
         douta_o => douta,
         addrb_i => addrb,
         doutb_o => doutb
      );

   ----------------------------------------------------------------------------
   -- Combinatorial Logic
   ----------------------------------------------------------------------------

   -- Perform signal extension for the two inputs
   sg_ext_a  <= a_i(2) & (a_i);
   sg_ext_x  <= x_i(2) & (x_i);

   -- Perform addition to create a+x => addra
   addra     <= std_logic_vector(unsigned(sg_ext_a) + unsigned(sg_ext_x));

   -- Perform subtraction to create a-x => addrb
   addrb     <= std_logic_vector(unsigned(sg_ext_a) - unsigned(sg_ext_x));

   -- Perform squared subtraction
   douta_b   <= std_logic_vector(unsigned('0' & douta) - unsigned('0' & doutb));

   -- Perform divide by 4 using Arithmetic shift
   div4      <= douta_b(7) & douta_b(7) & douta_b(7 downto 2);

end architecture RTL;