-------------------------------------------------------------------------------
-- Title      : Multiplication by Squaring Testbench
-------------------------------------------------------------------------------
-- Entity     : multiply_by_squaring_tb
-- Created    : 2022-11-01
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Testbench for the Multiplication by Squaring block
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-01      1.0       AT     Initial Version
-- 2022-12-02      1.1       AT     Simplified multiply function. Cleanup
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
use work.multiply_by_squaring_cmp_pkg.all;

-------------------------------------------------------------------------------
-- Entity Declaration
-------------------------------------------------------------------------------
entity multiply_by_squaring_tb is
end entity multiply_by_squaring_tb;

-------------------------------------------------------------------------------
-- Architecture Declaration
-------------------------------------------------------------------------------
architecture behavior of multiply_by_squaring_tb is
   ----------------------------------------------------------------------------
   -- Constant Declaration
   ----------------------------------------------------------------------------
   constant CLK_PERIOD  : time := 10000 ps;

   ----------------------------------------------------------------------------
   -- Signal Declaration
   ----------------------------------------------------------------------------
   signal clk_100MHz    : std_logic := '1';

   -- DUV Specific signals
   signal a_i_s         : std_logic_vector(2 downto 0) := (others => '0');
   signal x_i_s         : std_logic_vector(2 downto 0) := (others => '0');
   signal product_o_s   : std_logic_vector(7 downto 0);

   -- Stimuli/Response Checker Specific signals
   signal error_count   : natural                       := 0;

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

   -- function multiplier block
   function multiply(a : in std_logic_vector(2 downto 0);
                     b : in std_logic_vector(2 downto 0))
   return  std_logic_vector is

   begin

      return std_logic_vector(signed(a(2) & (a)) * signed(b(2) & (b)));

   end function;

--Start
begin
   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------
   duv : multiply_by_squaring
      port map(
         a_i       => a_i_s,
         x_i       => x_i_s,
         product_o => product_o_s
      );

   ----------------------------------------------------------------------------
   -- Clock

   clk_100MHz <= not clk_100MHz after CLK_PERIOD / 2;

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
      variable expected_result : std_logic_vector(7 downto 0);

      -- Test all cases
      procedure test_all_possible_case is
      begin

         a_i_s <= (others => '0');
         x_i_s <= (others => '0');

         for i in 0 to 7 loop

            a_i_s <= std_logic_vector(unsigned(a_i_s) + 1);

            for j in 0 to 7 loop

               x_i_s <= std_logic_vector(unsigned(x_i_s) + 1);

               wait until rising_edge(clk_100MHz);

               expected_result := multiply(a_i_s, x_i_s);
               check(product_o_s, expected_result, "Multiplication Result ", error_count);

               wait until rising_edge(clk_100MHz);

            end loop;
         end loop;

      end procedure test_all_possible_case;

      -- Start
   begin

      for k in 0 to 1 loop              -- Loop to ensure nothing breaks

         test_all_possible_case;

      end loop;

      wait for 100 ns;
      results(error_count);
   end process stimuli_proc;
end behavior;