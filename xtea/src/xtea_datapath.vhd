-------------------------------------------------------------------------------
-- Title      : XTEA Datapath
-------------------------------------------------------------------------------
-- Entity     : xtea_datapath
-- Created    : 2022-11-25
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Execution unit of the XTEA block. Below is the algorithm
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
package xtea_datapath_cmp_pkg is

   component xtea_datapath
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
         en_v0    : in  std_logic;
         en_v1    : in  std_logic;
         en_sum   : in  std_logic;
         ld_j     : in  std_logic;
         en_j     : in  std_logic;
         zj       : out std_logic;
         cyclenum : in  std_logic;
         enC      : in  std_logic;
         C        : out std_logic_vector(2 * W - 1 downto 0)
      );
   end component xtea_datapath;

end package xtea_datapath_cmp_pkg;

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Imports
use work.ram_spar_cmp_pkg.all;
use work.reg_n_width_cmp_pkg.all;
use work.adder_mod2W_cmp_pkg.all;
use work.xor_W_cmp_pkg.all;
use work.mod_n_counter_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity xtea_datapath is
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

      -- Active High Enable for V0 Register
      en_v0    : in  std_logic;

      -- Active High Enable for V1 Register
      en_v1    : in  std_logic;

      -- Active High Enable for Sum Register
      en_sum   : in  std_logic;

      -- Active High Load for Counter Register
      ld_j     : in  std_logic;

      -- Active High Enable for Counter Register
      en_j     : in  std_logic;
 
      -- Active High Counter Max Indicator
      zj       : out std_logic;

      -- Cycle 1 or 2 Stage indicator
      cyclenum : in  std_logic;
 
      -- Output Enable
      enC      : in  std_logic;

      -- Ciphertext block = Encrypted block M
      C        : out std_logic_vector(2 * W - 1 downto 0)
   );
end entity xtea_datapath;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declaration
-------------------------------------------------------------------------------
architecture RTL of xtea_datapath is

   ----------------------------------------------------------------------------
   -- Constant Declarations
   ----------------------------------------------------------------------------

   -- Need to store 4 Keys
   constant C_ADDR_WIDTH : natural := 2;

   ----------------------------------------------------------------------------
   -- Signal Declarations
   ----------------------------------------------------------------------------

   -- Contains Most Significant Double Word of the input M
   signal v0             : std_logic_vector(W - 1 downto 0);

   -- Contains Least Significant Double Word of the input M
   signal v1             : std_logic_vector(W - 1 downto 0);

   -- Depending on the cyclenum, the wire will hold output of either V0 or V1
   signal v0_mux_v1      : std_logic_vector(W - 1 downto 0);

   -- Holds the output of the operation : v0_mux_v1 << 4 ^ v0_mux_v1 >> 5
   signal shift_add      : std_logic_vector(W - 1 downto 0);

   -- Depending the cyclenum, the wire will hold output of either V1 or V0
   signal v1_mux_v0      : std_logic_vector(W - 1 downto 0);

   -- SUM Register . Initialized to zeros and add DELTA when enabled
   signal sum_r_reg      : std_logic_vector(W - 1 downto 0);

   -- Contains the value of SUM + DELTA (constant)
   signal sum_r_next     : std_logic_vector(W - 1 downto 0);

   -- Address to the RAM
   signal ram_addr       : std_logic_vector(C_ADDR_WIDTH - 1 downto 0);

   -- Asynchronous output of the RAM is passed to this signal
   signal key_out        : std_logic_vector(W - 1 downto 0);

   -- Contains the addition of v0_mux_v1 and shift_add
   signal w00_w10        : std_logic_vector(W - 1 downto 0);

   -- Contains the addition of sum_r_reg and key_out
   signal w01_w11        : std_logic_vector(W - 1 downto 0);

   -- Contains the XOR of w00_w10 and w01_w11
   signal t0_t1          : std_logic_vector(W - 1 downto 0);

   -- Contains the final value for either V0 or V1
   -- The signal is addition of v1_mux_v0 or t0_t1
   signal v0_v1_next     : std_logic_vector(W - 1 downto 0);

-- Start
begin

   ----------------------------------------------------------------------------
   -- Output
   ----------------------------------------------------------------------------

   -- Output Register
   inst_C_ouput_reg : reg_n_width
      generic map(
         N => 2 * W
      )
      port map(
         clk_i     => clk,
         srst_i    => reset,
         ld_i      => '0',
         en_i      => enC,
         din_i     => v0 & v0_v1_next,
         ld_data_i => (others => '0'),
         dout_o    => C
      );

   ----------------------------------------------------------------------------
   -- Component Instantiations
   ----------------------------------------------------------------------------

   -- V0 Reg that contains msg(MSB downto W);  Most Significant Double Word
   inst_v0_reg : reg_n_width
      generic map(
         N => W
      )
      port map(
         clk_i     => clk,
         srst_i    => '0',
         ld_i      => write_M,
         en_i      => en_v0,
         din_i     => v0_v1_next,
         ld_data_i => M(2 * W -1 downto W),
         dout_o    => v0
      );

   -- V1 Reg that contains msg(W -1 downto 0); Least Significant Double Word
   inst_v1_reg : reg_n_width
      generic map(
         N => W
      )
      port map(
         clk_i     => clk,
         srst_i    => '0',
         ld_i      => write_M,
         en_i      => en_v1,
         din_i     => v0_v1_next,
         ld_data_i => M(W -1 downto 0),
         dout_o    => v1
      );

   -- Add constant, DELTA, to the SUM. SUM is initialized to zero
   inst_sum_reg : reg_n_width
      generic map(
         N => W
      )
      port map(
         clk_i     => clk,
         srst_i    => '0',
         ld_i      => write_M,
         en_i      => en_sum,
         din_i     => sum_r_next,
         ld_data_i => (others => '0'),
         dout_o    => sum_r_reg
      );

   -- Key Storage (4 X W RAM)
   inst_key_ram : ram_spar
      generic map(
         DATA_WIDTH => W,
         ADDR_WIDTH => C_ADDR_WIDTH
      )
      port map(
         clk_i  => clk,
         we_i   => write_Ki,
         addr_i => ram_addr,
         dia_i  => Ki,
         doa_o  => key_out -- Async Read
      );

   -- Calculate sum prime
   inst_sum_pr : adder_mod2W
      generic map(
         W => W
      )
      port map(
         x => sum_r_reg,
         y => std_logic_vector(unsigned(to_unsigned(DELTA, W))),
         s => sum_r_next
      );

   -- Calculate W01_W11
   inst_w01_w11 : adder_mod2W
      generic map(
         W => W
      )
      port map(
         x => key_out,
         y => sum_r_reg,
         s => w01_w11
      );

   -- Calculate shift_XOR
   inst_shift_xor : xor_W
      generic map(
         W => W
      )
      port map(
         x => std_logic_vector(shift_left (unsigned(v0_mux_v1), 4)),
         y => std_logic_vector(shift_right(unsigned(v0_mux_v1), 5)),
         s => shift_add
      );

   -- Calculate W00_10
   inst_w00_w10 : adder_mod2W
      generic map(
         W => W
      )
      port map(
         x => v0_mux_v1,
         y => shift_add,
         s => w00_w10
      );

   -- Calculate t0 XOR t1
   inst_t0_xor_t1 : xor_W
      generic map(
         W => W
      )
      port map(
         x => w00_w10,
         y => w01_w11,
         s => t0_t1
      );

   -- Calculate v0_v1_next
   inst_v0_v1_next : adder_mod2W
      generic map(
         W => W
      )
      port map(
         x => t0_t1,
         y => v1_mux_v0,
         s => v0_v1_next
      );

   -- Number of rounds
   inst_j_count : mod_n_counter
      generic map(
         N => R
      )
      port map(
         clk_i             => clk,
         srst_i            => reset,
         en_i              => en_j,
         ld_i              => ld_j,
         count_o           => open,
         count_max_pulse_o => zj
      );

   ----------------------------------------------------------------------------
   -- Combinatorial Logic
   ----------------------------------------------------------------------------

   -- Let the external circuit load all the round keys to the RAM
   -- then based on the cyclenum output the appropiate KEY for the operation
   ram_addr    <= i                       when write_Ki = '1' else
                  sum_r_reg(12 downto 11) when cyclenum = '1' else
                  sum_r_reg(01 downto 00);

   -- Select either V1 or V0
   v0_mux_v1   <= v0 when cyclenum = '1' else v1;

   -- Select either V0 or V1
   v1_mux_v0   <= v1 when cyclenum = '1' else v0;

end architecture RTL;