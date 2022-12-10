-------------------------------------------------------------------------------
-- Title      : Shift/subtract sequential restoring divider for unsigned integers
-------------------------------------------------------------------------------
-- Entity     : divisor
-- Created    : 2022-11-03
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    This is a VHDL description of the divisor block,
--
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
package divisor_cmp_pkg is

   component divisor
      port(
         clk_i  : in  std_logic;
         init_i : in  std_logic;
         run_i  : in  std_logic;
         z_i    : in  std_logic_vector(7 downto 0);
         d_i    : in  std_logic_vector(3 downto 0);
         r_o    : out std_logic_vector(3 downto 0);
         q_o    : out std_logic_vector(3 downto 0)
      );
   end component divisor;

end package divisor_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.shift_pl_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declarations
-------------------------------------------------------------------------------
entity divisor is
   port(
      -- System Clock
      clk_i : in std_logic;

      -- Intialize the register (indicates a new run when init_i = '1')
      init_i : in std_logic;

      -- Run computation (enable shift register in the design when '1'
      run_i  : in std_logic;

      -- 8-bit dividend
      z_i   : in  std_logic_vector(7 downto 0);
 
      -- 4-bit divisor
      d_i   : in  std_logic_vector(3 downto 0);

      -- 4-bit remainder
      r_o   : out std_logic_vector(3 downto 0);
      
      -- 4-bit quotient
      q_o   : out std_logic_vector(3 downto 0)
   );
end entity divisor;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declarations
-------------------------------------------------------------------------------
architecture RTL of divisor is
   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------
   
   -- Stored the output for the shift register for Z[7:4]
   signal shift_msb : std_logic_vector(3 downto 0);

   -- Stored the output for the shift register for Z[3:0]
   signal shift_lsb : std_logic_vector(3 downto 0);

   -- Stores the concatination of the above shift register
   signal shift_reg : std_logic_vector(7 downto 0);

   -- Stores the output of 4-bit adder. Cout will at the MSB-bit
   signal sum       : std_logic_vector(4 downto 0);

   -- Intermediate signal for parallel load. 
   signal din       : std_logic_vector(3 downto 0);

   --- Stored divisor input when init is '1'
   signal div_reg   : std_logic_vector(3 downto 0);

   -- Intermediate signal the calculates OR of shift_reg(7) and Cout
   signal load      : std_logic;

-- Start
begin
   ----------------------------------------------------------------------------
   -- Outputs
   ----------------------------------------------------------------------------
   r_o <= shift_msb;

   ----------------------------------------------------------------------------
   -- Component Instantiations
   ----------------------------------------------------------------------------

   -- Assign din (Parallel load)
   din <= z_i(7 downto 4) when init_i = '1' else sum(3 downto 0);

   -- takes z_i (7 downto 4)
   inst_msb_shreg : shift_pl
      port map(
         clk_i   => clk_i,
         din_i   => din,
         ld_i    => init_i or load,
         en_i    => run_i,
         sin_i   => shift_reg(3),
         shreg_o => shift_msb
      );

   -- takes z_i (3 downto 0)
   inst_lsb_shreg : shift_pl
      port map(
         clk_i   => clk_i,
         din_i   => z_i(3 downto 0),
         ld_i    => init_i,
         en_i    => run_i,
         sin_i   => '0',
         shreg_o => shift_lsb
      );

   -- Capture divisor to a register
   inst_R : shift_pl
      port map(
         clk_i   => clk_i,
         din_i   => d_i,
         ld_i    => init_i,
         en_i    => '0',
         sin_i   => '0',
         shreg_o => div_reg
      );

   -- Outputs quotient
   inst_shift_q : shift_pl
      port map(
         clk_i   => clk_i,
         din_i   => (others => '0'),
         ld_i    => '0',
         en_i    => run_i,
         sin_i   => load,
         shreg_o => q_o
      );

   ----------------------------------------------------------------------------
   -- Combinatorial Logic
   ----------------------------------------------------------------------------
   -- Concatinate the outputs from the shift register
   shift_reg <= shift_msb & shift_lsb;

   -- Adder Block w/ Cin = '1'
   sum       <= std_logic_vector(unsigned('0' & shift_reg(6 downto 3)) +
                                 unsigned(not(div_reg))                +
                                 '1');

   -- Take the cout and or it with MSB of the shift reg
   load      <= shift_reg(7) or sum(4);

end architecture RTL;
