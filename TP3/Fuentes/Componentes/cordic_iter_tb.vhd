library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity cordic_iter_testbench is 
end entity cordic_iter_testbench;

architecture cordic_iter_testbench_arq of cordic_iter_testbench is

    constant N : natural := 16;
    constant ANG_RAD : real := (real(269)*MATH_PI)/real(180); -- Angulo que quiero rotar pasado a radianes
    constant ANGm180 : real := ANG_RAD + MATH_PI;
    constant ANG_Z : integer := integer( round( (ANGm180/arctan(real(1))) * real(2**(N-3)) ) ); -- Angulo que quiero rotar en fondo de escala [ Rads ]
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal req : std_logic := '0';
    signal ack : std_logic := '0';
    signal rot0_vec1 : std_logic := '0';
    signal x_in,y_in,z_in : std_logic_vector(N-1 downto 0);
    signal x_aux, y_aux,z_aux : std_logic_vector(N-1 downto 0);
    signal x_aux2, y_aux2,z_aux2 : std_logic_vector(N-1 downto 0);
    signal x_out,y_out,z_out : std_logic_vector(N-1 downto 0);
  
begin
           
    rst <= '0';
    clk <= not clk after 10 us; 
    req <= '1' after 10 us,
           '0' after 50 us,
           '1' after 400 us,
           '0' after 440 us;
           
    z_aux2 <= std_logic_vector(to_signed(ANG_Z,N));

    x_aux <= "0001000000000000",
            "0001000000000000" after 400 us;
    y_aux <= "0000000000000000",
            "0001000000000000" after 400 us;
    z_aux <= "0010000000000000",
            z_aux2 after 400 us;
            
    x_in <= std_logic_vector(signed(not(x_aux)) + 1);
    y_in <= std_logic_vector(signed(not(y_aux)) + 1);
    z_in <= z_aux;
    

    DUV: entity work.cordic_iter(behavioral)
    generic map(
        N => N 
    )
    port map(
        clk => clk,
        rst => rst,
        req => req,
        ack => ack,
        rot0_vec1 => rot0_vec1,
        x_0 => x_in,
        y_0 => y_in,
        z_0 => z_in,
        x_nm1 => x_out,
        y_nm1 => y_out,
        z_nm1 => z_out   
    );

end architecture cordic_iter_testbench_arq;