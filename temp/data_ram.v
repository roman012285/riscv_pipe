`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT DATA RAM OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
/////////////////////////////////////////////////////////////////

`include "defines.v"

module data_ram(
     input  [$clog2(`DATA_DEPTH)-1:0]  addra,
     input                             clka,
     input  [`DATA_SIZE-1:0]           dina, 
     output [`DATA_SIZE-1:0]           douta,
     input                             ena,
     input                             wea
);

    // This is distributed RAM. To create block ram use IP or add register to output
    // possible to use (*ram_style = block"*) after creating output reg 
    reg [`DATA_SIZE-1:0] data_ram [0:`DATA_DEPTH-1];
    
    
    always @(posedge clka) begin
        if(ena & wea)
            data_ram[addra] <= dina;
    end 
    
    assign douta = (ena) ? data_ram[addra] : 0;
    
endmodule
