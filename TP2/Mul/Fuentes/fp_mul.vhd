library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_mul is
    generic(N : natural := 20;
            NE : natural := 6
    );
    port (
        X   : in std_logic_vector(N-1 downto 0); -- Operando 1
        Y   : in std_logic_vector(N-1 downto 0); -- Operando 2
        Z   : out std_logic_vector(N-1 downto 0) -- Resultado       
    );
end fp_mul;

architecture behavioral of fp_mul is
    
    constant EXC        : natural := 2**(NE-1)-1;
    constant NF         : natural := N-NE-1;
    constant EXCESO     : unsigned(NE+1 downto 0) := to_unsigned(EXC, NE+2);
    constant E_MIN      : unsigned(NE-1 downto 0) := to_unsigned(0, NE);
    constant E_MAX      : unsigned(NE-1 downto 0) := to_unsigned(2**(NE)-2, NE);
    constant E_CEROS    : unsigned(NE+1 downto 0) := to_unsigned(0, NE+2); -- usada para chequear campo E todos '0'
    constant F_CEROS    : unsigned(NF-1 downto 0) := to_unsigned(0, NF); -- usada para chequear campo F todos '0'
    constant RES_CERO   : unsigned(N-2 downto 0)  := to_unsigned(0,N-1);  

    signal sx       : std_logic; -- Signo operando X
    signal sy       : std_logic; -- Signo operando Y

    signal ex       : unsigned(NE+1 downto 0) := (others => '0'); -- Exponente operando X, representado en exceso -> rango(ex) = [0; 2**(NE)-1]
    signal ey       : unsigned(NE+1 downto 0) := (others => '0'); -- Exponente operando Y, representado en exceso -> rango(ey) = [0; 2**(NE)-1]
    signal cero_op  : std_logic := '0';                           -- "Flag" usada para saber si uno de los operandos es 0

    signal fx       : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa operando X
    signal fy       : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa operando Y

    signal mx       : unsigned(NF downto 0) := (others => '0'); -- Significand operandos X
    signal my       : unsigned(NF downto 0) := (others => '0'); -- significand operando Y

    signal sz           : std_logic;                                    -- Signo del resultado
    signal ez           : unsigned(NE-1 downto 0) := (others => '0');   -- Exponente del resultado, representado en exceso.
    signal ez_aux       : unsigned(NE+1 downto 0) := (others => '0');   -- Exponente auxiliar para cuentas
    signal ez_aux_p     : unsigned(NE+1 downto 0) := (others => '0');   -- Exponente auxiliar 'prima' para cuentas 
    signal mz           : unsigned(2*NF+1 downto 0) := (others => '0'); -- Significand del resultado.
    signal fz           : unsigned(NF-1 downto 0) := (others => '0');   -- Mantisa del resultado.
    signal fz_aux       : unsigned(NF-1 downto 0) := (others => '0');   -- Mantisa auxiliar para cuentas.

    -- DE ESTA LINEA HASTA LA 51 NO VA EN LA ENTREGA, HACER UN NUEVO ARCHIVO QUE SEA PARA ENTREGAR. ESTE QUEDA PARA EL GONZA DEL FUTURO
    -- Constantes que uso para comparar en logica de saturacion
    -- No la uso mas, por lo dicho en la linea 107
    --constant EMAX_LIM    : unsigned(NE-1 downto 0) := to_unsigned(2**(NE)-1, NE);
    


begin
    
    -- Separacion de los campos de los operandos
    sx <= X(NE+NF);
    sy <= Y(NE+NF);
    ex <= '0' & '0' & unsigned(X(NF+NE-1 downto NF)); -- Le agrego 2 '0' al principio para poder chequear overflow y underflow
    ey <= '0' & '0' & unsigned(Y(NF+NE-1 downto NF)); -- Por eso ex, ey, ez y EXCESO tienen NE+2 bits.
    fx <= unsigned(X(NF-1 downto 0));
    fy <= unsigned(Y(NF-1 downto 0));

    -- Chequeo si alguno de los operandos es cero (Resultado trivial)
    cero_op <= '1' when ( (ex = E_CEROS) and (fx = F_CEROS) ) else
               '1' when ( (ey = E_CEROS) and (fy = F_CEROS) ) else
               '0';

    -- Calculo del signo del resultado
    sz <= sx xor sy;

    -- Multiplicacion de los Significand
    mx <= '1' & fx; -- Le agrego un '1' al principio a F para calcular el Significand
    my <= '1' & fy; -- por eso mx, my tienen NF+1 bits.
    
    mz <= mx * my; -- mz tiene 2*NF+2 bits.

    -- Calculo del exponente representado en exceso
    ez_aux <= ex + ey - EXCESO;
    
    -- Redondeo de la mantisa
    fz_aux <=
          mz(2*NF downto NF+1) when mz(2*NF+1) = '1' else
          mz(2*NF-1 downto NF);

    ez_aux_p <= 
             (ez_aux + 1) when mz(2*NF+1) = '1' else ez_aux;
    
    -- Logica de saturacion:
    
    -- Caso overflow => Trunco al E_MAX
    -- Se da cuando: ez_aux(NE+ 1) = '0' and ez_aux(NE) = '1'
    
    -- Caso underflow => Trunco al E_MIN (todos '0')
    -- Se da cuando ez_aux(NE + 1) = '1' and ez_aux(NE) = '1'

    -- DE ESTA LINEA HASTA LA 119 NO VA EN LA ENTREGAR, HACER UN NUEVO ARCHIVO QUE SEA PARA ENTREGAR. ESTE QUEDA PARA EL GONZA DEL FUTURO
    -- Caso que descubri debbuguando:
    -- se da cuando  ex + ey - EXC = 0 
    -- o cuando ex + ey - EXC = -1 y luego le sumo por el resultado del significand
    -- en este caso, trunca fz al minimo directamente (no se porq).
    -- De todas formas, en el archivo 'fmul_15_6.txt' hay un solo caso (linea 505 o 504) en donde NO hace esto, no se porq.
    -- Hay 3 errores mas en el archivo 'fmul_15_6.txt', pero en estos casos no coincide ni el campo F ni el campo E (No deberia ser un caso limite o raro), asi que puedo suponer que hay algo raro en el archivo en ese caso.

    -- Con estas lineas los archivos corren casi sin errores salvo por los mencionados en la linea 93 y 95
    
    --ez <= E_MAX when (( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '1') ) or ( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '0') and (ez_aux_p(NE-1 downto 0) = EMAX_LIM ) )) else
    --    E_MIN when (( (ez_aux_p(NE+ 1) = '1') and (ez_aux_p(NE) = '1') ))  else
    --    ez_aux_p(NE-1 downto 0);

    --fz <= (others => '1') when ( ( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '1') ) or ( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '0') and (ez_aux_p(NE-1 downto 0) = EMAX_LIM ) )) else
    --        (others => '0') when ( ( (ez_aux_p(NE+ 1) = '1') and (ez_aux_p(NE) = '1') ) or (ez_aux_p = CEROS) ) else
    --        fz_aux;    


    -- UPDATE: Al final es un error en el archivo jejeje, no deberia pasar lo de la linea 91 porq no estamos usando IEEE754.
    -- opciones: Puedo modificar el archivo o comentarle el error en el informe.
    -- Por este UPDATE dejo todo como estaba que es la forma en la que estamos planteando las cosas en nuestro TP

    ez <= E_MAX when ( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '1') ) else
          E_MIN when (( (ez_aux_p(NE+ 1) = '1') and (ez_aux_p(NE) = '1') ))  else
          ez_aux_p(NE-1 downto 0);

    fz <= (others => '1') when ( (ez_aux_p(NE+ 1) = '0') and (ez_aux_p(NE) = '1') ) else
          (others => '0') when ( ( (ez_aux_p(NE+ 1) = '1') and (ez_aux_p(NE) = '1') ) ) else
          fz_aux;

    Z <= std_logic_vector(sz & RES_CERO) when ( cero_op = '1' ) else 
         std_logic_vector(sz & ez & fz);

end architecture behavioral;