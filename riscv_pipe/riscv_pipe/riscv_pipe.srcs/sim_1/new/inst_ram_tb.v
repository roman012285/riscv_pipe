`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS ONE PORT INSTRUCTION BRAM TB OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

module inst_bram_tb(
);

     localparam DELAY =  5;
     localparam N     = 32;
     
     localparam INST_DEPTH = 2048;
     localparam INST_WIDTH =   32;
         
     reg  [$clog2(INST_DEPTH)-1:0]  addra;
     reg                            clka;
     reg  [INST_WIDTH-1:0]          dina; 
     wire [INST_WIDTH-1:0]          douta;
     reg                            ena; 
     reg                            wea;
     reg                            rsta;
                             
     always #DELAY clka = ~clka;
     
     inst_ram  inst_ram_module(
            .addra(addra),
            .clka(clka),
            .dina(dina),
            .douta(douta),
            .ena(ena),
            .wea(wea),
            .rsta(rsta)
     ); 
     
     integer i;
     integer j;
 
     initial begin
        clka = 0;
        ena =  1;
        wea =  1;
        rsta = 0;
        #DELAY;
        $display("writing to mem complited successfully");
        
        for(i=0; i<N; i = i+1) begin
            addra = i;
            dina  = i+1;
            #(30*DELAY);
        end  
        
        wea = 0;
        #DELAY;
        
        $display("start reading from memory");
        $display("-------------------------");
   
        for(j=0; j<N; j = j+1) begin
            addra = j;
            #(30*DELAY);
            $display("mem[%1d] = %1d", j, douta);             
        end
        
        $display("Testing reset");
        rsta = 1;
        addra = $random%5;  
        #(2*DELAY);
        $display("mem[%1d] = %1d", addra, douta);
                       
        $finish();
               
     end

endmodule
