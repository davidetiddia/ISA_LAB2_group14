library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.dadda_functions.all;

-- Modified Booth Encoder multiplier implemented with a Dadda tree

entity MBE is 
    port (A : in std_logic_vector (31 downto 0);
          B : in std_logic_vector (31 downto 0);
          PRODUCT : out std_logic_vector (63 downto 0));

end MBE;

architecture structural of MBE is
 
    component   booth_encoder is
        port ( enc : in std_logic_vector(2 downto 0);
              a   : in std_logic_vector (31 downto 0);
              p   : out std_logic_vector (32 downto 0));
    end component;


type encodearray is array (15 downto 0) of std_logic_vector (2 downto 0);
type mux_out    is array (15 downto 0) of std_logic_vector (32 downto 0);
type partial_product is array (13 downto 0) of std_logic_vector (34 downto 0);

signal addend_0:std_logic_vector (35 downto 0);   
signal addend : partial_product;
signal addend_15: std_logic_vector (33 downto 0);
signal addend_16: std_logic_vector (31 downto 0);
signal enc_fact: encodearray;


signal tmp: mux_out;

-------------------------------------------------------

-- signals needed at step 1 --

signal part_prod_1_0: std_logic_vector (63 downto 0);
signal part_prod_1_1: std_logic_vector (62 downto 0);
signal part_prod_1_2: std_logic_vector (59 downto 0);
signal part_prod_1_3: std_logic_vector (55 downto 0);
signal part_prod_1_4: std_logic_vector (51 downto 0);
signal part_prod_1_5: std_logic_vector (47 downto 0);
signal part_prod_1_6: std_logic_vector (43 downto 0);
signal part_prod_1_7: std_logic_vector (39 downto 0);
signal part_prod_1_8: std_logic_vector (35 downto 0);
signal part_prod_1_9: std_logic_vector (31 downto 0);
signal part_prod_1_10: std_logic_vector (27 downto 0);
signal part_prod_1_11: std_logic_vector (23 downto 0);
signal part_prod_1_12: std_logic_vector (19 downto 0);
signal part_prod_1_13: std_logic_vector (15 downto 0);
signal part_prod_1_14: std_logic_vector (11 downto 0);
signal part_prod_1_15: std_logic_vector (7 downto 0);
signal part_prod_1_16: std_logic_vector (4 downto 0);

--------------------------------------------------
-- signals needed at stage 2 ---------------------

signal part_prod_2_0: std_logic_vector (63 downto 0);
signal part_prod_2_1: std_logic_vector (62 downto 0);
signal part_prod_2_2: std_logic_vector (59 downto 0);
signal part_prod_2_3: std_logic_vector (55 downto 0);
signal part_prod_2_4: std_logic_vector (51 downto 0);
signal part_prod_2_5: std_logic_vector (47 downto 0);
signal part_prod_2_6: std_logic_vector (43 downto 0);
signal part_prod_2_7: std_logic_vector (39 downto 0);
signal part_prod_2_8: std_logic_vector (35 downto 0);
signal part_prod_2_9: std_logic_vector (31 downto 0);
signal part_prod_2_10: std_logic_vector (27 downto 0);
signal part_prod_2_11: std_logic_vector (23 downto 0);
signal part_prod_2_12: std_logic_vector (20 downto 0);

-----------------------------------------------------
-- signals needed at stage 3 ------------------------
signal part_prod_3_0 : std_logic_vector (63 downto 0);
signal part_prod_3_1 : std_logic_vector (62 downto 0);
signal part_prod_3_2 : std_logic_vector (59 downto 0);
signal part_prod_3_3 : std_logic_vector (55 downto 0);
signal part_prod_3_4 : std_logic_vector (51 downto 0);
signal part_prod_3_5 : std_logic_vector (47 downto 0);
signal part_prod_3_6 : std_logic_vector (43 downto 0);
signal part_prod_3_7 : std_logic_vector (39 downto 0);
signal part_prod_3_8 : std_logic_vector (36 downto 0);

-----------------------------------------------------
-- signals needed at stage 4 ------------------------
signal part_prod_4_0 : std_logic_vector (63 downto 0);
signal part_prod_4_1 : std_logic_vector (62 downto 0);
signal part_prod_4_2 : std_logic_vector (59 downto 0);
signal part_prod_4_3 : std_logic_vector (55 downto 0);
signal part_prod_4_4 : std_logic_vector (51 downto 0);
signal part_prod_4_5 : std_logic_vector (48 downto 0);

----------------------------------------------------
-- signals needed at stage 5 -----------------------
signal part_prod_5_0 : std_logic_vector (63 downto 0);
signal part_prod_5_1 : std_logic_vector (62 downto 0);
signal part_prod_5_2 : std_logic_vector (59 downto 0);
signal part_prod_5_3 : std_logic_vector (56 downto 0);

---------------------------------------------------
-- signals needed at stage 6 ----------------------
signal part_prod_6_0 : std_logic_vector (63 downto 0);
signal part_prod_6_1 : std_logic_vector (62 downto 0);
signal part_prod_6_2 : std_logic_vector (60 downto 0);

---------------------------------------------------
-- signals needed at stage 7 (last) ---------------
signal part_prod_7_0 : std_logic_vector (63 downto 0);
signal part_prod_7_1 : std_logic_vector (63 downto 0);

-- final product is obtained by : part_prod_7_0 + part_prod_7_1

begin
    
    -- assignment of every 3 bits encoding factor for the Booth algorithm
    encode_signals: for i in 0 to 16 generate
        first_addend: if i = 0 generate
            enc_fact(i) <= B(1 downto 0) & '0';
            mux_first: booth_encoder
            port map (enc_fact(i), A, tmp(i));
            
            addend_0 <= not(B(1)) & B(1) & B(1) & tmp(i); 


        end generate;


        i_th_addend: if i/=0 and i/=15 and i/=16 generate
                    enc_fact(i) <= B((i*2)+1 downto (i*2)-1);
                   
                    mux_i: booth_encoder                    
                    port map (enc_fact(i), A,tmp(i));

           addend(i-1) <= '1' & not(B(i*2+1)) & tmp(i);

        end generate;

        last_last_addend: if i=15 generate
            enc_fact(i) <= B(31 downto 29);

            mux_ii: booth_encoder           
            port map (enc_fact(i), A, tmp(i));

            addend_15 <= not(B(i*2+1)) & tmp(i);

        end generate;
        

        last_addend: if i = 16 generate
            addend_16 <= (others => '0') when B(31)='0' else
                            A when B(31)='1'; 
            end generate;
    end generate;



-- compose the part_prod_1_* words (stage 1)
part_prod_1_0  <= addend_15(33) & addend(13)(34 downto 33) & addend(12)(34 downto 33) & addend(11)(34 downto 33) & addend(10)(34 downto 33) & addend(9)(34 downto 33) & addend(8)(34 downto 33) & addend(7)(34 downto 33) & addend(6)(34 downto 33) & addend(5)(34 downto 33) & addend(4)(34 downto 33) & addend(3)(34 downto 33) & addend(2)(34 downto 33) & addend(1)(34 downto 33) & addend(0)(34) & addend_0(35 downto 0);
part_prod_1_1  <= addend_16(31) & addend_15(32 downto 31) & addend(13)(32 downto 31) & addend(12)(32 downto 31) & addend(11)(32 downto 31) & addend(10)(32 downto 31) & addend(9)(32 downto 31) & addend(8)(32 downto 31) & addend(7)(32 downto 31) & addend(6)(32 downto 31) & addend(5)(32 downto 31) & addend(4)(32 downto 31) & addend(3)(32 downto 31) & addend(2)(32 downto 31) & addend(1)(32) & addend(0)(33 downto 0) & B(1);
part_prod_1_2  <= addend_16(30 downto 29) & addend_15(30 downto 29) & addend(13)(30 downto 29) & addend(12)(30 downto 29) & addend(11)(30 downto 29) & addend(10)(30 downto 29) & addend(9)(30 downto 29) & addend(8)(30 downto 29) & addend(7)(30 downto 29) & addend(6)(30 downto 29) & addend(5)(30 downto 29) & addend(4)(30 downto 29) & addend(3)(30 downto 29) & addend(2)(30) & addend(1)(31 downto 0) & B(3);
part_prod_1_3  <= addend_16(28 downto 27) & addend_15(28 downto 27) & addend(13)(28 downto 27) & addend(12)(28 downto 27) & addend(11)(28 downto 27) & addend(10)(28 downto 27) & addend(9)(28 downto 27) & addend(8)(28 downto 27) & addend(7)(28 downto 27) & addend(6)(28 downto 27) & addend(5)(28 downto 27) & addend(4)(28 downto 27) & addend(3)(28) & addend(2)(29 downto 0) & B(5);
part_prod_1_4  <= addend_16(26 downto 25) & addend_15(26 downto 25) & addend(13)(26 downto 25) & addend(12)(26 downto 25) & addend(11)(26 downto 25) & addend(10)(26 downto 25) & addend(9)(26 downto 25) & addend(8)(26 downto 25) & addend(7)(26 downto 25) & addend(6)(26 downto 25) & addend(5)(26 downto 25) & addend(4)(26) & addend(3)(27 downto 0) & B(7);
part_prod_1_5  <= addend_16(24 downto 23) & addend_15(24 downto 23) & addend(13)(24 downto 23) & addend(12)(24 downto 23) & addend(11)(24 downto 23) & addend(10)(24 downto 23) & addend(9)(24 downto 23) & addend(8)(24 downto 23) & addend(7)(24 downto 23) & addend(6)(24 downto 23) & addend(5)(24) & addend(4)(25 downto 0) & B(9);
part_prod_1_6  <= addend_16(22 downto 21) & addend_15(22 downto 21) & addend(13)(22 downto 21) & addend(12)(22 downto 21) & addend(11)(22 downto 21) & addend(10)(22 downto 21) & addend(9)(22 downto 21) & addend(8)(22 downto 21) & addend(7)(22 downto 21) & addend(6)(22) & addend(5)(23 downto 0) & B(11);
part_prod_1_7  <= addend_16(20 downto 19) & addend_15(20 downto 19) & addend(13)(20 downto 19) & addend(12)(20 downto 19) & addend(11)(20 downto 19) & addend(10)(20 downto 19) & addend(9)(20 downto 19) & addend(8)(20 downto 19) & addend(7)(20) & addend(6)(21 downto 0) & B(13);
part_prod_1_8  <= addend_16(18 downto 17) & addend_15(18 downto 17) & addend(13)(18 downto 17) & addend(12)(18 downto 17) & addend(11)(18 downto 17) & addend(10)(18 downto 17) & addend(9)(18 downto 17) & addend(8)(18) & addend(7)(19 downto 0) & B(15);
part_prod_1_9  <= addend_16(16 downto 15) & addend_15(16 downto 15) & addend(13)(16 downto 15) & addend(12)(16 downto 15) & addend(11)(16 downto 15) & addend(10)(16 downto 15) & addend(9)(16) & addend(8)(17 downto 0) & B(17);
part_prod_1_10 <= addend_16(14 downto 13) & addend_15(14 downto 13) & addend(13)(14 downto 13) & addend(12)(14 downto 13) & addend(11)(14 downto 13) & addend(10)(14) & addend(9)(15 downto 0) & B(19);
part_prod_1_11 <= addend_16(12 downto 11) & addend_15(12 downto 11) & addend(13)(12 downto 11) & addend(12)(12 downto 11) & addend(11)(12) & addend(10)(13 downto 0) & B(21);
part_prod_1_12 <= addend_16(10 downto 9) & addend_15(10 downto 9) & addend(13)(10 downto 9) & addend(12)(10) & addend(11)(11 downto 0) & B(23);
part_prod_1_13 <= addend_16(8 downto 7) & addend_15(8 downto 7) & addend(13)(8) & addend(12)(9 downto 0) & B(25);
part_prod_1_14 <= addend_16(6 downto 5) & addend_15(6) & addend(13)(7 downto 0) & B(27);
part_prod_1_15 <= addend_16(4) & addend_15(5 downto 0) & B(29);
part_prod_1_16 <= addend_16(3 downto 0) & B(31);

----------------------------------------
---------stage 2 signals -> d=13 -------

part_prod_2_0(23 downto 0) <= part_prod_1_0 (23 downto 0);
part_prod_2_0(24) <= sum_HA(part_prod_1_0(24), part_prod_1_1(23));
part_prod_2_0(25) <= sum_HA(part_prod_1_0(25), part_prod_1_1(24));
part_prod_2_0_gen: for i in 26 to 41 generate
    part_prod_2_0(i) <= sum_FA(part_prod_1_0(i), part_prod_1_1(i-1), part_prod_1_2(i-3));
end generate;
part_prod_2_0(42) <= sum_HA(part_prod_1_0(42), part_prod_1_1(41));
part_prod_2_0(63 downto 43) <= part_prod_1_0 (63 downto 43);
--------------------
part_prod_2_1(22 downto 0)  <= part_prod_1_1 (22 downto 0);
part_prod_2_1(24 downto 23) <= part_prod_1_2 (22 downto 21);
part_prod_2_1(25) <= sum_HA (part_prod_1_3(21), part_prod_1_4(19));
part_prod_2_1(26) <= sum_HA (part_prod_1_3(22), part_prod_1_4(20));
part_prod_2_1_gen: for i in 27 to 38 generate
    part_prod_2_1(i) <= sum_FA (part_prod_1_3(i-4), part_prod_1_4(i-6), part_prod_1_5(i-8));
end generate;
part_prod_2_1(39) <= sum_HA (part_prod_1_3(35), part_prod_1_4(33));
part_prod_2_1(40) <= part_prod_1_3(36);
part_prod_2_1(41) <= part_prod_1_2(39);
part_prod_2_1(62 downto 42) <= part_prod_1_1(62 downto 42);
---------------------
part_prod_2_2(20 downto 0)  <= part_prod_1_2 (20 downto 0);
part_prod_2_2(22 downto 21)  <= part_prod_1_3 (20 downto 19);
part_prod_2_2(24 downto 23)  <= part_prod_1_5 (18 downto 17);
part_prod_2_2(25)  <= sum_HA (part_prod_1_6(17), part_prod_1_7(15));
part_prod_2_2(26)  <= sum_HA (part_prod_1_6(18), part_prod_1_7(16));
part_prod_2_2_gen: for i in 27 to 34 generate
part_prod_2_2(i)  <= sum_FA (part_prod_1_6(i-8), part_prod_1_7(i-10), part_prod_1_8(i-12));
end generate;                  
part_prod_2_2(35)  <= sum_HA (part_prod_1_6(27), part_prod_1_7(25));
part_prod_2_2(36)  <= part_prod_1_6(28);
part_prod_2_2(37)  <= part_prod_1_5(31);
part_prod_2_2(38)  <= part_prod_1_4(34);
part_prod_2_2(39)  <= part_prod_1_3(37);
part_prod_2_2(59 downto 40) <= part_prod_1_2(59 downto 40);
-------------------
part_prod_2_3(18 downto 0) <= part_prod_1_3 (18 downto 0);
part_prod_2_3(20 downto 19) <= part_prod_1_4(18 downto 17);
part_prod_2_3(22 downto 21) <= part_prod_1_6(16 downto 15);
part_prod_2_3(24 downto 23) <= part_prod_1_8(14 downto 13);
part_prod_2_3(25) <= sum_HA(part_prod_1_9(13), part_prod_1_10(11));
part_prod_2_3(26) <= sum_HA(part_prod_1_9(14), part_prod_1_10(12));
part_prod_2_3_gen: for i in 27 to 30 generate
part_prod_2_3(i) <= sum_FA(part_prod_1_9(i-12), part_prod_1_10(i-14), part_prod_1_11(i-16));
end generate;
part_prod_2_3(31) <= sum_HA(part_prod_1_9(19), part_prod_1_10(17));
part_prod_2_3(32) <= part_prod_1_9(20);
part_prod_2_3(33) <= part_prod_1_8(23);
part_prod_2_3(34) <= part_prod_1_7(26);
part_prod_2_3(35) <= part_prod_1_6(29);
part_prod_2_3(36) <= part_prod_1_5(32);
part_prod_2_3(37) <= part_prod_1_4(35);
part_prod_2_3(55 downto 38) <= part_prod_1_3(55 downto 38);
---------------------
part_prod_2_4(16 downto 0) <= part_prod_1_4(16 downto 0);
part_prod_2_4(18 downto 17) <= part_prod_1_5(16 downto 15);
part_prod_2_4(20 downto 19) <= part_prod_1_7(14 downto 13);
part_prod_2_4(22 downto 21) <= part_prod_1_9 (12 downto 11);
part_prod_2_4(24 downto 23) <= part_prod_1_11(10 downto 9);
part_prod_2_4(28 downto 25) <= part_prod_1_12(12 downto 9);
part_prod_2_4(29) <= part_prod_1_11(15);
part_prod_2_4(30) <= part_prod_1_10(18);
part_prod_2_4(31) <= part_prod_1_9(21);
part_prod_2_4(32) <= part_prod_1_8(24);
part_prod_2_4(33) <= part_prod_1_7(27);
part_prod_2_4(34) <= part_prod_1_6(30);
part_prod_2_4(35) <= part_prod_1_5(33);
part_prod_2_4(51 downto 36) <= part_prod_1_4(51 downto 36);
---------------------
part_prod_2_5(14 downto 0) <= part_prod_1_5(14 downto 0);
part_prod_2_5(16 downto 15) <= part_prod_1_6(14 downto 13);
part_prod_2_5(18 downto 17) <= part_prod_1_8(12 downto 11);
part_prod_2_5(20 downto 19) <= part_prod_1_10(10 downto 9);
part_prod_2_5(22 downto 21) <= part_prod_1_12(8 downto 7);
part_prod_2_5(26 downto 23) <= part_prod_1_13(10 downto 7);
part_prod_2_5(27) <= part_prod_1_12(13);
part_prod_2_5(28) <= part_prod_1_11(16);
part_prod_2_5(29) <= part_prod_1_10(19);
part_prod_2_5(30) <= part_prod_1_9(22);
part_prod_2_5(31) <= part_prod_1_8(25);
part_prod_2_5(32) <= part_prod_1_7(28);
part_prod_2_5(33) <= part_prod_1_6(31);
part_prod_2_5(47 downto 34) <= part_prod_1_5(47 downto 34);
-----------------
part_prod_2_6(12 downto 0) <= part_prod_1_6(12 downto 0);
part_prod_2_6(14 downto 13) <= part_prod_1_7(12 downto 11);
part_prod_2_6(16 downto 15) <= part_prod_1_9(10 downto 9);
part_prod_2_6(18 downto 17) <= part_prod_1_11(8 downto 7);
part_prod_2_6(20 downto 19) <= part_prod_1_13(6 downto 5);
part_prod_2_6(24 downto 21) <= part_prod_1_14(8 downto 5);
part_prod_2_6(25) <= part_prod_1_13(11);
part_prod_2_6(26) <= part_prod_1_12(14);
part_prod_2_6(27) <= part_prod_1_11(17);
part_prod_2_6(28) <= part_prod_1_10(20);
part_prod_2_6(29) <= part_prod_1_9(23);
part_prod_2_6(30) <= part_prod_1_8(26);
part_prod_2_6(31) <= part_prod_1_7(29);
part_prod_2_6(43 downto 32) <= part_prod_1_6(43 downto 32);
-----------------
part_prod_2_7(10 downto 0) <=  part_prod_1_7(10 downto 0);
part_prod_2_7(12 downto 11) <=  part_prod_1_8(10 downto 9);
part_prod_2_7(14 downto 13) <=  part_prod_1_10(8 downto 7);
part_prod_2_7(16 downto 15) <=  part_prod_1_12(6 downto 5);
part_prod_2_7(18 downto 17) <=  part_prod_1_14(4 downto 3);
part_prod_2_7(22 downto 19) <=  part_prod_1_15(6 downto 3);
part_prod_2_7(23) <=  part_prod_1_14(9);
part_prod_2_7(24) <=  part_prod_1_13(12);
part_prod_2_7(25) <=  part_prod_1_12(15);
part_prod_2_7(26) <=  part_prod_1_11(18);
part_prod_2_7(27) <=  part_prod_1_10(21);
part_prod_2_7(28) <=  part_prod_1_9(24);
part_prod_2_7(29) <=  part_prod_1_8(27);
part_prod_2_7(39 downto 30) <=  part_prod_1_7(39 downto 30);
----------------
part_prod_2_8(8 downto 0) <= part_prod_1_8(8 downto 0);
part_prod_2_8(10 downto 9) <= part_prod_1_9(8 downto 7);
part_prod_2_8(12 downto 11) <= part_prod_1_11(6 downto 5);
part_prod_2_8(14 downto 13) <= part_prod_1_13(4 downto 3);
part_prod_2_8(16 downto 15) <= part_prod_1_15(2 downto 1);
part_prod_2_8(20 downto 17) <= part_prod_1_16(4 downto 1);
part_prod_2_8(21) <= part_prod_1_15(7);
part_prod_2_8(22) <= part_prod_1_14(10);
part_prod_2_8(23) <= part_prod_1_13(13);
part_prod_2_8(24) <= part_prod_1_12(16);
part_prod_2_8(25) <= part_prod_1_11(19);
part_prod_2_8(26) <= part_prod_1_10(22);
part_prod_2_8(27) <= part_prod_1_9(25);
part_prod_2_8(35 downto 28) <= part_prod_1_8(35 downto 28);
----------------
part_prod_2_9(6 downto 0) <= part_prod_1_9(6 downto 0);
part_prod_2_9(8 downto 7) <= part_prod_1_10(6 downto 5);
part_prod_2_9(10 downto 9) <= part_prod_1_12(4 downto 3);
part_prod_2_9(12 downto 11) <= part_prod_1_14(2 downto 1);
part_prod_2_9(13) <= part_prod_1_16(0);
part_prod_2_9(14) <= carry_FA(part_prod_1_0(30), part_prod_1_1(29),part_prod_1_2(27));
part_prod_2_9(15) <= carry_FA(part_prod_1_0(31), part_prod_1_1(30), part_prod_1_2(28));
part_prod_2_9(16) <= carry_FA(part_prod_1_0(32), part_prod_1_1(31), part_prod_1_2(29));
part_prod_2_9(17) <= carry_FA(part_prod_1_0(33), part_prod_1_1(32), part_prod_1_2(30));
part_prod_2_9(18) <= carry_FA(part_prod_1_0(34), part_prod_1_1(33), part_prod_1_2(31)); 
part_prod_2_9(19) <= carry_FA(part_prod_1_0(35), part_prod_1_1(34), part_prod_1_2(32));
part_prod_2_9(20) <= carry_FA(part_prod_1_0(36), part_prod_1_1(35), part_prod_1_2(33));
part_prod_2_9(21) <= part_prod_1_14(11);
part_prod_2_9(22) <= part_prod_1_13(14);
part_prod_2_9(23) <= part_prod_1_12(17);
part_prod_2_9(24) <= part_prod_1_11(20);
part_prod_2_9(25) <= part_prod_1_10(23);
part_prod_2_9(31 downto 26) <= part_prod_1_9(31 downto 26);
-----------------------------
part_prod_2_10(4 downto 0) <= part_prod_1_10(4 downto 0);
part_prod_2_10(6 downto 5) <= part_prod_1_11(4 downto 3);
part_prod_2_10(8 downto 7) <= part_prod_1_13(2 downto 1);
part_prod_2_10(9) <= part_prod_1_15(0);
part_prod_2_10(10) <= carry_FA(part_prod_1_0(28), part_prod_1_1(27), part_prod_1_2(25));
part_prod_2_10(11) <= carry_FA(part_prod_1_0(29), part_prod_1_1(28), part_prod_1_2(26));
part_prod_2_10_gen: for i in 12 to 18 generate

part_prod_2_10(i) <= carry_FA(part_prod_1_3(i+13), part_prod_1_4(i+11), part_prod_1_5(i+9));
end generate;
part_prod_2_10(19) <= carry_FA(part_prod_1_0(37), part_prod_1_1(36), part_prod_1_2(34));
part_prod_2_10(20) <= carry_FA(part_prod_1_0(38), part_prod_1_1(37), part_prod_1_2(35));
part_prod_2_10(21) <= part_prod_1_13(15);
part_prod_2_10(22) <= part_prod_1_12(18);
part_prod_2_10(23) <= part_prod_1_11(21);
part_prod_2_10(27 downto 24) <= part_prod_1_10(27 downto 24);
-----------------------

part_prod_2_11(2 downto 0) <= part_prod_1_11(2 downto 0);
part_prod_2_11(4 downto 3) <= part_prod_1_12(2 downto 1);
part_prod_2_11(5) <= part_prod_1_14(0);
part_prod_2_11(6) <= carry_FA(part_prod_1_0(26), part_prod_1_1(25), part_prod_1_2(23));
part_prod_2_11(7) <= carry_FA(part_prod_1_0(27), part_prod_1_1(26), part_prod_1_2(24));
part_prod_2_11(8) <= carry_FA(part_prod_1_3(23), part_prod_1_4(21), part_prod_1_5(19)); 
part_prod_2_11(9) <= carry_FA(part_prod_1_3(24), part_prod_1_4(22), part_prod_1_5(20));
part_prod_2_11(10) <= carry_FA(part_prod_1_6(19), part_prod_1_7(17), part_prod_1_8(15));
part_prod_2_11(11) <= carry_FA(part_prod_1_6(20), part_prod_1_7(18), part_prod_1_8(16));
part_prod_2_11(12) <= carry_FA(part_prod_1_6(21), part_prod_1_7(19), part_prod_1_8(17));
part_prod_2_11(13) <= carry_FA(part_prod_1_6(22), part_prod_1_7(20), part_prod_1_8(18));
part_prod_2_11(14) <= carry_FA(part_prod_1_6(23), part_prod_1_7(21), part_prod_1_8(19));
part_prod_2_11(15) <= carry_FA(part_prod_1_6(24), part_prod_1_7(22), part_prod_1_8(20));
part_prod_2_11(16) <= carry_FA(part_prod_1_6(25), part_prod_1_7(23), part_prod_1_8(21));
part_prod_2_11(17) <= carry_FA(part_prod_1_3(32), part_prod_1_4(30), part_prod_1_5(28));
part_prod_2_11(18) <= carry_FA(part_prod_1_3(33), part_prod_1_4(31), part_prod_1_5(29));
part_prod_2_11(19) <= carry_FA(part_prod_1_0(39), part_prod_1_1(38), part_prod_1_2(36));
part_prod_2_11(20) <= carry_FA(part_prod_1_0(40), part_prod_1_1(39), part_prod_1_2(38)); 
part_prod_2_11(21) <= part_prod_1_12(19);
part_prod_2_11(23 downto 22) <= part_prod_1_11(23 downto 22);
------------------------------
part_prod_2_12(0) <= part_prod_1_12(0);
part_prod_2_12(1) <= part_prod_1_13(0);
part_prod_2_12(2) <= carry_HA(part_prod_1_0(24), part_prod_1_1(23));
part_prod_2_12(3) <= carry_HA(part_prod_1_0(25), part_prod_1_1(24));
part_prod_2_12(4) <= carry_HA(part_prod_1_3(21), part_prod_1_4(19));
part_prod_2_12(5) <= carry_HA(part_prod_1_3(22), part_prod_1_4(20));
part_prod_2_12(6) <= carry_HA(part_prod_1_6(17), part_prod_1_7(15));
part_prod_2_12(7) <= carry_HA(part_prod_1_6(18), part_prod_1_7(16));
part_prod_2_12(8) <= carry_HA(part_prod_1_9(13), part_prod_1_10(11)); 
part_prod_2_12(9) <= carry_HA(part_prod_1_9(14), part_prod_1_10(12)); 
part_prod_2_12(10) <= carry_FA(part_prod_1_9(15), part_prod_1_10(13), part_prod_1_11(11));
part_prod_2_12(11) <= carry_FA(part_prod_1_9(16), part_prod_1_10(14), part_prod_1_11(12));
part_prod_2_12(12) <= carry_FA(part_prod_1_9(17), part_prod_1_10(15), part_prod_1_11(13));
part_prod_2_12(13) <= carry_FA(part_prod_1_9(18), part_prod_1_10(16), part_prod_1_11(14));
part_prod_2_12(14) <= carry_HA(part_prod_1_9(19), part_prod_1_10(17));
part_prod_2_12(15) <= carry_FA(part_prod_1_6(26), part_prod_1_7(24), part_prod_1_8(22));
part_prod_2_12(16) <= carry_HA(part_prod_1_6(27), part_prod_1_7(25));
part_prod_2_12(17) <= carry_FA(part_prod_1_3(34), part_prod_1_4(32), part_prod_1_5(30));
part_prod_2_12(18) <= carry_HA(part_prod_1_3(35), part_prod_1_4(33));
part_prod_2_12(19) <= carry_FA(part_prod_1_0(41), part_prod_1_1(40), part_prod_1_2(38));
part_prod_2_12(20) <= carry_HA(part_prod_1_0(42), part_prod_1_1(41));
------------------------------
-- stage 3 signals => d = 9;
part_prod_3_0(15 downto 0) <= part_prod_2_0(15 downto 0);
part_prod_3_0(16) <= sum_HA(part_prod_2_0(16), part_prod_2_1(15));
part_prod_3_0(17) <= sum_HA(part_prod_2_0(17), part_prod_2_1(16));
part_prod_3_0_gen: for i in 18 to 49 generate
    part_prod_3_0(i) <= sum_FA(part_prod_2_0(i), part_prod_2_1(i-1), part_prod_2_2(i-3));
end generate;
part_prod_3_0(50) <= sum_HA(part_prod_2_0(50), part_prod_2_1(49));
part_prod_3_0(63 downto 51) <= part_prod_2_0(63 downto 51);
----------------------
part_prod_3_1(14 downto 0) <= part_prod_2_1(14 downto 0); 
part_prod_3_1(16 downto 15) <= part_prod_2_2 (14 downto 13); 
part_prod_3_1(17) <= sum_HA(part_prod_2_3(13), part_prod_2_4(11));
part_prod_3_1(18) <= sum_HA(part_prod_2_3(14), part_prod_2_4(12));
part_prod_3_1_gen: for i in 19 to 46 generate
    part_prod_3_1(i) <= sum_FA(part_prod_2_3(i-4), part_prod_2_4(i-6), part_prod_2_5(i-8));
end generate;
part_prod_3_1(47) <= sum_HA(part_prod_2_3(43), part_prod_2_4(41)); 
part_prod_3_1(48) <= part_prod_2_3(44);
part_prod_3_1(49) <= part_prod_2_2(47);
part_prod_3_1(62 downto 50) <= part_prod_2_1(62 downto 50);
---------------------
part_prod_3_2(12 downto 0)  <= part_prod_2_2(12 downto 0); 
part_prod_3_2(14 downto 13) <= part_prod_2_3(12 downto 11); 
part_prod_3_2(16 downto 15) <= part_prod_2_5(10 downto 9); 
part_prod_3_2(17) <= sum_HA(part_prod_2_6(9), part_prod_2_7(7));
part_prod_3_2(18) <= sum_HA(part_prod_2_6(10), part_prod_2_7(8));
part_prod_3_2_gen: for i in 19 to 42 generate
    part_prod_3_2(i) <= sum_FA(part_prod_2_6(i-8), part_prod_2_7(i-10), part_prod_2_8(i-12));
end generate;
part_prod_3_2(43) <= sum_HA(part_prod_2_6(35), part_prod_2_7(33));
part_prod_3_2(44) <= part_prod_2_6(36);
part_prod_3_2(45) <= part_prod_2_5(39);
part_prod_3_2(46) <= part_prod_2_4(42);
part_prod_3_2(47) <= part_prod_2_3(45);
part_prod_3_2(59 downto 48) <=  part_prod_2_2(59 downto 48);
--------------------------
part_prod_3_3(10 downto 0) <= part_prod_2_3(10 downto 0);
part_prod_3_3(12 downto 11) <= part_prod_2_4(10 downto 9);
part_prod_3_3(14 downto 13) <= part_prod_2_6(8 downto 7);
part_prod_3_3(16 downto 15) <= part_prod_2_8(6 downto 5);
part_prod_3_3(17) <= sum_HA(part_prod_2_9(5), part_prod_2_10(3));
part_prod_3_3(18) <= sum_HA(part_prod_2_9(6), part_prod_2_10(4));
part_prod_3_3_gen: for i in 19 to 38 generate
    part_prod_3_3(i) <= sum_FA(part_prod_2_9(i-12), part_prod_2_10(i-14), part_prod_2_11(i-16));
end generate;
part_prod_3_3(39) <= sum_HA(part_prod_2_9(27), part_prod_2_10(25));
part_prod_3_3(40) <= part_prod_2_9(28);
part_prod_3_3(41) <= part_prod_2_8(31);
part_prod_3_3(42) <= part_prod_2_7(34);
part_prod_3_3(43) <= part_prod_2_6(37); 
part_prod_3_3(44) <= part_prod_2_5(40);
part_prod_3_3(45) <= part_prod_2_4(43);
part_prod_3_3(55 downto 46) <= part_prod_2_3(55 downto 46);
--------------------
part_prod_3_4(8 downto 0)   <= part_prod_2_4(8 downto 0);
part_prod_3_4(10 downto 9)  <= part_prod_2_5(8 downto 7);
part_prod_3_4(12 downto 11) <= part_prod_2_7(6 downto 5);
part_prod_3_4(14 downto 13) <= part_prod_2_9(4 downto 3);
part_prod_3_4(16 downto 15) <= part_prod_2_11(2 downto 1);
part_prod_3_4_gen: for i in 17 to 36 generate
    part_prod_3_4(i) <= part_prod_2_12(i-16);
end generate;
part_prod_3_4(37) <= part_prod_2_11(23);
part_prod_3_4(38) <= part_prod_2_10(26);
part_prod_3_4(39) <= part_prod_2_9(29);
part_prod_3_4(40) <= part_prod_2_8(32);
part_prod_3_4(41) <= part_prod_2_7(35);
part_prod_3_4(42) <= part_prod_2_6(38);
part_prod_3_4(43) <= part_prod_2_5(41);
part_prod_3_4(51 downto 44) <= part_prod_2_4(51 downto 44);
-----------------------
part_prod_3_5(6 downto 0)   <= part_prod_2_5(6 downto 0);
part_prod_3_5(8 downto 7)   <= part_prod_2_6(6 downto 5);
part_prod_3_5(10 downto 9)  <= part_prod_2_8(4 downto 3);
part_prod_3_5(12 downto 11) <= part_prod_2_10(2 downto 1);
part_prod_3_5(13) <= part_prod_2_12(0);
part_prod_3_5(14) <= carry_FA(part_prod_2_0(22), part_prod_2_1(21), part_prod_2_2(19));
part_prod_3_5_gen: for i in 15 to 34 generate 
    part_prod_3_5(i) <= carry_FA(part_prod_2_0(i+8), part_prod_2_1(i+7), part_prod_2_2(i+5));
end generate;
part_prod_3_5(35) <= carry_FA(part_prod_2_0(43), part_prod_2_1(42), part_prod_2_2(40));
part_prod_3_5(36) <= carry_FA(part_prod_2_0(44), part_prod_2_1(43), part_prod_2_2(41));
part_prod_3_5(37) <= part_prod_2_10(27);
part_prod_3_5(38) <= part_prod_2_9(30);
part_prod_3_5(39) <= part_prod_2_8(33);
part_prod_3_5(40) <= part_prod_2_7(36);
part_prod_3_5(41) <= part_prod_2_6(39);
part_prod_3_5(47 downto 42) <= part_prod_2_5(47 downto 42);
-------------------
part_prod_3_6(4 downto 0) <= part_prod_2_6(4 downto 0);
part_prod_3_6(6 downto 5) <= part_prod_2_7(4 downto 3);
part_prod_3_6(8 downto 7) <= part_prod_2_9(2 downto 1);
part_prod_3_6(9) <= part_prod_2_11(0);
part_prod_3_6(10) <= carry_FA(part_prod_2_0(20), part_prod_2_1(19), part_prod_2_2(17));
part_prod_3_6(11) <= carry_FA(part_prod_2_0(21), part_prod_2_1(20), part_prod_2_2(18));
part_prod_3_6(12) <= carry_FA(part_prod_2_3(17), part_prod_2_4(15), part_prod_2_5(13));
part_prod_3_6_gen: for i in 13 to 32 generate
    part_prod_3_6(i) <= carry_FA(part_prod_2_3(i+5), part_prod_2_4(i+3), part_prod_2_5(i+1));
end generate;
part_prod_3_6(33) <= carry_FA(part_prod_2_3(38), part_prod_2_4(36), part_prod_2_5(34));
part_prod_3_6(34) <= carry_FA(part_prod_2_3(39), part_prod_2_4(37), part_prod_2_5(35));
part_prod_3_6(35) <= carry_FA(part_prod_2_0(45), part_prod_2_1(44), part_prod_2_2(42)); 
part_prod_3_6(36) <= carry_FA(part_prod_2_0(46), part_prod_2_1(45), part_prod_2_2(43)); 
part_prod_3_6(37) <= part_prod_2_9(31);
part_prod_3_6(38) <= part_prod_2_8(34);
part_prod_3_6(39) <= part_prod_2_7(37);
part_prod_3_6(43 downto 40) <= part_prod_2_6(43 downto 40);
----------------------------------------------
part_prod_3_7(2 downto 0) <= part_prod_2_7(2 downto 0);
part_prod_3_7(4 downto 3) <= part_prod_2_8(2 downto 1);
part_prod_3_7(5) <= part_prod_2_10(0);
part_prod_3_7(6) <= carry_FA(part_prod_2_0(18), part_prod_2_1(17), part_prod_2_2(15));
part_prod_3_7(7) <= carry_FA(part_prod_2_0(19), part_prod_2_1(18), part_prod_2_2(16));
part_prod_3_7(8) <= carry_FA(part_prod_2_3(15), part_prod_2_4(13), part_prod_2_5(11));
part_prod_3_7(9) <= carry_FA(part_prod_2_3(16), part_prod_2_4(14), part_prod_2_5(13));
part_prod_3_7(10) <= carry_FA(part_prod_2_6(11), part_prod_2_7(9), part_prod_2_8(7));
part_prod_3_7_gen: for i in 11 to 30 generate
    part_prod_3_7(i) <= carry_FA(part_prod_2_6(i+1), part_prod_2_7(i-1), part_prod_2_8(i-3));
end generate;
part_prod_3_7(31) <= carry_FA(part_prod_2_6(32), part_prod_2_7(30), part_prod_2_8(28));
part_prod_3_7(32) <= carry_FA(part_prod_2_6(33), part_prod_2_7(31), part_prod_2_8(29));
part_prod_3_7(33) <= carry_FA(part_prod_2_3(40), part_prod_2_4(38), part_prod_2_5(36));
part_prod_3_7(34) <= carry_FA(part_prod_2_3(41), part_prod_2_4(39), part_prod_2_5(37));
part_prod_3_7(35) <= carry_FA(part_prod_2_0(47), part_prod_2_1(46), part_prod_2_2(44));
part_prod_3_7(36) <= carry_FA(part_prod_2_0(48), part_prod_2_1(47), part_prod_2_2(45));
part_prod_3_7(37) <= part_prod_2_8(35);
part_prod_3_7(39 downto 38) <= part_prod_2_7(39 downto 38);
------------------------------
part_prod_3_8(0) <= part_prod_2_8(0);
part_prod_3_8(1) <= part_prod_2_9(0);
part_prod_3_8(2) <= carry_HA(part_prod_2_0(16),part_prod_2_1(15));
part_prod_3_8(3) <= carry_HA(part_prod_2_0(17),part_prod_2_1(16));
part_prod_3_8(4) <= carry_HA(part_prod_2_3(13),part_prod_2_4(11));
part_prod_3_8(5) <= carry_HA(part_prod_2_3(14),part_prod_2_4(12));
part_prod_3_8(6) <= carry_HA(part_prod_2_6(9),part_prod_2_7(7));
part_prod_3_8(7) <= carry_HA(part_prod_2_6(10),part_prod_2_7(8));
part_prod_3_8(8) <= carry_HA(part_prod_2_9(5),part_prod_2_10(3));
part_prod_3_8(9) <= carry_HA(part_prod_2_9(6),part_prod_2_10(4));
part_prod_3_8_gen: for i in 10 to 28 generate
    part_prod_3_8(i) <= carry_FA(part_prod_2_9(i-3), part_prod_2_10(i-5), part_prod_2_11(i-7));
end generate;
part_prod_3_8(29) <= carry_FA(part_prod_2_9(26), part_prod_2_10(24), part_prod_2_11(22));
part_prod_3_8(30) <= carry_HA(part_prod_2_9(27),part_prod_2_10(25));
part_prod_3_8(31) <= carry_FA(part_prod_2_6(34), part_prod_2_7(32), part_prod_2_8(30));
part_prod_3_8(32) <= carry_HA(part_prod_2_6(35),part_prod_2_7(33));
part_prod_3_8(33) <= carry_FA(part_prod_2_3(42), part_prod_2_4(40), part_prod_2_5(38));
part_prod_3_8(34) <= carry_HA(part_prod_2_3(43),part_prod_2_4(41));
part_prod_3_8(35) <= carry_FA(part_prod_2_0(49), part_prod_2_1(48), part_prod_2_2(46));
part_prod_3_8(36) <= carry_HA(part_prod_2_0(50),part_prod_2_1(49)); --?
-------------------------
-- stage 4 signals => d = 6;

part_prod_4_0(9 downto 0) <= part_prod_3_0(9 downto 0);
part_prod_4_0(10) <= sum_HA(part_prod_3_0(10), part_prod_3_1(9));
part_prod_4_0(11) <= sum_HA(part_prod_3_0(11), part_prod_3_1(10));
part_prod_4_0_gen: for i in 12 to 55 generate
part_prod_4_0(i) <= sum_FA(part_prod_3_0(i), part_prod_3_1(i-1), part_prod_3_2(i-3));
end generate;
part_prod_4_0(56) <= sum_HA(part_prod_3_0(56), part_prod_3_1(55));
part_prod_4_0(63 downto 57) <= part_prod_3_0(63 downto 57);
---------------
part_prod_4_1(8 downto 0) <= part_prod_3_1(8 downto 0);
part_prod_4_1(10 downto 9) <= part_prod_3_2(8 downto 7);
part_prod_4_1(11) <= sum_HA(part_prod_3_3(7), part_prod_3_4(5));
part_prod_4_1(12) <= sum_HA(part_prod_3_3(8), part_prod_3_4(6));
part_prod_4_1_gen: for i in 13 to 52 generate
part_prod_4_1(i) <=  sum_FA(part_prod_3_3(i-4), part_prod_3_4(i-6), part_prod_3_5(i-8));
end generate;
part_prod_4_1(53) <= sum_HA(part_prod_3_3(49), part_prod_3_4(47));
part_prod_4_1(54) <= part_prod_3_3(50);
part_prod_4_1(55) <= part_prod_3_2(53);
part_prod_4_1(62 downto 56) <= part_prod_3_1(62 downto 56);
---------------
part_prod_4_2(6 downto 0) <= part_prod_3_2(6 downto 0);  
part_prod_4_2(8 downto 7) <= part_prod_3_3(6 downto 5);
part_prod_4_2(10 downto 9) <= part_prod_3_5(4 downto 3);
part_prod_4_2(11) <= sum_HA(part_prod_3_6(3), part_prod_3_7(1));
part_prod_4_2(12) <= sum_HA(part_prod_3_6(4), part_prod_3_7(2));
part_prod_4_2_gen: for i in 13 to 48 generate
part_prod_4_2(i) <= sum_FA(part_prod_3_6(i-8), part_prod_3_7(i-10), part_prod_3_8(i-12));
end generate;
part_prod_4_2(49) <= sum_HA(part_prod_3_6(41), part_prod_3_7(39));
part_prod_4_2(50) <= part_prod_3_6(42);
part_prod_4_2(51) <= part_prod_3_5(45);
part_prod_4_2(52) <= part_prod_3_4(48);
part_prod_4_2(53) <= part_prod_3_3(51);
part_prod_4_2(59 downto 54) <= part_prod_3_2(59 downto 54);
---------------
part_prod_4_3(4 downto 0) <= part_prod_3_3(4 downto 0); 
part_prod_4_3(6 downto 5) <= part_prod_3_4(4 downto 3); 
part_prod_4_3(8 downto 7) <= part_prod_3_6(2 downto 1);
part_prod_4_3(9) <= part_prod_3_8(0);
part_prod_4_3_gen: for i in 10 to 48 generate
part_prod_4_3(i) <= carry_FA(part_prod_3_0(i+4), part_prod_3_1(i+3), part_prod_3_2(i+1));
end generate;
part_prod_4_3(49) <= part_prod_3_6(43);
part_prod_4_3(50) <= part_prod_3_5(46);
part_prod_4_3(51) <= part_prod_3_4(49);
part_prod_4_3(55 downto 52) <= part_prod_3_3(55 downto 52);
--------------
part_prod_4_4(2 downto 0) <= part_prod_3_4(2 downto 0);
part_prod_4_4(4 downto 3) <= part_prod_3_5(2 downto 1);
part_prod_4_4(5) <= part_prod_3_7(0);
part_prod_4_4(6) <= carry_FA(part_prod_3_0(12), part_prod_3_1(11), part_prod_3_2(9)); 
part_prod_4_4(7) <= carry_FA(part_prod_3_0(13), part_prod_3_1(12), part_prod_3_2(10));
part_prod_4_4_gen: for i in 8 to 46 generate
part_prod_4_4(i) <= carry_FA(part_prod_3_3(i+1), part_prod_3_4(i-1), part_prod_3_5(i-3)); 
end generate;
part_prod_4_4(47) <= carry_FA(part_prod_3_0(53), part_prod_3_1(52), part_prod_3_2(50));
part_prod_4_4(48) <= carry_FA(part_prod_3_0(54), part_prod_3_1(53), part_prod_3_2(51));
part_prod_4_4(49) <= part_prod_3_5(47);
part_prod_4_4(51 downto 50) <= part_prod_3_4(51 downto 50);
--------------
part_prod_4_5(0) <= part_prod_3_5(0);
part_prod_4_5(1) <= part_prod_3_6(0);
part_prod_4_5(2) <= carry_HA(part_prod_3_0(10), part_prod_3_1(9));
part_prod_4_5(3) <= carry_HA(part_prod_3_0(11), part_prod_3_1(10));
part_prod_4_5(4) <= carry_HA(part_prod_3_3(7), part_prod_3_4(5));
part_prod_4_5(5) <= carry_HA(part_prod_3_3(8), part_prod_3_4(6));
part_prod_4_5(6) <= carry_HA(part_prod_3_6(4), part_prod_3_7(2));
part_prod_4_5(7) <= carry_HA(part_prod_3_6(5), part_prod_3_7(3));
part_prod_4_5_gen: for i in 8 to 43 generate
part_prod_4_5(i) <=  carry_FA(part_prod_3_6(i-3), part_prod_3_7(i-5), part_prod_3_8(i-7));
end generate;
part_prod_4_5(44) <= carry_HA(part_prod_3_6(41), part_prod_3_7(39));
part_prod_4_5(45) <= carry_FA(part_prod_3_3(48), part_prod_3_4(46), part_prod_3_5(44)); 
part_prod_4_5(46) <= carry_HA(part_prod_3_3(49), part_prod_3_4(47));
part_prod_4_5(47) <= carry_FA(part_prod_3_0(56), part_prod_3_1(55), part_prod_3_2(54));
part_prod_4_5(48) <= carry_HA(part_prod_3_0(57), part_prod_3_1(56));
----------------------------
-- stage 5 signals => d = 4;
part_prod_5_0(5 downto 0) <= part_prod_4_0(5 downto 0); 
part_prod_5_0(6) <= sum_HA(part_prod_4_0(6), part_prod_4_1(5));
part_prod_5_0(7) <= sum_HA(part_prod_4_0(7), part_prod_4_1(6));
part_prod_5_0_gen: for i in 8 to 59 generate
part_prod_5_0(i) <= sum_FA(part_prod_4_0(i), part_prod_4_1(i-1), part_prod_4_2(i-3));
end generate;
part_prod_5_0(60) <= sum_HA(part_prod_4_0(60), part_prod_4_1(59));
part_prod_5_0(63 downto 61) <= part_prod_4_0(63 downto 61);
--------------------------
part_prod_5_1(4 downto 0) <= part_prod_4_1(4 downto 0);
part_prod_5_1(6 downto 5) <= part_prod_4_2(4 downto 3);
part_prod_5_1(7) <= sum_HA(part_prod_4_3(3), part_prod_4_4(1));
part_prod_5_1(8) <= sum_HA(part_prod_4_3(4), part_prod_4_4(2));
part_prod_5_1_gen: for i in 9 to 56 generate
part_prod_5_1(i) <= sum_FA(part_prod_4_3(i-4), part_prod_4_4(i-6), part_prod_4_5(i-8)); 
end generate;
part_prod_5_1(57) <= sum_HA(part_prod_4_3(53), part_prod_4_4(51));
part_prod_5_1(58) <= part_prod_4_3(54);
part_prod_5_1(59) <= part_prod_4_2(57);
part_prod_5_1(62 downto 60) <= part_prod_4_1(62 downto 60);
-----------------
part_prod_5_2(2 downto 0) <= part_prod_4_2(2 downto 0); 
part_prod_5_2(4 downto 3) <= part_prod_4_3(2 downto 1);
part_prod_5_2(5) <= part_prod_4_5(0);
part_prod_5_2_gen: for i in 6 to 56 generate
    part_prod_5_2(i) <= carry_FA(part_prod_4_0(i+2), part_prod_4_1(i+1), part_prod_4_2(i-1));
end generate;
part_prod_5_2(57) <= part_prod_4_3(55);
part_prod_5_2(59 downto 58) <= part_prod_4_2(59 downto 58);
-----------------
part_prod_5_3(0) <= part_prod_4_3(0);
part_prod_5_3(1) <= part_prod_4_4(0);
part_prod_5_3(2) <= carry_HA(part_prod_4_0(6), part_prod_4_1(5));
part_prod_5_3(3) <= carry_HA(part_prod_4_0(7), part_prod_4_1(6));
part_prod_5_3(4) <= carry_HA(part_prod_4_3(3), part_prod_4_4(1));
part_prod_5_3(5) <= carry_HA(part_prod_4_3(4), part_prod_4_4(2));
part_prod_5_3_gen: for i in 6 to 53 generate
    part_prod_5_3(i) <= carry_FA(part_prod_4_3(i-1), part_prod_4_4(i-3), part_prod_4_5(i-5));
end generate;
part_prod_5_3(54) <= carry_HA(part_prod_4_3(53), part_prod_4_4(51));
part_prod_5_3(55) <= carry_FA(part_prod_4_0(59), part_prod_4_1(58), part_prod_4_2(56));
part_prod_5_3(56) <= carry_HA(part_prod_4_0(60), part_prod_4_1(59));
------------------
-- stage 6 signals => d = 3;
part_prod_6_0(3 downto 0) <= part_prod_5_0(3 downto 0);
part_prod_6_0(4) <= sum_HA(part_prod_5_0(4), part_prod_5_1(3));
part_prod_6_0(5) <= sum_HA(part_prod_5_0(5), part_prod_5_1(4));
part_prod_6_0_gen: for i in 6 to 61 generate
part_prod_6_0(i) <= sum_FA(part_prod_5_0(i), part_prod_5_1(i-1), part_prod_5_2(i-3));
end generate;
part_prod_6_0(62) <= sum_HA(part_prod_5_0(62), part_prod_5_1(61)); --changed here
part_prod_6_0(63) <= part_prod_5_0(63);
----------------
part_prod_6_1(2 downto 0) <= part_prod_5_1(2 downto 0);
part_prod_6_1(4 downto 3) <= part_prod_5_2(2 downto 1);
part_prod_6_1(60 downto 5) <= part_prod_5_3(56 downto 1);
part_prod_6_1(61) <= part_prod_5_2(59);
part_prod_6_1(62) <= part_prod_5_1(62);
-----------------
part_prod_6_2(0) <= part_prod_5_2(0);
part_prod_6_2(1) <= part_prod_5_3(0);
part_prod_6_2(2) <= carry_HA(part_prod_5_0(4), part_prod_5_1(3));
part_prod_6_2(3) <= carry_HA(part_prod_5_0(5), part_prod_5_1(4));
part_prod_6_2_gen: for i in 4 to 59 generate
    part_prod_6_2(i) <= carry_FA(part_prod_5_0(i+2),part_prod_5_1(i+1), part_prod_5_2(i-1));
end generate;
part_prod_6_2(60) <= carry_HA(part_prod_5_0(62), part_prod_5_1(61));
----------------
-- stage 6 signals => d = 2;
part_prod_7_0(1 downto 0) <= part_prod_6_0(1 downto 0);
part_prod_7_0(2) <= sum_HA(part_prod_6_0(2), part_prod_6_1(1));
part_prod_7_0(3) <= sum_HA(part_prod_6_0(3), part_prod_6_1(2));
part_prod_7_0_gen: for i in 4 to 63 generate
    part_prod_7_0(i) <= sum_FA(part_prod_6_0(i), part_prod_6_1(i-1), part_prod_6_2(i-3));
end generate;

----------------
part_prod_7_1(0) <= part_prod_6_1(0);
part_prod_7_1(1) <= '0';
part_prod_7_1(2) <= part_prod_6_2(0);
part_prod_7_1(3) <= carry_HA(part_prod_6_0(2), part_prod_6_1(1));
part_prod_7_1(4) <= carry_HA(part_prod_6_0(3), part_prod_6_1(2));
part_prod_7_1_gen: for i in 5 to 63 generate
part_prod_7_1(i) <= carry_FA(part_prod_6_0(i-1), part_prod_6_1(i-2), part_prod_6_2(i-4));
end generate;


PRODUCT <= std_logic_vector(unsigned(part_prod_7_0) + unsigned(part_prod_7_1));


end structural;