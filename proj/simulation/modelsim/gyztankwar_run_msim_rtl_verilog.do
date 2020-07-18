transcript on
if ![file isdirectory gyztankwar_iputf_libs] {
	file mkdir gyztankwar_iputf_libs
}

if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

###### Libraries for IPUTF cores 
###### End libraries for IPUTF cores 
###### MIF file copy and HDL compilation commands for IPUTF cores 


vlog "D:/tankwar/pll_clock_sim/pll_clock.vo"

vlog -vlog01compat -work work +incdir+D:/tankwar {D:/tankwar/vgatest.v}
vlog -vlog01compat -work work +incdir+D:/tankwar {D:/tankwar/RanGen.v}
vlog -vlog01compat -work work +incdir+D:/tankwar {D:/tankwar/mybullet.v}
vlog -vlog01compat -work work +incdir+D:/tankwar {D:/tankwar/enermy1bullet.v}
vlog -vlog01compat -work work +incdir+D:/tankwar {D:/tankwar/enermy2bullet.v}

vlog -vlog01compat -work work +incdir+D:/tankwar/simulation/modelsim {D:/tankwar/simulation/modelsim/vgatest.vt}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  vgatest_vlg_tst

add wave *
view structure
view signals
run -all
