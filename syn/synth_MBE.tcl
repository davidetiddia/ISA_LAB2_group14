analyze -f vhdl -lib WORK ../src/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../src/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../src/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../src/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../src/dadda_functions.vhd
analyze -f vhdl -lib WORK ../src/encoder.vhd
analyze -f vhdl -lib WORK ../src/MBE.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage2_struct_MBE.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage4_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_pipeline.vhd


set power_preserve_rtl_hier_names true

elaborate FPmul -arch pipeline -lib WORK > ./elaborate.txt

link
#1.2 nm -> 0.35 //
create_clock -name MY_CLK -period 2.72 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

ungroup -all -flatten

compile

 report_resources > resources_MBE.txt
 report_timing > timing_MBE.txt
 report_area > area_MBE.txt



# change_names -hierarchy -rules verilog
# write_sdf ../netlist/filter.sdf
# write -f verilog -hierarchy -output ../netlist/filter.v
# write_sdc ../netlist/filter.sdc
 quit
