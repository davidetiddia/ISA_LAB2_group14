library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.dadda_functions.all;


entity booth_encoder is
    port ( enc : in std_logic_vector(2 downto 0);
          a   : in std_logic_vector (31 downto 0);
          p   : out std_logic_vector (32 downto 0));
end booth_encoder;

architecture beh of booth_encoder is
    signal q_j : std_logic_vector (32 downto 0);
begin
    q_j <= (others => '0') when  (not(enc(1) xor enc(0)) and not(enc(2) xor enc(1))) ='1' else
           ('0' & a) when (enc(1) xor enc(0))='1' else
            std_logic_vector(shift_left(unsigned('0' & a),1)) when (not(enc(1) xor enc(0)) and (enc(2) xor enc(1))) = '1';
    p <= my_xor(q_j,enc(2));
end beh;

