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
        --rst      : in  std_logic;
        rxd_pin  : in std_logic
        --ack      : out std_logic;
        --x_o, y_o : out std_logic_vector(N-1 downto 0)
    );
end top;

architecture behavioral of top is

    constant N_COUNT : natural := 22;

    signal cordic_enable   : std_logic := '0';
    signal continuous_mode : std_logic := '0';
    signal ang             : std_logic_vector(N-1 downto 0) := (others => '0');
    signal ack_aux         : std_logic := '0';
    signal stop_cordic     : std_logic := '0';
    
    -- Señales para bloque VIO
    signal rst_i : std_logic_vector(0 downto 0);
    signal ack_o : std_logic_vector(0 downto 0);
    signal x_o_vio, y_o_vio : std_logic_vector(15 downto 0);
    signal rst : std_logic;
    
    COMPONENT vio_0
      PORT (
        clk : IN STD_LOGIC;
        probe_in0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe_in1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe_in2 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe_out0 : OUT STD_LOGIC_VECTOR(0 DOWNTO 0) 
      );
    END COMPONENT;
    
begin

    --ack <= ack_aux;
    -- Hago esto para operar de la misma forma que antes sin cambiar el codigo (Ahora rst y ack son std_logic_vector !!).
    ack_o <= "1" when ack_aux = '1' else "0";
    rst <= '1' when rst_i = "1" else '0';
    
top_vio : vio_0
  PORT MAP (
    clk => clk,
    probe_in0 => x_o_vio,
    probe_in1 => y_o_vio,
    probe_in2 => ack_o,
    probe_out0 => rst_i
  );

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
        x_o => x_o_vio,
        y_o => y_o_vio
    );
    
end behavioral;