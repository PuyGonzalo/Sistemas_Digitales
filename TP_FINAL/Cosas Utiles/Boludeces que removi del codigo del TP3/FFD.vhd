library ieee;
use ieee.std_logic_1164.all;

entity ffd is
    port(
        d   : in std_logic;
        rst : in std_logic;
        clk : in std_logic;
        q   : out std_logic
    );
    
end ffd;

architecture behavioral of ffd is

begin

    process(clk,rst)
    begin
        if rst = '1' then
            q <= '0';
        
        elsif clk = '1' and clk'event then
            q <= d;
            
        end if;
    end process;
    
end behavioral;