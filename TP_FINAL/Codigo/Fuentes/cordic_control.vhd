library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_control is
    generic(
        N : natural := 16;
        N_COUNT : natural := 22
    );
    Port ( 
        clk  : in std_logic;
        rst  : in std_logic;
        ena  : in std_logic;
        mode : in std_logic;
        stop_cordic : in std_logic;
        ang  : in std_logic_vector(N-1 downto 0);
        ack  : out std_logic;
        x_o, y_o   : out std_logic_vector(N-1 downto 0)
    );
end cordic_control;

architecture behavioral of cordic_control is

    constant NC : natural := 2499;
    --constant NC : natural := 2499999;

    type fsm_state is (INITIAL, CONVERSION, C_CONVERSION, IDLE, CORDIC_A, CORDIC_C);

    signal count        : integer := 0;
    signal state        : fsm_state;
    signal cordic_clk   : std_logic := '0';
    signal req          : std_logic := '0';
    signal ack_aux      : std_logic := '0';
    signal x_i, y_i, z_i : std_logic_vector(N-1 downto 0) := (others => '0');
    signal x_initial, y_initial : std_logic_vector(N-1 downto 0) := (others => '0');
    signal x_o_aux, y_o_aux, z_o_aux : std_logic_vector(N-1 downto 0) := (others => '0');

    -- Para probar:
    signal initial_p, idle_p, cordic_a_p, cordic_c_p, conversion_p, c_conversion_p   : std_logic := '0';

begin

-- ++++++++++++++++++++++++++++++++++++++++++++++++
    -- Para poder ver los estados de la FSM:
    initial_p <= '1' when state = INITIAL else
                 '0';

    idle_p <= '1' when state = IDLE else
              '0';

    cordic_a_p <= '1' when state = CORDIC_A else
                  '0';

    cordic_c_p <= '1' when state = CORDIC_C else
                  '0';

    conversion_p <= '1' when state = CONVERSION else
                    '0';

    c_conversion_p <= '1' when state = C_CONVERSION else
                      '0';
-- ++++++++++++++++++++++++++++++++++++++++++++++++

    x_initial <= std_logic_vector(to_signed(0,N));
    y_initial <= std_logic_vector(to_signed(4096,N));

    ack <= ack_aux;
    x_o <= x_o_aux;
    y_o <= y_o_aux;

    CORDIC: entity work.cordic(behavioral_iter)
    generic map(N => N)
    port map(
        clk => cordic_clk,
        rst => rst,
        req => req,
        rot0_vec1 => '0', --Siempre en modo rotacion
        x_i => x_i,
        y_i => y_i,
        z_i => z_i,
        ack => ack_aux,
        x_o => x_o_aux,
        y_o => y_o_aux,
        z_o => z_o_aux
    );

FSM:
    process (cordic_clk,rst)
    begin
        if rst = '1' then
            state <= INITIAL;
        elsif cordic_clk = '1' and cordic_clk'event then
            case state is

                when INITIAL =>
                    x_i <= x_initial;--Coordenada X inicial.
                    y_i <= y_initial;-- Coordenada Y inicial. 
                    z_i <= (others => '0');
                    req <= '1';
                    state <= CONVERSION;

                when CONVERSION =>
                    req <= '0';
                    if ack_aux = '1' then
                        state <= IDLE;
                    else
                        state <= CONVERSION;
                    end if;

                when C_CONVERSION =>
                    req <= '0';
                    if ack_aux = '1' then
                        state <= CORDIC_C;
                    elsif stop_cordic = '1' then
                        state <= IDLE;
                    else
                        state <= C_CONVERSION;
                    end if;

                when IDLE =>
                    x_i <= x_o_aux;
                    y_i <= y_o_aux;
                    z_i <= (others => '0');
                    req <= '1';
                    if ena = '1' and mode = '0' then
                        state <= CORDIC_A;
                    elsif ena = '1' and mode = '1' then
                        state <= CORDIC_C;
                    else
                        state <= IDLE;
                    end if;

                when CORDIC_A =>
                    x_i <= x_o_aux;
                    y_i <= y_o_aux;
                    z_i <= ang;
                    state <= CONVERSION;

                when CORDIC_C =>
                    x_i <= x_o_aux;
                    y_i <= y_o_aux;
                    z_i <= ang;
                    req <= '1';
                    state <= C_CONVERSION;


            end case;
        end if;
    end process;

    clk_cordic_gen: process(clk, rst)
    begin
        if rst = '1' then
            count <= 0;
        elsif (clk = '1' and clk'event) then
            count <= count + 1;
            if count = NC then
                cordic_clk <= not cordic_clk;
                count <= 0;
            end if;
        end if;
    end process;
    

end behavioral;