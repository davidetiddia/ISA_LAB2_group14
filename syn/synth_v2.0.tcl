analyze -f vhdl -lib WORK ../src/fpnormalize_fpnormalize.vhd
analyze -f vhdl -lib WORK ../src/fpround_fpround.vhd
analyze -f vhdl -lib WORK ../src/packfp_packfp.vhd
analyze -f vhdl -lib WORK ../src/unpackfp_unpackfp.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage1_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage2_struct_REG.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage3_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_stage4_struct.vhd
analyze -f vhdl -lib WORK ../src/fpmul_pipeline.vhd


set power_preserve_rtl_hier_names true

elaborate FPmul -arch pipeline -lib WORK > ./elaborate.txt

link
create_clock -name MY_CLK -period 1.0 clk
set_dont_touch_network MY_CLK
set_clock_uncertainty 0.07 [get_clocks MY_CLK]
set_input_delay 0.5 -max -clock MY_CLK [remove_from_collection [all_inputs] clk]
set_output_delay 0.5 -max -clock MY_CLK [all_outputs]
set OLOAD [load_of NangateOpenCellLibrary/BUF_X4/A]
set_load $OLOAD [all_outputs]

ungroup -all -flatten

# uncomment to implement multiplier with csa
# set_implementation DW02_mult/csa [find cell *mult*]

# uncomment to implement multiplier with parallel-prefix
# set_implementation DW02_mult/pparch [find cell *mult*]

 compile

 optimize_registers

# compile_ultra

# report_resources > resources_flat.txt
# report_timing > timing_flat.txt
# report_area > area_flat.txt

#  report_resources > resources_csa.txt
#  report_timing > timing_csa.txt
#  report_area > area_csa.txt

# report_resources > resources_pparch.txt
# report_timing > timing_pparch.txt
# report_area > area_pparch.txt

# report_resources > resources_pipelined.txt
report_timing > timing_pipelined.txt
report_area > area_pipelined.txt

 quit
