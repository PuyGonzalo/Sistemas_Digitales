#! /bin/bash

ghdl -s ../Fuentes/Componentes/meta_harden.vhd ../Fuentes/Componentes/uart_baud_gen.vhd ../Fuentes/Componentes/uart_rx_ctl.vhd ../Fuentes/Componentes/uart_rx.vhd ../Fuentes/Componentes/atan_rom.vhd ../Fuentes/Componentes/add_sub.vhd ../Fuentes/Componentes/Nbits_Mult.vhd ../Fuentes/Componentes/cordic_base.vhd ../Fuentes/Componentes/cordic_iter.vhd ../Fuentes/Componentes/pre_cordic.vhd ../Fuentes/Componentes/post_cordic.vhd ../Fuentes/cordic.vhd ../Fuentes/uart_top.vhd ../Fuentes/recive_control.vhd ../Fuentes/cordic_control.vhd ../Fuentes/tp_top.vhd ../Fuentes/tp_tb_2.vhd 
ghdl -a ../Fuentes/Componentes/meta_harden.vhd ../Fuentes/Componentes/uart_baud_gen.vhd ../Fuentes/Componentes/uart_rx_ctl.vhd ../Fuentes/Componentes/uart_rx.vhd ../Fuentes/Componentes/atan_rom.vhd ../Fuentes/Componentes/add_sub.vhd ../Fuentes/Componentes/Nbits_Mult.vhd ../Fuentes/Componentes/cordic_base.vhd ../Fuentes/Componentes/cordic_iter.vhd ../Fuentes/Componentes/pre_cordic.vhd ../Fuentes/Componentes/post_cordic.vhd ../Fuentes/cordic.vhd ../Fuentes/uart_top.vhd ../Fuentes/recive_control.vhd ../Fuentes/cordic_control.vhd ../Fuentes/tp_top.vhd ../Fuentes/tp_tb_2.vhd
ghdl -e tp_testbench_2
ghdl -r tp_testbench_2 --vcd=tp.vcd
gtkwave tp.vcd wf2.gtkw

#clear