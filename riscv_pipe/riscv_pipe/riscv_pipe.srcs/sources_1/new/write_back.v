`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS WRITE BACK STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module write_back(
    //----- to decode stage -----// 
    input                           gpr_en_mem,       
    input                           gpr_we_mem,        // write enable to gpr. 
    input   [`REG_ADDR_WIDTH-1:0]   addr_rd_mem,       // rd address to write back into. 
    input   [`REG_WIDTH-1:0]        data_rd_mem,        // rd data to write back into.
    output                          gpr_en_id,    
    output                          gpr_we_id,        // write enable to gpr. 
    output  [`REG_ADDR_WIDTH-1:0]   addr_rd_id,       // rd address to write back into. 
    output  [`REG_WIDTH-1:0]        data_rd_id        // rd data to write back into. 
    
 );

    assign gpr_en_id   = gpr_en_mem;
    assign gpr_we_id   = gpr_we_mem;
    assign addr_rd_id  =  addr_rd_mem;
    assign data_rd_id  =  data_rd_mem; 
    
endmodule
