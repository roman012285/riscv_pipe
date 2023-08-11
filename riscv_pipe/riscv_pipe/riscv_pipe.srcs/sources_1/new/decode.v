`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS DECODE STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module decode(
    input                               clk,
    input                               rst,
    //----- from fetch stage -----//
    input  [`INST_WIDTH-1:0]            instruction,
    input  [`PC_WIDTH-1:0]              pc_from_id,
   //----- to execution stage -----//
    output reg [`REG_WIDTH-1:0]         alu_in1,    // alu1 input   
    output reg [`REG_WIDTH-1:0]         alu_in2,    // alu2 input 
    output reg [`FUNC_SIZE-1:0]         funct3_alu, // function passed to alu
    output reg [`PC_WIDTH-1:0]          pc2ex,      // pass pc to next stage
       
    //----- to data memory stage -----//
    output reg data_mem_en_idex,
    output reg data_mem_we_idex,
    
    //----- to write back stage -----//
    output reg                       gpr_en_idex,
    output reg                       gpr_we_idex,
    output reg [`REG_ADDR_WIDTH-1:0] addr_rd_idex,
    
    //----- from write back stage -----//
    input                               gpr_we_wb,
    input [`REG_WIDTH-1:0]              rd_in_wb,
    input                               gpr_en_wb,
    input [`REG_ADDR_WIDTH-1:0]         addr_rd_wb

    
);
     
    wire [`REG_WIDTH-1:0] rs1;
    wire [`REG_WIDTH-1:0] rs2;
       
    gpr gpr_module(
      .clk(clk),
      .we(gpr_we_wb),
      .en(gpr_en_wb),
      .addr_rs1(`addr_rs1),
      .addr_rs2(`addr_rs2),
      .addr_rd(addr_rd_wb),
      .data_rd(rd_in_wb),
      .data_rs1(rs1),
      .data_rs2(rs2)
    );
    
    
    wire [`IMM_ID-1:0] immidiate;
    
    imm_generator imm_generator_module(
        .instruction(instruction),
        .immidiate(immidiate)
    );
    
    // passing register info to next stage
    always@(posedge clk) begin
        pc2ex <= pc_from_id;
    end
   
   reg [`REG_WIDTH-1:0]      funct3_alu_ns;
   reg [`REG_WIDTH-1:0]      alu_in1_ns;
   reg [`REG_WIDTH-1:0]      alu_in2_ns;
   reg                       data_mem_en_idex_ns;
   reg                       data_mem_we_idex_ns;
   reg                       gpr_we_idex_ns;
   reg                       gpr_en_idex_ns;
   reg [`REG_ADDR_WIDTH-1:0] addr_rd_idex_ns;
      
   always@(posedge clk) begin
        if(rst) begin
            funct3_alu       <= 32'h00000000;
            alu_in1          <= 32'h00000000;
            alu_in2          <= 32'h00000000; 
            data_mem_en_idex <= 1'b0;
            data_mem_we_idex <= 1'b0;
            gpr_we_idex      <= 1'b0; 
            gpr_we_idex      <= 1'b0;
            addr_rd_idex     <= 5'b00000;         
        end
        else begin
            funct3_alu       <= funct3_alu_ns;
            alu_in1          <= alu_in1_ns;
            alu_in2          <= alu_in2_ns;
            data_mem_en_idex <= data_mem_en_idex_ns;
            data_mem_we_idex <= data_mem_we_idex_ns;
            gpr_we_idex      <= gpr_we_idex_ns; 
            gpr_we_idex      <= gpr_en_idex_ns;
            addr_rd_idex     <= addr_rd_idex_ns;
        end
   end
      
    //----- DECODER -----//
    always@(*) begin
        set_default();
        case(`op_code)
            `r_type: begin
                //to execution stage
                funct3_alu_ns       = {`bit, `funct3};
                alu_in1_ns          = rs1;
                alu_in2_ns          = rs2;
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;            
            end
            `i_type_arithm: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd; 
                //to execution stage
                alu_in1_ns    = rs1; 
                if(`funct3 == 3'b001 | `funct3 == 3'b101) begin
                    funct3_alu_ns = {`bit, `funct3};
                    alu_in2_ns    = {{27{1'b0}},`shamt};
                end
                else begin
                   funct3_alu_ns = {1'b0, `funct3};
                   alu_in2_ns    = immidiate;
                end
            end
            `s_type: begin
                 //to execution stage
                 funct3_alu_ns      = `add;
                 alu_in1_ns         = rs1;
                 alu_in2_ns         = immidiate;
                //to memory stage
                data_mem_en_idex_ns = 1'b1;
                data_mem_we_idex_ns = 1'b1;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd; 
            end     
            `i_type_dmem: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b1;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns  = `add;
                alu_in1_ns    = rs1;
                alu_in2_ns    = immidiate;
            end   
           `b_type: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = rs1;
                alu_in2_ns    = rs2; 
           end
           `i_type_jalr: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = rs1;
                alu_in2_ns    = immidiate; 
           end
           `j_type: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b0;
                gpr_we_idex_ns      = 1'b0;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = rs1;
                alu_in2_ns    = pc_from_id;         
            end
            `u_type_auipc: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = immidiate;
                alu_in2_ns    = pc_from_id;
            end
            `u_type_lui: begin
                //to memory stage
                data_mem_en_idex_ns = 1'b0;
                data_mem_we_idex_ns = 1'b0;
                //to write back stage
                gpr_en_idex_ns      = 1'b1;
                gpr_we_idex_ns      = 1'b1;
                addr_rd_idex_ns     = `addr_rd;
                //to execution stage
                funct3_alu_ns = `add;
                alu_in1_ns    = immidiate;
                alu_in2_ns    = 32'h00000000;
            end
            
        endcase  
    end

    task set_default(); begin
        funct3_alu_ns       = `add;
        alu_in1_ns          = 32'h00000000;
        alu_in2_ns          = 32'h00000000;
        data_mem_en_idex_ns = 1'b0;
        data_mem_we_idex_ns = 1'b0;
        gpr_en_idex_ns      = 1'b0;
        gpr_we_idex_ns      = 1'b0;
        addr_rd_idex_ns     = 5'b00000;              
        end
    endtask
    
endmodule
