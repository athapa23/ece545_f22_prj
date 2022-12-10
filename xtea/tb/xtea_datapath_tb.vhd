-------------------------------------------------------------------------------
-- Title      : XTEA Datapath Testbench
-------------------------------------------------------------------------------
-- Entity     : xtea_datapath_tb
-- Created    : 2022-11-27
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Testbench for the XTEA Datapath block
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-27      1.0       AT     Initial Version
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Library Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;

-- std;
use std.textio.all;
use std.env.all;

-- work
use work.tb_utils_pkg.all;
use work.xtea_datapath_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity xtea_datapath_tb is
end entity xtea_datapath_tb;

-------------------------------------------------------------------------------
-- Architecture Declaration
-------------------------------------------------------------------------------
architecture behavior of xtea_datapath_tb is

   ----------------------------------------------------------------------------
   -- Type Declaration
   ----------------------------------------------------------------------------

   -- RAM Type declaration
   type ram_type is array (0 to 3) of std_logic_vector(16 - 1 downto 0);

   ----------------------------------------------------------------------------
   -- Constant Declaration
   ----------------------------------------------------------------------------
   constant CLK_PRD    : time := 10000 ps;

   constant W          : natural  := 16;
   constant R          : natural  := 3;

   constant DELTA      : unsigned := X"800A";

   constant KEY        : ram_type := (X"ABCD", X"CCCC", X"6666", X"FEDC");

   ----------------------------------------------------------------------------
   -- Signal Declaration
   ----------------------------------------------------------------------------
   signal clk_100MHz   : std_logic := '1';
   signal async_reset  : std_logic := '0';

   -- DUV Specific signals
   signal M            : std_logic_vector(2 * W - 1 downto 0) := (others => '0');
   signal write_M      : std_logic                            := '0';
   signal Ki           : std_logic_vector(W - 1 downto 0)     := (others => '0');
   signal write_Ki     : std_logic                            := '0';
   signal i            : std_logic_vector(1 downto 0)         := (others => '0');
   signal en_v0        : std_logic                            := '0';
   signal en_v1        : std_logic                            := '0';
   signal en_sum       : std_logic                            := '0';
   signal ld_j         : std_logic                            := '0';
   signal en_j         : std_logic                            := '0';
   signal zj           : std_logic;
   signal cyclenum     : std_logic                            := '0';
   signal enC          : std_logic                            := '0';
   signal C            : std_logic_vector(2 * W - 1 downto 0);

   -- Stimuli/Response Checker Specific signals
   signal test_running : string(1 to 60) := (others => ' '); -- @suppress "signal test_running is never read"
   signal error_count  : natural := 0;

   ----------------------------------------------------------------------------
   -- function XTEA block
   ----------------------------------------------------------------------------
   procedure func_xtea(msg        : in  std_logic_vector(2 * W - 1 downto 0);
                       expected_C : out std_logic_vector(2 * W - 1 downto 0)
                    ) is
      variable w00   : std_logic_vector(W - 1 downto 0);
      variable w01   : std_logic_vector(W - 1 downto 0);
      variable t0    : std_logic_vector(W - 1 downto 0);
      variable w10   : std_logic_vector(W - 1 downto 0);
      variable w11   : std_logic_vector(W - 1 downto 0);
      variable t1    : std_logic_vector(W - 1 downto 0);
      variable sum_v : unsigned(W - 1 downto 0);
      variable v0_v  : unsigned(W - 1 downto 0);
      variable v1_v  : unsigned(W - 1 downto 0);

   begin
      v0_v  := unsigned(msg(2 * W - 1 downto W));
      v1_v  := unsigned(msg(W - 1 downto 0));
      sum_v := (others => '0');

      for j in 1 to R loop

         w00   := std_logic_vector(shift_left(v1_v, 4)) xor std_logic_vector(shift_right(v1_v, 5));
         w00   := std_logic_vector(unsigned(w00) + v1_v);

         w01   := std_logic_vector(sum_v + unsigned(KEY(to_integer(sum_v(1 downto 0)))));

         t0    := w00 xor w01;
         v0_v  := v0_v + unsigned(t0);

         sum_v := sum_v + DELTA;

         w10   := std_logic_vector(shift_left(v0_v, 4)) xor std_logic_vector(shift_right(v0_v, 5));
         w10   := std_logic_vector(unsigned(w10) + v0_v);

         w11   := std_logic_vector(sum_v + unsigned(KEY(to_integer(sum_v(12 downto 11)))));

         t1    := w10 xor w11;
         v1_v  := v1_v + unsigned(t1);

      end loop;

      expected_C := std_logic_vector(v0_v) & std_logic_vector(v1_v);
   end procedure;

--Start
begin

   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------
   duv : xtea_datapath
      generic map(
         W     => W,
         R     => R,
         DELTA => to_integer(DELTA)
      )
      port map(
         clk      => clk_100MHz,
         reset    => async_reset,
         M        => M,
         write_M  => write_M,
         Ki       => Ki,
         write_Ki => write_Ki,
         i        => i,
         en_v0    => en_v0,
         en_v1    => en_v1,
         en_sum   => en_sum,
         ld_j     => ld_j,
         en_j     => en_j,
         zj       => zj,
         cyclenum => cyclenum,
         enC      => enC,
         C        => C
      );

   ----------------------------------------------------------------------------
   -- Clock
   ----------------------------------------------------------------------------

   clk_100MHz <= not clk_100MHz after CLK_PRD / 2;

   ----------------------------------------------------------------------------
   -- Halt the program if the error count exceeds the threshold
   ----------------------------------------------------------------------------
   halt_proc : process(error_count)
   begin
      if (error_count > 10) then
         PRINT("Too many errors. Halting");
         stop(0);
      end if;
   end process halt_proc;

   ----------------------------------------------------------------------------
   -- Stimuli Generator and Response Checker
   ----------------------------------------------------------------------------
   stimuli_proc : process
      variable LSG32 : std_logic_vector(31 downto 0) := X"ABCDEF99";

      -- Reset the datapath block
      procedure reset_procedure is
      begin

         async_reset <= '0';
         wait for 100 ns;

         async_reset <= '1';
         wait for 100 ns;

         async_reset <= '0';
         wait for 100 ns;

         -- Check output is '0' after initialization
         CHECK(C, X"0000_0000", "Counter Output not 0 after reset", error_count);

      end procedure reset_procedure;

      -- Round Keys
      procedure init_round_keys is
      begin

         Ki <= KEY(0);
         i  <= B"00";
         PULSE(write_Ki, clk_100MHz);

         Ki <= KEY(1);
         i  <= B"01";
         PULSE(write_Ki, clk_100MHz);

         Ki <= KEY(2);
         i  <= B"10";
         PULSE(write_Ki, clk_100MHz);

         Ki <= KEY(3);
         i  <= B"11";
         PULSE(write_Ki, clk_100MHz);

      end procedure init_round_keys;

      -- Load's the message to be encrypted
      procedure load_message(msg          : in std_logic_vector(2 * W - 1 downto 0)) is
      begin
         wait until rising_edge(clk_100MHz);
         M       <= msg;
         en_v0   <= '1';
         en_v1   <= '1';
         en_sum  <= '1';
         write_M <= '1';
         wait until rising_edge(clk_100MHz);
         en_v0   <= '0';
         en_v1   <= '0';
         en_sum  <= '0';
         write_M <= '0';                -- Suspend for the rest of the execution
         M       <= (others => '0');    -- Ensure the data is only stored when write_M ='1'
         wait until rising_edge(clk_100MHz);
      end procedure load_message;

      -- Controller for the datapath. Normally it would be a FSM
      procedure xtea_algorithm(msg        : in std_logic_vector(2 * W - 1 downto 0);
                               expected_C : in std_logic_vector(2 * W - 1 downto 0)) is
         variable count : integer := 0;
      begin

         load_message(msg);

         count := 0;

         main_loop : while (zj /= '1') loop
            count := count + 1;

            cyclenum <= '0';

            wait until rising_edge(clk_100MHz); -- All Register will be updated
            en_v0  <= '1';
            en_sum <= '1';

            wait until rising_edge(clk_100MHz);
            en_v0    <= '0';
            en_sum   <= '0';
            cyclenum <= '1';

            if (count = R) then
               PULSE(enC, clk_100MHz);
               wait for 1 ps;
               CHECK(C, expected_C, "Output does not match", error_count);
            else
               en_v1 <= '1';
               wait until rising_edge(clk_100MHz);
               en_v1 <= '0';
               PULSE(en_j, clk_100MHz);
            end if;

         end loop main_loop;

         CHECK(zj = '1', "Loop exited without reaching max iteration", error_count);

         ld_j  <= '1';
         en_j  <= '1';
         wait until rising_edge(clk_100MHz);
         en_v0 <= '0';
         ld_j  <= '0';

         -- Clear all control signals
         write_M  <= '0';
         en_v0    <= '0';
         en_v1    <= '0';
         en_sum   <= '0';
         ld_j     <= '0';
         en_j     <= '0';
         cyclenum <= '0';
         enC      <= '0';
         wait for 1000 ns;
      end procedure xtea_algorithm;

      -- Test all cases
      procedure test_lsg_case is
         variable expected_C : std_logic_vector(2 * W - 1 downto 0);

      begin

         ----------------------------------------------------------------------
         TWRITE("Test LSG Cases", test_running);
         ----------------------------------------------------------------------

         for m in 0 to 99 loop

            func_xtea      (LSG32, expected_C); -- To TB Model
            xtea_algorithm (LSG32, expected_C); -- To DUV
            LSG32 := LSG(LSG32);

         end loop;

      end procedure test_lsg_case;

      procedure test_select_case is

      begin

         ----------------------------------------------------------------------
         TWRITE("Test C-generated Cases", test_running);
         ----------------------------------------------------------------------

         test0 : xtea_algorithm(X"FFFF_0000", X"6A80_1569");
         test1 : xtea_algorithm(X"0000_FFFF", X"86D0_7EEF");
         test2 : xtea_algorithm(X"AAAA_0000", X"9B00_5509");
         test3 : xtea_algorithm(X"5555_0000", X"4253_892A");
         test4 : xtea_algorithm(X"FFFF_AAAA", X"15DB_816C");
         test5 : xtea_algorithm(X"FFFF_5555", X"8E55_A31E");
         test6 : xtea_algorithm(X"0101_1010", X"13AC_48B8");
         test7 : xtea_algorithm(X"ABCD_EF01", X"FC33_DEE3");
         test8 : xtea_algorithm(X"ABCD_DA1A", X"D5F2_DB28");
         test9 : xtea_algorithm(X"DA1A_0001", X"8799_D0DA");

      end procedure test_select_case;

   -- Start
   begin
      -- Hit Reset
      reset_procedure;

      -- Initialize Round Keys
      init_round_keys;

      mid_reset_loop : for j in 0 to 1 loop  -- Perform mid operation reset

         run_2_loop : for k in 0 to 1 loop   -- Loop to ensure nothing breaks

            test_lsg_case;
            test_select_case;

            if k = 0 then

               PRINT(" ");
               PRINT("Looping Over");
               PRINT(" ");

            end if;

         end loop run_2_loop;

         if j = 0 then

            TWRITE("Mid-Operation Reset", test_running);
            reset_procedure;

         end if;

      end loop mid_reset_loop;

      wait for 100 ns;
      RESULTS(error_count);
   end process stimuli_proc;
end behavior;
