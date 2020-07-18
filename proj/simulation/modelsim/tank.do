onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /vgatest_vlg_tst/i1/absx32
add wave -noupdate /vgatest_vlg_tst/i1/absx42
add wave -noupdate /vgatest_vlg_tst/i1/absx43
add wave -noupdate /vgatest_vlg_tst/i1/absy32
add wave -noupdate /vgatest_vlg_tst/i1/absy42
add wave -noupdate /vgatest_vlg_tst/i1/absy43
add wave -noupdate /vgatest_vlg_tst/i1/blue
add wave -noupdate /vgatest_vlg_tst/i1/bullet_counter
add wave -noupdate /vgatest_vlg_tst/i1/bullet_direction
add wave -noupdate /vgatest_vlg_tst/i1/bullet_exit24
add wave -noupdate /vgatest_vlg_tst/i1/bullet_exit_reg
add wave -noupdate /vgatest_vlg_tst/i1/bullet_x
add wave -noupdate /vgatest_vlg_tst/i1/bullet_y
add wave -noupdate /vgatest_vlg_tst/i1/clk_100m
add wave -noupdate /vgatest_vlg_tst/i1/clk_200m
add wave -noupdate /vgatest_vlg_tst/i1/clk_25m
add wave -noupdate /vgatest_vlg_tst/i1/clk_50m
add wave -noupdate /vgatest_vlg_tst/i1/clk_slow
add wave -noupdate /vgatest_vlg_tst/i1/clk_slow_counter
add wave -noupdate /vgatest_vlg_tst/i1/dac_blank
add wave -noupdate /vgatest_vlg_tst/i1/dac_clk
add wave -noupdate /vgatest_vlg_tst/i1/dac_sync
add wave -noupdate /vgatest_vlg_tst/i1/direction
add wave -noupdate /vgatest_vlg_tst/i1/direction_ori
add wave -noupdate /vgatest_vlg_tst/i1/direction_reg
add wave -noupdate /vgatest_vlg_tst/i1/green
add wave -noupdate /vgatest_vlg_tst/i1/hsync
add wave -noupdate /vgatest_vlg_tst/i1/i
add wave -noupdate /vgatest_vlg_tst/i1/j
add wave -noupdate /vgatest_vlg_tst/i1/rst_n
add wave -noupdate /vgatest_vlg_tst/i1/clk_f
add wave -noupdate -expand /vgatest_vlg_tst/i1/bullet_exit
add wave -noupdate /vgatest_vlg_tst/i1/live
add wave -noupdate /vgatest_vlg_tst/i1/live_debug
add wave -noupdate /vgatest_vlg_tst/i1/rand_num
add wave -noupdate /vgatest_vlg_tst/i1/random
add wave -noupdate /vgatest_vlg_tst/i1/red
add wave -noupdate /vgatest_vlg_tst/i1/shoot
add wave -noupdate /vgatest_vlg_tst/i1/tank_direction
add wave -noupdate /vgatest_vlg_tst/i1/tank_exit
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[49]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[48]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[47]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[46]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[45]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[44]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[43]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[42]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[41]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_x[40]}
add wave -noupdate /vgatest_vlg_tst/i1/tank_x
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[49]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[48]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[47]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[46]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[45]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[44]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[43]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[42]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[41]}
add wave -noupdate {/vgatest_vlg_tst/i1/tank_y[40]}
add wave -noupdate /vgatest_vlg_tst/i1/tank_y
add wave -noupdate /vgatest_vlg_tst/i1/vsync
add wave -noupdate -radix ufixed /vgatest_vlg_tst/i1/x_cnt
add wave -noupdate -radix ufixed /vgatest_vlg_tst/i1/x_pos
add wave -noupdate -radix ufixed /vgatest_vlg_tst/i1/y_cnt
add wave -noupdate -radix ufixed /vgatest_vlg_tst/i1/y_pos
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {92921844 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 275
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {189 us}
