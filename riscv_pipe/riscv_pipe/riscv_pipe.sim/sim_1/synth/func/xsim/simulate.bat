@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Mon Aug 07 12:13:02 +0300 2023
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim inst_bram_tb_func_synth -key {Post-Synthesis:sim_1:Functional:inst_bram_tb} -tclbatch inst_bram_tb.tcl -view D:/BarIlan/DDP/exercises/RiscV_pipe/riscv_pipe/riscv_pipe/inst_bram_tb_behav.wcfg -log simulate.log"
call xsim  inst_bram_tb_func_synth -key {Post-Synthesis:sim_1:Functional:inst_bram_tb} -tclbatch inst_bram_tb.tcl -view D:/BarIlan/DDP/exercises/RiscV_pipe/riscv_pipe/riscv_pipe/inst_bram_tb_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
