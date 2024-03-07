library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Nbits_Mult is
generic(N : natural := 16);
port(
x0 : in std_logic_vector(N-1 downto 0);
x1 : in std_logic_vector(N-1 downto 0);
y : out std_logic_vector(2*N-1 downto 0)
);
end Nbits_Mult;

architecture behavioral of Nbits_Mult is

begin
y <= std_logic_vector(signed(x0) * signed(x1));
end behavioral;
