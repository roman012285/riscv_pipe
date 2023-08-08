`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS RISC-V (32I) ISA CORE
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

// general cpu parameters defines //
`define REG_WIDTH  32
`define GPRN       32

// alu //
`define FLAGN     3 
`define FUNC_SIZE 4
`define add  4'b0000
`define sub  4'b1000
`define sll  4'b0001
`define slt  4'b0010
`define sltu 4'b0011
`define rxor 4'b0100
`define srl  4'b0101
`define sra  4'b1101
`define ror  4'b0110
`define rand 4'b0111


// instruction ram //
`define INST_DEPTH 1024
`define INST_SIZE  32

// data ram //
`define DATA_DEPTH 8192
`define DATA_SIZE  32

// ISA RV32I encoding //
`define r_type        7'b0110011
`define i_type_arithm 7'b0010011
`define i_type_dmem   7'b0000011
`define s_type        7'b0100011
`define b_type        7'b1100011
`define i_type_jalr   7'b1100111
`define j_type        7'b1101111
`define u_type_auipc  7'b0010111
`define u_type_lui    7'b0110111

`define op_code   IR[6:0]
`define func      IR[14:12]   
`define rd        IR[11:7]
`define rs1       IR[19:15]
`define rs2       IR[24:20]
`define func_bit  IR[30]  
`define shamt     IR[24:20]
`define msb       IR[31]
`define imm_i     IR[31:20]
`define imm_sr    IR[11:7]
`define imm_sl    IR[31:25]
`define imm_br    IR[11:8]
`define imm_bl    IR[30:25]
`define b_bit     IR[7]
`define imm_jl    IR[30:21]
`define imm_jr    IR[19:12]
`define l_bit     IR[20]
`define imm_u     IR[31:12]


  

