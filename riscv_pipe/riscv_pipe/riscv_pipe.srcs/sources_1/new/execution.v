`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS EXECUTION STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////

`include "defines.v"

module execution(
    input clk,
    input rst,
    
    //----- from decode stage -----//
    input [`REG_WIDTH-1:0]         alu_in1,    // alu1 input  
    input [`REG_WIDTH-1:0]         alu_in2,    // alu2 input 
    input [`FUNC_SIZE-1:0]         funct3_alu, // op code passed to alu
    input [`PC_WIDTH-1:0]          pc   ,      // pass from decode stage
    input [`OP_CODE_WIDTH-1:0]     op_code,    // instruction[6:0]
    input [`FUNCT3_WIDTH-1:0]      funct3,     // instruction[14:12] 
    input [`REG_WIDTH-1:0]         rs2,        // used in store instructions in mem stage
 
  
    //----- to data memory stage -----//
    input                                data_mem_en_idex,   // enables memory read in load-store instructions. pass as is to next stage
    input                                data_mem_we_idex,   // write enable in store instructions. pass as is to next stage
    input [`REG_WIDTH-1:0]               rs2_idex,           // used in store instructions in mem stage. pass as is to next stage
    output reg                           data_mem_en_mem,    // enables memory in load-store instructions. passed as is to next stage
    output reg                           data_mem_we_mem,    // write enable in store instructions. passed as is to next stage
    output reg [`REG_WIDTH-1:0]          rs2_mem,            // used in store instructions. passed as is to next stage
    output reg [$clog2(`DATA_DEPTH)-1:0] addr_mem,           // adder to store rs2 or load to rd
    output reg [`PC_WIDTH-1:0]           pc_mem,
    
    //----- to write back stage -----//
    input                              gpr_en_idex,       
    input                              gpr_we_idex,     // write enable to gpr. pass as is to next stage
    input [`REG_ADDR_WIDTH-1:0]        addr_rd_idex,    // rd address to write back into. pass as is to next stage
    output reg                         gpr_en_wb,    
    output reg                         gpr_we_wb,       // write enable to gpr. pass as is to next stage
    output reg [`REG_ADDR_WIDTH-1:0]   addr_rd_wb,      // rd address to write back into. pass as is to next stage
    output reg [`REG_ADDR_WIDTH-1:0]   data_rd_wb       // rd data to write back into. 

);

    wire [`REG_WIDTH-1:0] result; 
    wire [`FLAGN-1 :0]    flag;
    
    alu alu_module (
        .func_code(funct3_alu),
        .in1(alu_in1),
        .in2(alu_in2),
        .result(result),
        .flag(flag)      
    );
    
    reg [`REG_ADDR_WIDTH-1:0]     data_rd_wb_ns;
    reg [`PC_WIDTH-1:0]           pc_mem_ns;
    reg [$clog2(`DATA_DEPTH)-1:0] addr_mem_ns;
    
    always@(posedge clk) begin
        if(rst) 
            pc_mem <= 32'h00000000;
        else
            pc_mem <= pc_mem_ns;
    
    end
    
    always@(posedge clk) begin
        if(rst) begin
           data_mem_en_mem <= 1'b0;
           data_mem_we_mem <= 1'b0;
           rs2_mem         <= 32'h00000000;
           gpr_en_wb       <= 1'b0;
           gpr_we_wb       <= 1'b0;        
           addr_rd_wb      <= 0;
           data_rd_wb      <= 32'h00000000;
           addr_mem        <= 0;
        end
        else begin
           data_mem_en_mem <= data_mem_en_idex;
           data_mem_we_mem <= data_mem_we_idex;
           rs2_mem         <= rs2_idex;
           gpr_en_wb       <= gpr_en_idex;
           gpr_we_wb       <= gpr_we_idex;        
           addr_rd_wb      <= addr_rd_idex;
           data_rd_wb      <= data_rd_wb_ns;
           addr_mem        <= addr_mem_ns; 
        end
    end

    always@(*) begin
        set_default();
        pc_mem_ns = pc + 1;
        case(op_code)
            `r_type: 
                data_rd_wb_ns = result;           
            `i_type_arithm:
                data_rd_wb_ns = result;  
            `s_type:
                addr_mem_ns   = result;                     
            `i_type_dmem: 
                addr_mem_ns   = result;
           `b_type: begin
                if(funct3 == 3'b000)
                    if(flag[2])
                        pc_mem_ns = result;
                else if(funct3 == 3'b001)
                    if(!flag[2])
                        pc_mem_ns = result;
                else if(funct3 == 3'b100)
                    if(flag[0])
                        pc_mem_ns = result;
                else if(funct3 == 3'b101)
                    if(!flag[0])
                        pc_mem_ns = result;
               else if(funct3 == 3'b110)
                    if(flag[2])
                        pc_mem_ns = result;
               else if(funct3 == 3'b110)
                    if(!flag[2])
                        pc_mem_ns = result;       
           end
           `i_type_jalr: begin
                data_rd_wb_ns = pc + 1; 
                pc_mem_ns     = result;
           end
           `j_type: begin
                data_rd_wb_ns = pc + 1;
                pc_mem_ns     = result;  
            end
            `u_type_auipc: 
               data_rd_wb_ns = pc + 1;  
            `u_type_lui: begin
               data_rd_wb_ns = result;
            end
            
        endcase  
    end
    
    task set_default(); begin
        data_rd_wb_ns = 0;
        addr_mem_ns   = 0;
    end
    endtask
    
endmodule
