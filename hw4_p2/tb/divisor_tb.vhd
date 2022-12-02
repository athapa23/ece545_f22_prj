-------------------------------------------------------------------------------
-- Title      : Shift/subtract sequential restoring divider for unsigned integers
-------------------------------------------------------------------------------
-- Entity     : divisor_tb
-- Created    : 2022-11-03
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Testbench for the Divisor block
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
use ieee.std_logic_textio.all;
use ieee.math_real.all;

-- std;
use std.textio.all;
use std.env.all;

-- work
use work.divisor_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity divisor_tb is
end entity divisor_tb;

-------------------------------------------------------------------------------
-- Architecture Declaration
-------------------------------------------------------------------------------
architecture behavior of divisor_tb is
   ----------------------------------------------------------------------------
   -- Constant Declaration
   ----------------------------------------------------------------------------
   constant CLK_PRD   : time := 10000 ps;

   ----------------------------------------------------------------------------
   -- Signal Declaration
   ----------------------------------------------------------------------------
   signal clk_100MHz  : std_logic := '1';

   -- DUV Specific signals
   signal init_i_s    : std_logic := '0';
   signal run_i_s     : std_logic := '0';
   signal z_i_s       : std_logic_vector(7 downto 0) := (others => '0');
   signal d_i_s       : std_logic_vector(3 downto 0) := (others => '0');
   signal r_o_s       : std_logic_vector(3 downto 0);
   signal q_o_s       : std_logic_vector(3 downto 0);

   -- Stimuli/Response Checker Specific signals
   signal test_running : string(1 to 20) := (others => ' ');
   signal error_count  : natural := 0;

   ----------------------------------------------------------------------------
   -- Utility procedure
   ----------------------------------------------------------------------------

   -- Print procedure
   procedure print(saywhat : in string) is
      variable printline : line;
   begin
      write(printline, saywhat);
      writeline(output, printline);
   end print;

   -- Print std_logic_vector to string
   function to_string(slv : std_logic_vector) return string is
      alias slvin : std_logic_vector(1 to slv'length) is slv;
      variable s  : string(1 to slv'length);
   begin
      for i in slvin'range loop
         case slvin(i) is
            when '1'    => s(i) := '1';
            when '0'    => s(i) := '0';
            when 'X'    => s(i) := 'X';
            when 'U'    => s(i) := 'U';
            when 'Z'    => s(i) := 'Z';
            when '-'    => s(i) := '-';
            when 'H'    => s(i) := 'H';
            when 'L'    => s(i) := 'L';
            when 'W'    => s(i) := 'W';
            when others => s(i) := 'X';
         end case;
      end loop;
      return s;
   end function;

   -- check procedure
   procedure check(inputA             : std_logic_vector;
                   inputB             : std_logic_vector;
                   saywhat            : string;
                   signal error_count : inout natural) is
      variable tline : line;
   begin
      if (inputA /= inputB) then
         error_count <= error_count + 1;
         write(tline, saywhat);
         write(tline, string'(" at time "));
         write(tline, now);
         writeline(output, tline);
         write(tline, string'("Expected " & to_string(inputB) &
                                  " got " & to_string(inputA)));
         writeline(output, tline);
      end if;
   end procedure;

   -- Print Results 
   procedure results(signal error_count : in integer) is
      variable tline : line;
   begin
      print(" ");
      print("*******");
      print("RESULTS");
      print("*******");
      print(" ");
      if (error_count /= 0) then
         write(tline, string'("Number of errors in the simualtion : "));
         write(tline, error_count);
      else
         write(tline, string'("Simulation completed without errors"));
      end if;
      writeline(output, tline);
      print(" ");
      print("*****************");
      print("Simulation Ending");
      print("*****************");
      print(" ");
      stop(0);
   end procedure;

   -- function divisor block
   procedure div_tb(z : in std_logic_vector(7 downto 0);
                    d : in std_logic_vector(3 downto 0);
                    q : out std_logic_vector(3 downto 0);
                    r : out std_logic_vector(3 downto 0)
                    )
                    is
      variable q_v : std_logic_vector(7 downto 0);
      variable r_v : std_logic_vector(3 downto 0);

   begin
      q_v := std_logic_vector(unsigned(z) / unsigned(d));
      r_v := std_logic_vector(unsigned(z) mod unsigned(d));
      q   := q_v(3 downto 0);
      r   := r_v;
   end procedure;

   -- Random Number Generator
   function LSG(seed : in std_logic_vector) return std_logic_vector is
      variable length   : natural                               := seed'LENGTH;
      variable seed_v   : std_logic_vector(length - 1 downto 0) := seed;
      variable feedback : std_logic_vector(length - 1 downto 0);

   begin

      case length is
         when 4       => feedback := (seed_v(0) xor seed_v(1))                             & seed_v(3 downto 1);
         when 8       => feedback := (seed_v(0) xor seed_v(2) xor seed_v(3) xor seed_v(4)) & seed_v(7 downto 1);
         when others  => feedback  := (others => '1');
      end case;
      return feedback;
   end function LSG;

--Start
begin
   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------
   duv : divisor
      port map(
         clk_i  => clk_100MHz,
         init_i => init_i_s,
         run_i  => run_i_s,
         z_i    => z_i_s,
         d_i    => d_i_s,
         r_o    => r_o_s,
         q_o    => q_o_s
      );

   ----------------------------------------------------------------------------
   -- Clock

   clk_100MHz <= not clk_100MHz after CLK_PRD / 2;

   ----------------------------------------------------------------------------
   -- Halt the program if the error count exceeds the threshold
   halt_proc : process(error_count)
   begin
      if (error_count > 10) then
         print("Too many errors. Halting");
         stop(0);
      end if;
   end process halt_proc;

   ----------------------------------------------------------------------------
   -- Stimuli Generator and Response Checker
   ----------------------------------------------------------------------------
   stimuli_proc : process
      variable expected_quo : std_logic_vector(3 downto 0);
      variable expected_rem : std_logic_vector(3 downto 0);
      variable LSG8         : std_logic_vector(7 downto 0) := (others => '1');
      variable LSG4         : std_logic_vector(3 downto 0) := (others => '1');

      -- Performs operation and checks the output
      procedure divide(z     : in std_logic_vector(7 downto 0);
                       d     : in std_logic_vector(3 downto 0);
                       exp_q : in std_logic_vector(3 downto 0);
                       exp_r : in std_logic_vector(3 downto 0)
                      ) is
      begin
         z_i_s <= z;
         d_i_s <= d;
         wait until rising_edge(clk_100MHz);
         wait until falling_edge(clk_100MHz);
         init_i_s <= '1';
         wait until falling_edge(clk_100MHz);
         init_i_s <= '0';
         wait until falling_edge(clk_100MHz);
         wait until falling_edge(clk_100MHz);
         wait until falling_edge(clk_100MHz);
         wait until falling_edge(clk_100MHz);
         check(q_o_s, exp_q, "Quotient  : ", error_count);
         check(r_o_s, exp_r, "Remainder : ", error_count);
         wait until rising_edge(clk_100MHz);
      end procedure;

      -- Test all cases
      procedure test_lsg_case is
      begin

         ----------------------------------------------------------------------
         test_running <= "Test LSG Cases      "; wait for 1 ps;
         ----------------------------------------------------------------------
         print(test_running & " at : " & time'image(now));

         divisor_loop : for i in 0 to 99 loop

            LSG4 := LSG(LSG4);

            divident_loop : for j in 0 to 99 loop

               if (LSG8(7 downto 4) < LSG4) then

                  div_tb(LSG8, LSG4, expected_quo, expected_rem); -- To TB Model
                  divide(LSG8, LSG4, expected_quo, expected_rem); -- To DUV

               end if;

               LSG8 := LSG(LSG8);

            end loop divident_loop;
         end loop divisor_loop;

      end procedure test_lsg_case;

      -- Test using hand written test cases
      procedure test_select_case is
      begin

         ----------------------------------------------------------------------
         test_running <= "Test Select Cases   "; wait for 1 ps;
         ----------------------------------------------------------------------
         print(test_running & " at : " & time'image(now));

                          -- Z         D       Q       R
         test1  : divide("00001001", "0011", "0011", "0000"); -- 9/3    ; q = 3  ; r = 0
         test2  : divide("00000000", "0001", "0000", "0000"); -- 0/1    ; q = 0  ; r = 0
         test3  : divide("00010000", "0101", "0011", "0001"); -- 16/5   ; q = 3  ; r = 1
         test4  : divide("11101111", "1111", "1111", "1110"); -- 239/15 ; q = 15 ; r = 14
         test5  : divide("11100000", "1111", "1110", "1110"); -- 224/15 ; q = 14 ; r = 14
         test6  : divide("01111111", "1000", "1111", "0111"); -- 127/8  ; q = 15 ; r = 7
         test7  : divide("01010101", "1010", "1000", "0101"); -- 85/10  ; q = 8  ; r = 5
         test8  : divide("01100011", "1001", "1011", "0000"); -- 99/9   ; q = 11 ; r = 0
         test9  : divide("00000100", "0100", "0001", "0000"); -- 4/4    ; q = 1  ; r = 0
         test10 : divide("00000001", "1111", "0000", "0001"); -- 1/15   ; q = 0  ; r = 1

      end procedure test_select_case;

   -- Start
   begin

      run_i_s <= '1';

      for k in 0 to 1 loop              -- Loop to ensure nothing breaks

         test_lsg_case;
         test_select_case;

      end loop;

      run_i_s <= '0';


      wait for 100 ns;
      results(error_count);
   end process stimuli_proc;
end behavior;