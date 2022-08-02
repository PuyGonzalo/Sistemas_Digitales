library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity tb_subadd is
end entity tb_subadd;

architecture tb_arch of tb_subadd is

    constant FILE_PATH  : string := "..\..\Archivos_de_Testeo\fadd_21_7.txt";
    constant TCK        : time := 20 ns; -- Periodo de reloj
    constant F_SIZE     : natural := 21; -- Tamaño de mantisa
    constant EXP_SIZE   : natural := 7;  -- Tamaño del exponente
    constant WORD_SIZE  : natural := EXP_SIZE + F_SIZE + 1; -- Tamaño de datos
   

    signal clk          : std_logic := '0';
    signal add_sub_tb   : std_logic := '0';
    signal x_file       : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal y_file       : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal z_file       : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');
    signal z_dut        : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    signal ciclos   : integer := 0;
    signal errores  : integer := 0;

    file datos : text open read_mode is FILE_PATH;
    
begin

    clk <= not(clk) after TCK/2; -- Reloj

    Test_Sequence: process 
        variable l   : line;
        variable ch  : character := ' ';
        variable aux : integer;
    begin
        while not(endfile(datos)) loop
            wait until rising_edge(clk);
            -- Solo para debugging
            ciclos <= ciclos + 1;
            -- Se lee una linea del archivo de valores de prueba
            readline(datos, l);
            -- Se extrae un entero de la linea
            read(l, aux);
            -- Se carga el valor del operando X
            x_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
            -- Se lee un caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero de la linea
            read(l, aux);
            -- Se carga el valor del operando Y
            y_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
            -- Se lee otro caracter (el espacio)
            read(l, ch);
            -- Se lee otro entero
            read(l, aux);
            -- Se carga el valor de la salida (resultado)
            z_file <= std_logic_vector(to_unsigned(aux, WORD_SIZE));
        end loop;
    
        file_close(datos); -- Se cierra el archivo

        
        -- Se aborta la simulacion (fin del archivo)
        assert false report
            "Fin de la simulacion" severity failure;

    end process Test_Sequence;

    -- Instanciacion del DUT
    DUT: entity work.subadd(behavioral)
    generic map(
        N => WORD_SIZE,
        NE => EXP_SIZE
    )
    port map(
        X       => x_file,
        Y       => y_file,
        --add_sub => add_sub_tb,
        Z       => z_dut
    );


    verificacion: process(clk)
    begin
        if rising_edge(clk) then
            assert to_integer(unsigned(z_file)) = to_integer(unsigned(z_dut)) report
                "Error: Salida del DUT no coincide con referencia (salida del DUT = " &
                integer'image(to_integer(unsigned(z_dut))) &
                ", salida del archivo = " &
                integer'image(to_integer(unsigned(z_file))) & ")"
                severity warning;
            
            if to_integer(unsigned(z_file)) /= to_integer(unsigned(z_dut)) then
                errores <= errores + 1;
            end if;
        end if;
    end process;

end architecture tb_arch;