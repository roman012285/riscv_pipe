`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS MEMORY STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module mem_stage(
    input                           clk, 
    input                           rst,
    
    //----- from execution stage -----//
    input                           data_mem_en,    // enables memory in load-store instructions
    input                           data_mem_we,    // write enable in store instructions
    input [`REG_WIDTH-1:0]          rs2_mem,        // used in store instructions
    input [$clog2(`DATA_DEPTH)-1:0] addr_mem,       // adder to store rs2 or load to rd
    
    //----- to write back stage -----//
    input                              gpr_en_ex,       
    input                              gpr_we_ex,        // write enable to gpr. pass as is to next stage
    input [`REG_ADDR_WIDTH-1:0]        addr_rd_ex,       // rd address to write back into. pass as is to next stage
    input [`REG_WIDTH-1:0]             data_rd_ex,        // rd data to write back into.
    output reg                         gpr_en_wb,    
    output reg                         gpr_we_wb,        // write enable to gpr. pass as is to next stage
    output reg [`REG_ADDR_WIDTH-1:0]   addr_rd_wb,       // rd address to write back into. pass as is to next stage
    output     [`REG_WIDTH-1:0]        data_rd_wb        // rd data to write back into. 
    
 );
  
      wire [`REG_WIDTH-1:0] mem_out;
      reg  [`REG_WIDTH-1:0] data_rd_ex_ns; // use this reg to create flip flop while passig rd to next state. caused of memory read latency = 1
     
      data_ram data_ram(
     .addr(addr_mem),
     .clk(clk),
     .din(rs2_mem), 
     .dout(mem_out),
     .en(data_mem_en), 
     .we(data_mem_we),
     .rst(rst)  
);

     always@(posedge clk) begin
        if(rst) begin
            gpr_en_wb  <= 1'b0;
            gpr_we_wb  <= 1'b0;
            addr_rd_wb <= 0;
        end
        else begin
            gpr_en_wb  <= gpr_en_ex;
            gpr_we_wb  <= gpr_we_ex;
            addr_rd_wb <= addr_rd_ex;
        end
    end

    // creating flip flop caused by the need to synchronize read memory 1 latency. 
     always @(posedge clk) 
        data_rd_ex_ns <= data_rd_ex;
        
        assign data_rd_wb = (rst | (data_mem_en & !data_mem_we)) ? mem_out : data_rd_ex_ns;
        
        /*  
        always@(posedge clk) begin
            if(rst)
                data_rd_wb <= 32'h00000000;
            else if(data_mem_en & !data_mem_we)   // load rd <- mem[addr]
                data_rd_wb <= mem_out;
            else
                data_rd_wb <= data_rd_ex;                    
        end
        */
        
endmodule
