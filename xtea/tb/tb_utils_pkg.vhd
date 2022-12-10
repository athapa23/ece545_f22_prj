-------------------------------------------------------------------------------
-- Title      : TB Utils package file
-------------------------------------------------------------------------------
-- Entity     : tb_utils_pkg
-- Created    : 2022-11-26
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Utility functions for creating self-checking testbench
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-26      1.0       AT     Initial Version
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

-------------------------------------------------------------------------------
-- Utility Package Declaration
-------------------------------------------------------------------------------
package tb_utils_pkg is

   procedure PRINT       (msg : in string);

   procedure TWRITE      (msg : in string; signal test_running : out string; resolution : in time := 1 us);

   function  TO_STRING   (slv : std_logic_vector) return string;

   procedure CHECK       (inputA : std_logic_vector; inputB : std_logic_vector; msg : string; signal error_count : inout natural);

   procedure CHECK       (inputA : boolean;                                     msg : string; signal error_count : inout natural);

   procedure RESULTS     (signal error_count : in integer);

   procedure PULSE       (signal sig: inout std_logic; signal clk: in std_logic);

   function  LSG         (seed : in std_logic_vector) return std_logic_vector;

end package tb_utils_pkg;

-------------------------------------------------------------------------------
-- Package body
-------------------------------------------------------------------------------
package body tb_utils_pkg is

   ----------------------------------------------------------------------------
   -- Utility procedures
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Print procedure
   ----------------------------------------------------------------------------
   procedure print(msg : in string) is
      variable printline : line;
   begin
      write(printline, msg);
      writeline(output, printline);
   end print;

   ----------------------------------------------------------------------------
   -- Write Test Procedure
   ----------------------------------------------------------------------------
   procedure twrite(msg                 : in  string; 
                    signal test_running : out string;
                    resolution          : in  time := 1 us
   ) is
      variable test_line    : line;
      variable test_integer : natural;
      variable test_string  : string(test_running'range);
   begin
      test_string                := (others => ' ');
      test_string(msg'range)     := msg;
      test_running               <= test_string;
      test_integer               := now / resolution;
      write(test_line, test_integer, right, 10);
      if resolution = 1 us then
         write(test_line, string'(" uS: "));
      elsif resolution = 1 ns then
         write(test_line, string'(" nS: "));
      elsif resolution = 1 ps then
         write(test_line, string'(" pS: "));
      elsif resolution = 1 ms then
         write(test_line, string'(" mS: "));
      else
         write(test_line, string'(" ticks: "));
      end if;
      write(test_line, msg);
      writeline(OUTPUT, test_line);
   end procedure;

   ----------------------------------------------------------------------------
   -- Print std_logic_vector to string
   ----------------------------------------------------------------------------
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

   ----------------------------------------------------------------------------
   -- Check Procedure
   ----------------------------------------------------------------------------
   procedure check(inputA             : std_logic_vector;
                   inputB             : std_logic_vector;
                   msg                : string;
                   signal error_count : inout natural) is
      variable tline : line;
   begin
      if (inputA /= inputB) then
         error_count <= error_count + 1;
         write(tline, msg);
         write(tline, string'(" at time "));
         write(tline, now);
         writeline(output, tline);
         write(tline, string'("Expected " & to_string(inputB) &
                                  " got " & to_string(inputA)));
         writeline(output, tline);
      end if;
   end procedure;

   ----------------------------------------------------------------------------
   -- Check Procedure (boolean)
   ----------------------------------------------------------------------------
   procedure check(inputA             : boolean;
                   msg                : string;
                   signal error_count : inout natural) is
      variable tline : line;
   begin
      if (not inputA) then
         error_count <= error_count + 1;
         write(tline, msg);
         write(tline, string'(" at time "));
         write(tline, now);
         writeline(output, tline);
      end if;
   end procedure;

   ----------------------------------------------------------------------------
   -- Print Results 
   ----------------------------------------------------------------------------
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

   ----------------------------------------------------------------------------
   -- Pulse Generator
   ----------------------------------------------------------------------------
   procedure pulse(signal sig : inout std_logic;
                   signal clk : in    std_logic) is
   begin
      wait until rising_edge(clk);
      sig <= not sig;
      wait until rising_edge(clk);
      sig <= not sig;
   end procedure;

   ----------------------------------------------------------------------------
   -- Random Number Generator
   ----------------------------------------------------------------------------
   function LSG(seed : in std_logic_vector) return std_logic_vector is
      variable length   : natural                               := seed'LENGTH;
      variable seed_v   : std_logic_vector(length - 1 downto 0) := seed;
      variable feedback : std_logic_vector(length - 1 downto 0);

   begin
      length := seed'LENGTH;
      seed_v := seed;

      case length is
         when 4       => feedback := (seed_v(0)   xor seed_v(1))                                    & seed_v(  3 downto 1);
         when 8       => feedback := (seed_v(0)   xor seed_v(2)   xor seed_v(3)   xor seed_v(4))    & seed_v(  7 downto 1);
         when 32      => feedback := (seed_v(0)   xor seed_v(10)  xor seed_v(30)  xor seed_v(31))   & seed_v( 31 downto 1);
         when others  => feedback := (others => '1');
      end case;
      return feedback;
   end function LSG;
end package body tb_utils_pkg;