-- TP 1
-- Materia: Sistemas digitales
-- Alumno: Gonzalo Puy
-- Padron: 99784

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity semaforos is
    port(
        rst         : in std_logic;
        clk         : in std_logic;
        rojo_1      : out std_logic;
        amarillo_1  : out std_logic;
        verde_1     : out std_logic;
        rojo_2      : out std_logic;
        amarillo_2  : out std_logic;
        verde_2     : out std_logic
    );
end semaforos;

architecture behavioral of semaforos is

    -- Definicion de constantes
    constant N_counter : natural := 31;
    
    -- Definicion del tipo de dato "t_state"
    type t_state is (R1_V2, R1_A2, A1_R2, V1_R2, A1_R2_p, R1_A2_p);
    
    -- Definicion de señales a usar

    constant val     : std_logic_vector(N_counter-1 downto 0) := (others => '0');
    signal state     : t_state;
    signal mux_out   : std_logic;
    signal sel_mux   : std_logic;
    signal seg_30    : std_logic;
    signal seg_3     : std_logic;
    
begin
    
    -- Componentes
    mux: entity work.mux
    port map(
        x0 => seg_30,
        x1 => seg_3,
        s  => sel_mux,
        y  => mux_out
    );
    
    contador: entity work.counterN
    generic map(N => N_counter)
    port map(
        rst => rst,
        clk => clk,
        load => mux_out,
        val  => val,
        count => open,
        seg_30_count => seg_30,
        seg_3_count => seg_3
    );
    
    fsm: process(clk, rst) -- Maquina de estados
    begin
        if rst = '1' then
            state <= R1_V2;
            
        elsif clk = '1' and clk'event then
            case state is
            
                when R1_V2 =>
                    if seg_30 = '1' then
                        state <= R1_A2;
                    end if;
                
                when R1_A2 =>
                    if seg_3 = '1' then
                        state <= A1_R2;
                    end if;
                
                when A1_R2 =>
                    if seg_3 = '1' then
                        state <= V1_R2;
                    end if;
                
                when V1_R2 =>
                    if seg_30 = '1' then
                        state <= A1_R2_p;
                    end if;
                
                when A1_R2_p =>
                    if seg_3 = '1' then
                        state <= R1_A2_p;
                    end if;
                    
                when R1_A2_p =>
                    if seg_3 = '1' then
                        state <= R1_V2;
                    end if;
            end case;
        end if;
    end process;
    
    -- Selector del mux:
    sel_mux <=
                '1' when ((state = R1_A2) or (state = R1_A2_p) or (state = A1_R2) or (state = A1_R2_p)) else
                '0';
                
    -- Salidas:    
    rojo_1 <=
            '1' when ((state = R1_V2) or (state = R1_A2) or (state = R1_A2_p)) else
            '0';
            
    amarillo_1 <=
                '1' when ((state = A1_R2) or (state = A1_R2_p)) else
                '0';
                
    verde_1 <=
             '1' when state = V1_R2 else
             '0';
             
    rojo_2 <=
            '1' when ((state = A1_R2) or (state = V1_R2) or (state = A1_R2_p)) else
            '0';
            
    amarillo_2 <=
                '1' when ((state = R1_A2) or (state = R1_A2_p)) else
                '0';
                
    verde_2 <=
             '1' when state = R1_V2 else
             '0';

end behavioral;          