library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity rx_control is
    generic(
        N : natural := 16;
        BAUD_RATE : integer := 115200;
        CLOCK_RATE: integer := 50E6
    );
    Port ( 
        clk :   in  std_logic;
        rst :   in  std_logic;
        rxd_pin :   in std_logic;
        cordic_ack : in std_logic;
        cordic_enable : out std_logic;
        continuous_mode : out std_logic;
        stop_cordic : out std_logic;
        z_o   : out std_logic_vector(N-1 downto 0)
    );
end rx_control;


architecture behavioral of rx_control is

    type fsm_state is (IDLE, R, O, T, A, C, SIGN, NUM_1, NUM_2, NUM_3, COUNTER_CLOCKWISE, CLOCKWISE, SPACE_1, SPACE_2, PROCESS_A_CORDIC, PROCESS_C_CORDIC);

    constant ZERO      : signed(N-9 downto 0) := (others => '0'); --Recordar que N >= 9
    constant C_ANG     : signed(N-1 downto 0) := to_signed(10,N);
    
    signal rx_data_rdy : std_logic;
    signal rx_data_rdy_delay : std_logic := '0';
    signal rx_data_rdy_re : std_logic := '0';
    signal cordic_ack_delay : std_logic := '0';
    signal cordic_ack_re : std_logic := '0';
    signal rx_data     : std_logic_vector(7 downto 0);
    signal state       : fsm_state;
    signal digit_1, digit_2, digit_3       : signed(N-1 downto 0) := (others => '0');
    signal ang         : signed(N-1 downto 0) := (others => '0');
    signal ang_rad     : signed(N-1 downto 0) := (others => '0');
    signal continuous_mode_aux   : std_logic := '0';
    signal cordic_enable_aux     : std_logic := '0';
    signal sign_en     : std_logic := '0';
    signal stop_cordic_aux : std_logic := '0';
    
    function AngConverter (constant i : signed(N-1 downto 0) ) return signed is
    begin
        return resize( i * to_signed( integer(round( MATH_PI/real(180) * real(2**(N-3)) * (real(1)/arctan(real(1))) )),N) ,N);
    end;

    -- Para poder ver los estados de interes:
    signal idle_p, process_a_cordic_p, process_c_cordic_p : std_logic := '0';

begin

-- Para poder ver los estados de interes:
idle_p <= '1' when state = IDLE else '0';
process_a_cordic_p <= '1' when state = PROCESS_A_CORDIC else '0';
process_c_cordic_p <= '1' when state = PROCESS_C_CORDIC else '0';
--


stop_cordic <= stop_cordic_aux;
continuous_mode <= continuous_mode_aux;
cordic_enable <= cordic_enable_aux;


UART: entity work.uart_top(uart_top_arq)
generic map (
    BAUD_RATE => BAUD_RATE,
    CLOCK_RATE => CLOCK_RATE
)
port map(
    clk_pin => clk,
    rst_pin => rst,
    rxd_pin => rxd_pin,
    rx_data_rdy => rx_data_rdy,
    rx_data => rx_data
);


FSM: process(rst, clk)
begin
    if rst = '1' then
        stop_cordic_aux <= '0';
        ang <= (others => '0');
        digit_1 <= (others => '0');
        digit_2 <= (others => '0');
        digit_3 <= (others => '0');
        sign_en <= '0';
        rx_data_rdy_delay <= '0';
        cordic_ack_delay <= '0';
        state <= IDLE;

    elsif clk = '1' and clk'event then
        if ( rx_data_rdy_re = '1' ) or ( cordic_ack_re = '1' ) then
            case state is
            
                when IDLE =>
                    ang <= (others => '0');
                    sign_en <= '0';
                    stop_cordic_aux <= '0';
                    if rx_data = "01010010" then --Si el sigiuente dato por UART es la R
                        state <= R;
                    else
                        state <= IDLE;
                    end if;
                
                when R =>
                    if rx_data = "01001111" then --Si el sigiuente dato por UART es la O
                        state <= O;
                    else
                        state <= IDLE;
                    end if;
                
                when O =>
                    if rx_data = "01010100" then --Si el sigiuente dato por UART es la T
                        state <= T;
                    else
                        state <= IDLE;
                    end if;
                
                when T =>
                    if rx_data = "00100000" then --Si el sigiuente dato por UART es un ESPACIO
                        state <= SPACE_1;
                    else
                        state <= IDLE;
                    end if;
                    
                when SPACE_1 =>
                    if rx_data = "01000011" then --Si el sigiuente dato por UART es la C
                        state <= C;
                    elsif rx_data = "01000001" then --Si el sigiuente dato por UART es la A
                        state <= A;
                    else
                        state <= IDLE;
                    end if;

                when C =>
                    if rx_data = "00100000" then --Si el sigiuente dato por UART es un ESPACIO
                        state <= SPACE_2;
                    else
                        state <= IDLE;
                    end if;
                
                when A =>
                    if rx_data = "00100000" then --Si el sigiuente dato por UART es un ESPACIO
                        state <= SPACE_2;
                    else
                        state <= IDLE;
                    end if;
                    
                when SPACE_2 =>
                    if (rx_data >= "00110000" and rx_data <= "00111001") then --Si el sigiuente dato es mayor o = que 48 y menor o = que 57 entonces es un numero y es el primer digito.
                        digit_1 <= (ZERO & signed(rx_data)) - to_signed(48,N);
                        state <= NUM_1;
                        
                    elsif rx_data = "00101101" then --Si el siguiente dato por UART es un '-'
                        state <= SIGN;
                    
                    elsif rx_data = "01000100" then --Si el siguiente dato por UART es una D
                        state <= COUNTER_CLOCKWISE;
                    
                    elsif rx_data = "01001000" then --Si el siguiente dato por UART es una H
                        state <= CLOCKWISE;
                        
                    else
                        state <= IDLE;
                    end if;
                
                when SIGN =>
                    sign_en <= '1';
                    if rx_data >= "00110000" and rx_data <= "00111001" then --Si el sigiuente dato por UART es un numero.
                        digit_1 <= (ZERO & signed(rx_data)) - to_signed(48,N);
                        state <= NUM_1;
                    
                    else
                        state <= IDLE;
                    end if;
                
                when NUM_1 =>
                    if rx_data >= "00110000" and rx_data <= "00111001" then --Si el sigiuente dato por UART es un numero.
                        digit_2 <= (ZERO & signed(rx_data)) - to_signed(48,N);
                        state <= NUM_2;
                    
                    elsif rx_data = "00001101" then --Si el siguiente dato por UART es un ENTER.
                        if sign_en = '1' then
                            ang <= not(resize((digit_1 * to_signed(1,N)),N)) + 1;
                        else
                            ang <= resize((digit_1 * to_signed(1,N)),N);
                        end if;
                        state <= PROCESS_A_CORDIC;
                                
                    else
                        state <= IDLE;
                    end if;
                    
                when NUM_2 =>
                    if rx_data >= "00110000" and rx_data <= "00111001" then
                        digit_3 <= (ZERO & signed(rx_data)) - to_signed(48,10);
                        state <= NUM_3;
                    
                    elsif rx_data = "00001101" then
                        if sign_en = '1' then
                            ang <= not(resize((digit_1 * to_signed(10,N)),N) + resize((digit_2 * to_signed(1,N)),N)) + 1;
                        else
                            ang <= resize((digit_1 * to_signed(10,N)),N) + resize((digit_2 * to_signed(1,N)),N);
                        end if;
                        state <= PROCESS_A_CORDIC;    
                    
                    else
                        state <= IDLE;
                    end if;
                
                when NUM_3 =>
                    if rx_data = "00001101" then
                        if sign_en = '1' then
                            ang <= not(resize((digit_1 * to_signed(100,N)),N) + resize((digit_2 * to_signed(10,N)),N) + resize((digit_3 * to_signed(1,N)),N)) + 1;
                        else
                            ang <= resize((digit_1 * to_signed(100,N)),N) + resize((digit_2 * to_signed(10,N)),N) + resize((digit_3 * to_signed(1,N)),N);
                        end if;
                        state <= PROCESS_A_CORDIC;
                    else
                        state <= IDLE;
                    end if;
                
                when COUNTER_CLOCKWISE =>
                    ang <= C_ANG;
                    if rx_data = "00001101" then
                        state <= PROCESS_C_CORDIC;
                    else    
                        state <= IDLE;
                    end if;
                    
                when CLOCKWISE =>
                    ang <= not(C_ANG) + 1;
                    if rx_data = "00001101" then
                        state <= PROCESS_C_CORDIC;
                    else    
                        state <= IDLE;
                    end if;

                when PROCESS_A_CORDIC =>
                    if cordic_ack = '0' then
                        state <= PROCESS_A_CORDIC;
                    else
                        state <= IDLE;
                    end if;
                    
                when PROCESS_C_CORDIC => 
                    if rx_data = "01010011" or rx_data = "01110011" then --Si el siguiente dato por UART es 's' o 'S' (Stop)
                        stop_cordic_aux <= '1';
                        state <= IDLE;
                    else
                        state <= PROCESS_C_CORDIC;
                    end if;            
            end case;
        
        end if;
        rx_data_rdy_delay <= rx_data_rdy;
        cordic_ack_delay  <= cordic_ack;       
    end if;
end process;

rx_data_rdy_re <= '1' when (rx_data_rdy = '1' and rx_data_rdy_delay = '0') else '0';
cordic_ack_re <= '1' when (cordic_ack = '1' and cordic_ack_delay = '0') else '0';

cordic_enable_aux <= '1' when (state = PROCESS_A_CORDIC) or (state = PROCESS_C_CORDIC) else
                     '0';
                 
continuous_mode_aux <= '1' when state = PROCESS_C_CORDIC else
                       '0';

ang_rad <= AngConverter(ang) when ang /= 0 else
           (others => '0');
       
z_o <= std_logic_vector(to_unsigned(0,N)) when cordic_enable_aux = '0' else
       std_logic_vector(ang_rad) when cordic_enable_aux = '1' else
       std_logic_vector(ang) when continuous_mode_aux = '1';

end behavioral;