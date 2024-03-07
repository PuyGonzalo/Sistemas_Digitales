library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity top is
    generic(
        N : natural := 16;
        BAUD_RATE : integer := 115200;
        CLOCK_RATE: integer := 125E6
    );
    Port ( 
        clk      : in  std_logic;
        rst      : in  std_logic;
        rxd_pin  : in std_logic;
        ack      : out std_logic;
        x_o, y_o : out std_logic_vector(N-1 downto 0)
    );
end top;

architecture behavioral of top is

    constant N_COUNT : natural := 22;

    signal cordic_enable   : std_logic := '0';
    signal continuous_mode : std_logic := '0';
    signal ang             : std_logic_vector(N-1 downto 0) := (others => '0');
    signal ack_aux         : std_logic := '0';
    signal stop_cordic     : std_logic := '0';
    
begin

    ack <= ack_aux;

    RX_CONTROL: entity work.rx_control(behavioral)
    generic map(N => N,
                BAUD_RATE => BAUD_RATE,
                CLOCK_RATE => CLOCK_RATE
    )
    port map(
        clk => clk,
        rst => rst,
        rxd_pin => rxd_pin,
        cordic_ack => ack_aux,
        cordic_enable => cordic_enable,
        continuous_mode => continuous_mode,
        stop_cordic => stop_cordic,
        z_o => ang
    );

    CORDIC_CONTROL: entity work.cordic_control(behavioral)
    generic map(N => N, N_COUNT => N_COUNT)
    port map(
        clk => clk,
        rst => rst,
        ena => cordic_enable,
        mode => continuous_mode,
        stop_cordic => stop_cordic,
        ack => ack_aux,
        ang => ang,
        x_o => x_o,
        y_o => y_o
    );
    
end behavioral;