library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fp_subadd is
    generic(N : natural := 20;
            NE : natural := 6
    );
    port (
        X         : in std_logic_vector(N-1 downto 0); -- Operando 1
        Y         : in std_logic_vector(N-1 downto 0); -- Operando 2
        ctrl      : in std_logic; -- Indicador de suma o resta. Si es 0 se suma, si es 1 se resta.
        Z         : out std_logic_vector(N-1 downto 0) -- Resultado       
    );
end fp_subadd;

architecture behavioral of fp_subadd is

    constant EXC    : natural := 2**(NE-1)-1;
    constant NF     : natural := N-NE-1;
    constant EXCESO : signed(NE-1 downto 0) := to_signed(EXC, NE);
    constant E_MAX  : signed(NE downto 0) := to_signed(2**(NE)-2, NE+1);
    constant E_MIN  : signed(NE downto 0) := to_signed(0, NE+1);

    signal Y_aux    : std_logic_vector(N-1 downto 0) := (others => '0');

    signal ex_aux   : unsigned(NE downto 0) := (others => '0'); -- Tomo el campo E de la entrada X con un bit extra.
    signal ey_aux   : unsigned(NE downto 0) := (others => '0'); -- Tomo el campo E de la entrada Y con un bit extra.
    signal resta_E  : unsigned(NE downto 0) := (others => '0'); -- Resta de los campos E de X e Y.

    signal X_p      : unsigned(N-1 downto 0) := (others => '0'); -- X_prima con el que voy a hacer efectivamente la suma/resta
    signal Y_p      : unsigned(N-1 downto 0) := (others => '0'); -- Y_prima con el que voy a hacer efectivamente la suma/resta

    signal sx_p     : std_logic; -- Signo operando X_prima
    signal sy_p     : std_logic; -- Signo operando Y_prima
    signal ex_p     : unsigned(NE-1 downto 0) := (others => '0');  -- Campo E de X_prima
    signal ey_p     : unsigned(NE-1 downto 0) := (others => '0');  -- Campo E de Y_prima
    signal fx_p     : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa operando X_prima
    signal fy_p     : unsigned(NF-1 downto 0) := (others => '0'); -- Mantisa operando Y_prima
    signal mx_p     : unsigned(NF downto 0) := (others => '0'); -- Significand operando X_prima
    signal my_p     : unsigned(NF downto 0) := (others => '0'); -- significand operando Y_prima

    -- Señales para cuentas auxiliares con los significands
    --  Como tengo que agregar |Ex-Ey| '0's a la derecha de mx_p y |Ex - Ey| '0's a la izquierda de my_p,
    -- creo un unsigned mx_2prima con el peor caso posible de |Ex-Ey| (Ex todo '1' e Ey todos '0'),
    -- con esto me aseguro de tener siempre bien la cantidad de ceros.
    signal mx_2p    : unsigned(NF+2**(NE)-1 downto 0) := (others => '0');
    signal my_2p    : unsigned(NF+2**(NE)-1 downto 0) := (others => '0');
    signal mx_3p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal my_3p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal mx_4p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal my_4p    : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');

    signal suma     : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal suma_p   : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');

    signal fz_aux   : unsigned(NF+2**(NE)+1 downto 0) := (others => '0');
    signal fz_aux_p : unsigned(NF-1 downto 0) := (others => '0');
    signal fz       : unsigned(NF-1 downto 0) := (others => '0');
    signal ez_aux   : signed(NE downto 0) := (others => '0');
    signal ez       : signed(NE-1 downto 0) := (others => '0');
    signal sz       : std_logic := '0'; -- Signo Resultado Z
    
    signal comp_x   : std_logic := '0'; -- Bit que indica si debo complementar X_p: 0 -> no compemento; 1 -> complemento
    signal comp_y   : std_logic := '0'; -- Bit que indica si debo complentar Y_p: 0 -> no compemento; 1 -> complemento
    
    -- Funcion para encontrar el primer uno en un std_logic_vector
    function find_one (x0: std_logic_vector) return integer is

        variable found  : boolean;
        variable index  : integer;
        
    begin
        found := False;

        for i in x0'length-1 downto 0 loop
            if x0(i) = '1' and found = False then
                found := True;
                index := i;
            end if;
        end loop;
        
        if index < 0 then
            index := 0;
        end if;

        return index;
    end function;
    
begin

    Y_aux <= not(Y(N-1)) & Y(N-2 downto 0) when ctrl = '1' else
             Y;


    --  Verifico cual de los operandos tiene mayor exponente.
    -- para esto, agrego un 0 a la izquierda y chequeo el signo (MSB) de la resta entre los campos E.
    ex_aux <= '0' & unsigned(X(NF+NE-1 downto NF));
    ey_aux <= '0' & unsigned(Y_aux(NF+NE-1 downto NF));
    
    resta_E <= ex_aux - ey_aux;

    -- El campo Ex debe ser mayor (en valor absoluto) que el campo Ey.
    -- Si el resultado de la resta es negativo => Ex < Ey. Por lo tanto invierto los operandos,
    -- de lo contrario, los dejo como estaban.
    X_p <= unsigned(Y_aux) when ( resta_E(NE) = '1' ) else
           unsigned(X);

    Y_P <= unsigned(X) when ( resta_E(NE) = '1' ) else
           unsigned(Y_aux);

    -- Tomo lo necesario de los nuevos valores de X_prima e Y_prima
    sx_p <= X_p(NE+NF);
    sy_p <= Y_p(NE+NF);
    ex_p <= X_p(NF+NE-1 downto NF); -- Los ceros se los agrego para luego ver saturacion.
    ey_p <= Y_p(NF+NE-1 downto NF); -- Los ceros se los agrego xq no puedo operar con vectores de distintos tamaños.
    fx_p <= X_p(NF-1 downto 0);
    fy_p <= Y_p(NF-1 downto 0);
    mx_p <= '1' & fx_p; -- Le agrego un '1' al principio a F para calcular m
    my_p <= '1' & fy_p; -- por eso mx, my tienen NF+1 bits.

    -- Logica para complementar los operandos
    comp_x <= '0' when sx_p = '0' else
              '1';
    
    comp_y <= '0' when ( (sy_p = '0') ) else
              '1';
    
    -- Alineacion de los significands
    
    \

    mx_2p(NF downto 0) <= mx_p;
    my_2p(NF downto 0) <= my_p;

    -- Shifteo a izquierda |Ex| posiciones el significand del operando X_prima
    -- Shifteo a izquierda |Ey| posiciones el significand del operando Y_prima
    -- De esta forma me quedan bien alineados. 
    mx_3p <= '0' & '0' & (mx_2p sll to_integer(ex_p));
    my_3p <= '0' & '0' & (my_2p sll to_integer(ey_p));
    

    -- En caso de que tenga que complementar, lo hago
    mx_4p <= (not(mx_3p) + 1) when (comp_x = '1') else
             mx_3p;
    my_4p <= (not(my_3p) + 1) when (comp_y = '1') else
             my_3p;
    
    -- Suma/Resta efectiva
    suma <= mx_4p + my_4p;

    -- Signo del resultado Z.
    sz <= suma(NF+2**(NE)+1);
    
    --  Si el resultado de la suma/resta da negativo, tengo que complementar
    suma_p <= suma when suma(NF+2**(NE)+1) = '0' else
              (not(suma)+1);
    
    -- Normalizacion de la mantisa de Z
    fz_aux   <= suma_p sll (suma_p'length - find_one(x0 => std_logic_vector(suma_p)));
    fz_aux_p <= fz_aux(fz_aux'length-1 downto fz_aux'length-NF );


    -- Campo Ez
    ez_aux <= to_signed(find_one(x0 => std_logic_vector(suma_p)) - NF, NE+1);
    
    --  Logica de saturacion para el resultado
    ez <= E_MAX(NE-1 downto 0) when ( to_integer(ez_aux) > to_integer(E_MAX) ) else
          E_MIN(NE-1 downto 0) when ( to_integer(ez_aux) < to_integer(E_MIN) ) else
          ez_aux(NE-1 downto 0);

    fz <= (others => '1') when ( to_integer(ez_aux) > to_integer(E_MAX) ) else
          (others => '0') when ( to_integer(ez_aux) < to_integer(E_MIN) ) else
          fz_aux_p;
    
    -- Resultado final
    Z <= sz & std_logic_vector(ez) & std_logic_vector(fz);

end architecture behavioral;