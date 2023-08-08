`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT INSTRUCTION RAM OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module inst_ram(
     input  [$clog2(`INST_DEPTH)-1:0]  addra,
     input                             clka,
     input  [`INST_SIZE-1:0]           dina, 
     output [`INST_SIZE-1:0]           douta
);


    reg [`INST_SIZE-1:0] inst_ram [0:`INST_DEPTH-1];
    
    initial 
        $readmemh("program.mem", inst_ram);
                   
    assign douta = inst_ram[addra];
    
endmodule
