-------------------------------------------------------------------------------
-- Title      : XTEA
-------------------------------------------------------------------------------
-- Entity     : xtea
-- Created    : 2022-12-08
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Performs the follwing operation:
-- 
--    Split M into two equal parts V0, V1 each of the size of w bits
--
--    SUM = 0
--
--    for j= 1 to r do
--       {
--          W00 = ((V1 << 4) XOR (V1 >> 5)) + V1
--          W01 = SUM + KEY[SUM mod 4]
--          T0 = W00 XOR W01
--          V0' = V0 + T0
--
--          SUM' = SUM + DELTA
--
--          W10 = ((V0' << 4) XOR (V0' >> 5)) + V0'
--          W11 = SUM' + KEY[(SUM'>>11) mod 4]
--          T1 = W10 XOR W11
--          V1' = V1 + T1
--
--          SUM = SUM'
--          V0 = V0'
--          V1 = V1'
--       }
--
--    C = V0 || V1
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
package xtea_cmp_pkg is

   component xtea
      generic(
         W     : natural := 32;
         R     : natural := 16;
         DELTA : natural := 16
      );
      port(
         clk      : in  std_logic;
         reset    : in  std_logic;
         M        : in  std_logic_vector(2 * W - 1 downto 0);
         write_M  : in  std_logic;
         Ki       : in  std_logic_vector(W - 1 downto 0);
         write_Ki : in  std_logic;
         i        : in  std_logic_vector(1 downto 0);
         done     : out std_logic;
         C        : out std_logic_vector(2 * W - 1 downto 0)
      );
   end component xtea;

end package xtea_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Imports
use work.xtea_datapath_cmp_pkg.all;
use work.xtea_controller_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity xtea is
   generic(
      -- Message Data width
      W     : natural := 32;
      -- Number of Rounds
      R     : natural := 16;
      -- constant DELTA
      DELTA : natural := 16
   );
   port(
      -- System Clock
      clk      : in  std_logic;

      -- Active High Synchronous Reset
      reset    : in  std_logic;

      -- Message block
      M        : in  std_logic_vector(2 * W - 1 downto 0);

      -- Synchronous write control signal for the message block M
      -- After the block M is written to the XTEA unit, the encryption
      -- of M starts automatically
      write_M  : in  std_logic;

      -- Round key K[index] loaded to the internal storage.
      Ki       : in  std_logic_vector(W - 1 downto 0);

      -- Synchronous write control signal for the round key
      write_Ki : in  std_logic;

      -- Index of the round key K[index] loaded using input round_key_i
      i        : in  std_logic_vector(1 downto 0);

      -- Asserted when ciphertext is ready and available at the output
      done     : out std_logic;

      -- Ciphertext block = Encrypted block M
      C        : out std_logic_vector(2 * W - 1 downto 0)
   );
end entity xtea;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture RTL of xtea is

   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- Enable for V0 Register coming from FSM
   signal fsm_en_v0 : std_logic;

   -- Enable for V1 Register coming from FSM
   signal fsm_en_v1 : std_logic;

   -- Enable for SUM Register coming from FSM
   signal fsm_en_sum : std_logic;

   -- Load (clear) for the counter from FSM
   signal fsm_ld_j : std_logic;

   -- Enable (add 1) for the counter from FSM
   signal fsm_en_j : std_logic;

   -- Status flag to FSM indicating max round is reached
   signal zj : std_logic;

   -- Contains Cycle 1 or Cycle 2 part of the algorithm
   signal fsm_cyclenum : std_logic;

   -- Enable to update the output regiser from FSM
   signal fsm_enC : std_logic;

-- Start
begin

   ----------------------------------------------------------------------------
   -- Component Instantiations
   ----------------------------------------------------------------------------

   -- Instantiate Datapath (Execution Unit)
   inst_xtea_datapath : xtea_datapath
      generic map(
         W     => W,
         R     => R,
         DELTA => DELTA
      )
      port map(
         clk      => clk,
         reset    => reset,
         M        => M,
         write_M  => write_M,
         Ki       => Ki,
         write_Ki => write_Ki,
         i        => i,
         en_v0    => fsm_en_v0,
         en_v1    => fsm_en_v1,
         en_sum   => fsm_en_sum,
         ld_j     => fsm_ld_j,
         en_j     => fsm_en_j,
         zj       => zj,
         cyclenum => fsm_cyclenum,
         enC      => fsm_enC,
         C        => C
      );

   -- Instantiate fsm (Controller Unit)
   inst_xtea_controller : xtea_controller
      port map(
         clk      => clk,
         reset    => reset,
         write_M  => write_M,
         en_v0    => fsm_en_v0,
         en_v1    => fsm_en_v1,
         en_sum   => fsm_en_sum,
         ld_j     => fsm_ld_j,
         en_j     => fsm_en_j,
         zj       => zj,
         cyclenum => fsm_cyclenum,
         enC      => fsm_enC,
         done     => done
      );

end architecture RTL;