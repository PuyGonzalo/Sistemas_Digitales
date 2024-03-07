library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tp_testbench_1 is
end tp_testbench_1;

architecture behavioral of tp_testbench_1 is

constant N      : natural := 16;
signal clk_tb   : std_logic := '0';
signal rst_tb   : std_logic := '1';
signal rxd_tb   : std_logic := '1';
signal ack_tb   : std_logic := '0';
signal xo_tb, yo_tb : Std_logic_vector(N-1 downto 0) := (others => '0');

constant FRECUENCIA : integer := 125E6; --En MHz
constant PERIODO    : time    := 1 sec/FRECUENCIA; -- En us.
constant BAUD_RATE  : integer := 115200;
signal   detener    : boolean := false;
constant nb_ack     : integer := 2;


begin


clk_tb <= not clk_tb after 4 ns;
rst_tb <= '1', '0' after 9 ns;

TEST:
process is begin
    report "Se inicia la prueba"
    severity note;
    
    wait until rst_tb = '0';
    wait until ack_tb = '1';
    wait for 3 ns;
  
        
    rxd_tb <= '1';  -- IDLE
    wait for 8681 ns; -- Tiempo de un bit: 1/BAUD_RATE. En este caso BAUD_RATE = 115200 => 8680,555 => 8681 redondeando
    
    rxd_tb <= '0'; -- START
    wait for 8681 ns;
        
    -- Envio letra R
    rxd_tb <= '0';  --bit(0) de la R = "01010010", se envia de derecha a izquierda. Empezando por el LSB
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(1) de la R
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(2) de la R
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de la R
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(4) de la R
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(5) de la R
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(6) de la R
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de la R
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio letra O

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '1';  --bit(0) de la O = "01001111"
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(1) de la O
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de la O
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(3) de la O
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de la O
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(5) de la O
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(6) de la O
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de la O
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio letra T

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '0';  --bit(0) de la T = "01010100"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de la T
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de la T
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de la T
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(4) de la T
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(5) de la T
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(6) de la T
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de la T
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio ESACIO

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '0';  --bit(0) de ESPACIO = "00100000"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(2) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(5) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de ESPACIO
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio letra A

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '1';  --bit(0) de la A = "01000001"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de la A
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(2) de la A
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de la A
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de la A
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(5) de la A
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(6) de la A
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de la A
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio ESACIO

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '0';  --bit(0) de ESPACIO = "00100000"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(2) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(5) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de ESPACIO
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de ESPACIO
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;
    
    -- Envio numeros
    -- SIGNO MENOS
    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '1';  --bit(0) de - = "00101101"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de -
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de -
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(3) de -
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de -
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(5) de -
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de -
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de -
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;

    --4
    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '0';  --bit(0) de 4 = "00110100"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de 4
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de 4
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de 4
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(4) de 4
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(5) de 4
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de 4
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de 4
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;

    --5
    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '1';  --bit(0) de 5 = "00110101"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de 5
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de 5
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(3) de 5
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(4) de 5
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(5) de 5
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de 5
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de 5
    wait for 8681 ns;

    rxd_tb <= '1';   -- STOP
    wait for 8681 ns;

    rxd_tb <= '1';   -- IDLE
    wait for 8681 ns;

    -- Envio ENTER (Carriage Return)

    rxd_tb <= '0';   -- START
    wait for 8681 ns;

    rxd_tb <= '1';  --bit(0) de ENTER = "00001101"
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(1) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(2) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '1';  --bit(3) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(4) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(5) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(6) de ENTER
    wait for 8681 ns;
    
    rxd_tb <= '0';  --bit(7) de ENTER
    wait for 8681 ns;
    
   rxd_tb <= '1'; -- STOP
   wait for 8681 ns;
   
   rxd_tb <= '1'; -- IDLE
   wait for 2 ms;
   --wait for 8681 ns;
   
   report "Se envio comando de rotacion"
   severity note;

   --wait until ack_tb = '1';
   
   report "Termina Prueba"
   severity note;
   
   detener <= true;
   
   -- Se aborta la simulacion
    assert false report
        "Fin de la simulacion" severity failure;
   
end process TEST;

DUT: entity work.top(behavioral)
generic map (N => 16, BAUD_RATE => BAUD_RATE, CLOCK_RATE => FRECUENCIA)
port map (
    clk => clk_tb,
    rst => rst_tb,
    rxd_pin => rxd_tb,
    ack => ack_tb,
    x_o => xo_tb,
    y_o => yo_tb
);

end behavioral;
