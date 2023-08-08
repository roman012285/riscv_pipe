`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FETCH STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module fetch(
    input                        clk,
    input                        rst,
    input  [`MUX_FETCH_SEL-1:0]  m_sel,
    input  [`IMM-1:0]            imm, 
    input                        inst_mem_en,
    input                        inst_mem_we,
    input                        inst_mem_rst,  //IF = 0
    output [`INST_WIDTH-1:0]     inst_fetch_out
);

    reg [`PC_WIDTH-1:0] PC, N_PC;
    
    always@(posedge clk) begin
        if(rst) 
            PC <= 32'h00000000;
        else 
            PC <= N_PC;
    end    
    
    always@(*) begin
        case(m_sel)
            `INC_PC:
                N_PC = PC + 1;
            `BRANCH_PC:
                N_PC = PC + imm;
            `FREEZE_PC: 
                N_PC = PC;
             default:
                N_PC = 32'h00000000;
        endcase   
    end
    
    inst_ram inst_ram_module(
     .addra(PC), 
     .clka(clk),
     .dina(), 
     .douta(inst_fetch_out),
     .ena(inst_mem_en), 
     .wea(inst_mem_we),
     .rsta(inst_mem_rst)
);
  
endmodule
