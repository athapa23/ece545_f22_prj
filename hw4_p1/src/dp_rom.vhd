-------------------------------------------------------------------------------
-- Title      : DualPort ROM
-------------------------------------------------------------------------------
-- Entity     : dp_rom
-- Created    : 2022-11-01
-- Standard   : VHDL-2008
-------------------------------------------------------------------------------
-- Description:
--    Dual Port ROM that holds the squared result for 4-bit input.
-------------------------------------------------------------------------------
-- Revisions:
-- Date        | Release | Author | Description
-- 2022-11-01      1.0       AT     Initial Version
-- 2022-12-02      1.1       AT     Removed the component package
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Library and Import Declarations
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
-- Entity Declarations
-------------------------------------------------------------------------------
entity dp_rom is
   port(
      -- Side A Address Port
      addra_i : in  std_logic_vector(3 downto 0);

      -- Side A Dataout Port
      douta_o : out std_logic_vector(6 downto 0);

      -- Side B Address Port
      addrb_i : in  std_logic_vector(3 downto 0);

      -- Side B Dataout Port
      doutb_o : out std_logic_vector(6 downto 0)
   );
end entity dp_rom;

-------------------------------------------------------------------------------
-- Synthesizable Architecture Declarations
-------------------------------------------------------------------------------
architecture RTL of dp_rom is
   ----------------------------------------------------------------------------
   -- Type Declarations
   ----------------------------------------------------------------------------

   -- Declare a rom type
   type rom_type is array (0 to 15) of std_logic_vector(6 downto 0);

   ----------------------------------------------------------------------------
   -- Constant Declarations
   ----------------------------------------------------------------------------

   -- ROM Array
   constant rom_array : rom_type := (
      "0000000",
      "0000001",
      "0000100",
      "0001001",
      "0010000",
      "0011001",
      "0100100",
      "0110001",
      "1000000",
      "0110001",
      "0100100",
      "0011001",
      "0010000",
      "0001001",
      "0000100",
      "0000001"
   );

--Start
begin

   ----------------------------------------------------------------------------
   -- Concurrent Outputs
   ----------------------------------------------------------------------------

   -- Assign asynchronous read for port a
   douta_o <= rom_array(to_integer(unsigned(addra_i)));

   -- Assign asynchronous read for port b
   doutb_o <= rom_array(to_integer(unsigned(addrb_i)));

end architecture RTL;