library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity post_cordic is
    generic(
        N : natural := 16 -- cantidad de iteraciones que va a hacer el algoritmo CORDIC.
    );
    port(
        x_i_postcordic       : in std_logic_vector(N-1 downto 0);
        y_i_postcordic       : in std_logic_vector(N-1 downto 0);
        x_o_postcordic       : out std_logic_vector(N-1 downto 0);
        y_o_postcordic       : out std_logic_vector(N-1 downto 0)
    );
end post_cordic;

architecture behavioral of post_cordic is
    constant MULTP : signed := to_signed(2487, N);
    signal   x_o_rot, y_o_rot : std_logic_vector(N-1 downto 0);
    signal   mult_i : std_logic_vector(N-1 downto 0);
    signal   mult_o_x, mult_o_y, x_o_postcordic_shifted, y_o_postcordic_shifted : std_logic_vector(2*N-1 downto 0);

begin

    x_o_rot <= x_i_postcordic;
    y_o_rot <= y_i_postcordic;
    
    mult_i <= std_logic_vector(MULTP);
    
    MULT_X: entity work.Nbits_Mult(behavioral)
    generic map(N => N)
    port map(
        x0 => x_o_rot,
        x1 => mult_i,
        y  => mult_o_x
    );
    
    MULT_Y: entity work.Nbits_Mult(behavioral)
    generic map(N => N)
    port map(
        x0 => y_o_rot,
        x1 => mult_i,
        y  => mult_o_y
    );
    
    x_o_postcordic_shifted <= std_logic_vector(shift_right(signed(mult_o_x),12));
    y_o_postcordic_shifted <= std_logic_vector(shift_right(signed(mult_o_y),12));

-- Como multiplico por ~ 0.6, no puedo tener un numero mas grande del que tenia originalmente de N bits, por lo que vuelvo a poner el resultado en N bits.    
    x_o_postcordic <= x_o_postcordic_shifted(N-1 downto 0);
    y_o_postcordic <= y_o_postcordic_shifted(N-1 downto 0);
    
end behavioral;
