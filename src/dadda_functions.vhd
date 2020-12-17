library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package dadda_functions is
    function sum_HA (a: std_logic; b: std_logic) return std_logic;
    function sum_FA (a: std_logic; b: std_logic; c: std_logic) return std_logic;
    function carry_HA (a: std_logic; b: std_logic) return std_logic;
    function carry_FA (a: std_logic; b: std_logic; c: std_logic) return std_logic;
    function my_xor (a: std_logic_vector(32 downto 0); b: std_logic) return std_logic_vector;
end;

package body dadda_functions is

    function sum_HA (a: std_logic; b: std_logic) return std_logic is
    begin 
        return a xor b;
    end;

    function sum_FA (a: std_logic; b: std_logic; c: std_logic) return std_logic is
    begin
        return a xor b xor c;
    end;

    function carry_HA (a: std_logic; b: std_logic) return std_logic is
    begin
        return a and b;
    end;


    function carry_FA (a: std_logic; b: std_logic; c: std_logic) return std_logic is
    begin
        return (a and b) or (a and c) or (b and c);
    end;

    function my_xor (a: std_logic_vector(32 downto 0); b: std_logic) return std_logic_vector is
        variable result : std_logic_vector(32 downto 0);
    begin 
        for i in 0 to 32 loop
            result(i) := a(i) xor b;
        end loop;
    return result;
    end function;

end package body;