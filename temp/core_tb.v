`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS RISC-V (32I) ISA CORE TB
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module core_tb(
);

   localparam CLK_CYCLE = 10;
   
   reg clk, rst;
   
    core core_module(
        .clk(clk),
        .rst(rst)
    );
    
    
    always #(CLK_CYCLE/2) clk = ~clk;
    
      initial begin
        clk = 0;
        rst = 0;
        #CLK_CYCLE;
        
        rst = 1;
        #CLK_CYCLE;
        
        //lui t1, 0
        if (core_module.gpr_instance.gpr_mem[1] == 32'h00000000)
            $display("lui t1, 0 -  PASS");
         else begin
            $display("lui t1, 0 - FAIL");
            $stop();
         end
        
        //lui t2, 0 
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[2] == 32'h00000000)
            $display("lui t2, 0 -  PASS");
         else begin
            $display("lui t2, 0 - FAIL");
            $stop();
         end
         
         //lui t31, 0 
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[31] == 32'h00000000)
            $display("lui t31, 0 -  PASS");
         else begin
            $display("lui t31, 0 - FAIL");
            $stop();
         end
         
        //lui t3, 7 
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[3] == 32'h00007000)
            $display("lui t3, 7 -  PASS");
         else begin
            $display("lui t3, 7 - FAIL");
            $stop();
         end
         
         //lui t4, a 
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[4] == 32'h0000a000)
            $display("lui t4, a -  PASS");
         else begin
            $display("lui t4, a - FAIL");
            $stop();
         end
         
         //add t5, t4, t3
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[5] == 32'h00011000)
            $display("add t5, t4, t3 -  PASS");
         else begin
            $display("add t5, t3, t4 - FAIL");
            $stop();
         end
        
        
        // add t6, t5, t0
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[6] == 32'h00011000)
            $display("add t6, t5, t0 -  PASS");
         else begin
            $display("add t6, t5, t0 - FAIL");
            $stop();
         end
         
         
        //slti t3,t3,4
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[3] == 32'h00000000)
            $display("slti t3,t3,4 -  PASS");
         else begin
            $display("slti t3,t3,4 - FAIL");
            $stop();
         end
         
        //slti t3,t3,4
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[3] == 32'h00000001)
            $display("slti t3,t3,4 -  PASS");
         else begin
            $display("slti t3,t3,4 - FAIL");
            $stop();
         end
         
        //slli r7,r4,2
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[7] == 32'h00028000)
            $display("slli r7,r4,2-  PASS");
         else begin
            $display("slli r7,r4,2 - FAIL");
            $stop();
         end
         
        //srli r8,r4,2
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[8] == 32'h00002800)
            $display("srli r8,r4,2-  PASS");
         else begin
            $display("srli r8,r4,2 - FAIL");
            $stop();
         end
        
        // testing sb, sh, sw //
        //lui r9, abcde
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[9] == 32'habcde000)
            $display("lui r9, abcde-  PASS");
         else begin
            $display("lui r9, abcde - FAIL");
            $stop();
         end
          
        //srai t10, t9, 8
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[10] == 32'hffabcde0)
            $display("srai t10, t9, 8-  PASS");
         else begin
            $display("srai t10, t9, 8 - FAIL");
            $stop();
         end
         
        //sb t10, 0(t0)
        #CLK_CYCLE;
        if (core_module.data_ram_module.data_ram[0] == 32'h000000e0)
            $display("sb t10, 0(t0)-  PASS");
         else begin
            $display("sb t10, 0(t0) - FAIL");
            $stop();
         end
         
        //sh t10, 0(t3)
        #CLK_CYCLE;
        if (core_module.data_ram_module.data_ram[1] == 32'h0000cde0)
            $display("sh t10, 0(t3)-  PASS");
         else begin
            $display("sh t10, 0(t3) - FAIL");
            $stop();
         end
         
        //sw t10, 1(t3)
        #CLK_CYCLE;
        if (core_module.data_ram_module.data_ram[2] == 32'hffabcde0)
            $display("sw t10, 1(t3)-  PASS");
         else begin
            $display("sw t10, 1(t3) - FAIL");
            $stop();
         end
         
         // testing lb, lh, lw, lbu, lhu // 
        //lb t1, 2(t0)
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[1] == 32'hffffffe0)
            $display("lb t1, 2(t0)-  PASS");
         else begin
            $display("lb t1, 2(t0) - FAIL");
            $stop();
         end
         
        //lh t1, 2(t0)
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[1] == 32'hffffcde0)
            $display("lh t1, 2(t0)-  PASS");
         else begin
            $display("lh t1, 2(t0) - FAIL");
            $stop();
         end
         
        //lw t1, 2(t0)
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[1] == 32'hffabcde0)
            $display("lw t1, 2(t0)-  PASS");
         else begin
            $display("lw t1, 2(t0) - FAIL");
            $stop();
         end
         
        //lbu t1, 2(t0)
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[1] == 32'h000000e0)
            $display("lbu t1, 2(t0)-  PASS");
         else begin
            $display("lbu t1, 2(t0) - FAIL");
            $stop();
         end
         
        //lhu t1, 2(t0)
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[1] == 32'h0000cde0)
            $display("lhu t1, 2(t0)-  PASS");
         else begin
            $display("lhu t1, 2(t0) - FAIL");
            $stop();
         end
         
         
        //auipc t11, 1
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[11] == 32'h00001015)
            $display("auipc t11, 1-  PASS");
         else begin
            $display("auipc t11, 1 - FAIL");
            $stop();
         end
        
       // jumps and branches check //
       // Uncomment each instruction separetly and the commet again for other instructions at that category //
       // Also uncomment each instruction in program.mem
       
        /***************************************************
        //jal t11, 1
        $display("pc value is : %1h", core_module.PC);
        #CLK_CYCLE;
        //JAL command cant be tested when pc is 10bits  wide . possible to test in wave viewer that alu gives right result
        if (core_module.gpr_instance.gpr_mem[12] == 32'h00000017 & core_module.PC == 10'h16)
            $display("jal t11, 1-  PASS");
         else begin
            $display("jal t11, 1 - FAIL");
            $stop();
         end
         ***************************************************/
        
        /***************************************************
        //jalr t12,1(t3)      
        $display("pc value is : %1h", core_module.PC);
        #CLK_CYCLE;
        if (core_module.gpr_instance.gpr_mem[12] == 32'h00000017 & core_module.PC == 10'd2)
            $display("jalr t12,1(t3)-  PASS");
         else begin
            $display("jalr t12,1(t3) - FAIL");
            $stop();
         end
         ***************************************************/
         
        /*************************************************** 
        
        //beq, bne, blt, bge, bltu, bgeu //
        //BRANCH command cant be tested when taken when pc is 10bits  wide . possible to change
        // the code to demo values in lines 204, 209, 214, 219, 224 in core.v and than observe PC value
        //beq t4, t5, 1
        $display("pc value before is : %1h", core_module.PC);
     
        #CLK_CYCLE;
        if (core_module.PC == 10'h17)
            $display("beq t4, t5, 1-  PASS");
         else begin
            $display("beq t4, t5, 1 - FAIL");
            $stop();
         end
         ***************************************************/
        
        /***************************************************   
        //bne t4, t5, 1
        $display("pc value before is : %1h", core_module.PC);
     
        #CLK_CYCLE;
        if (core_module.PC == 10'h17)
            $display("bne t4, t5, 1-  PASS");
         else begin
            $display("bne t4, t5, 1 - FAIL");
            $stop();
         end
         ***************************************************/

         show_gpr(); 
         #(5*CLK_CYCLE);
        
         show_data_mem(); 
         #(5*CLK_CYCLE);
         
        $finish();
      end 
    
        
      task show_gpr(); 
         integer i;
         for(i=0; i<`GPRN; i=i+1) begin
             $display("gpr[%1d] = %1h", i, core_module.gpr_instance.gpr_mem[i]); 
         end   
      endtask
      
      localparam SHOW = 5;
      task show_data_mem();
        integer j;
        for(j=0; j<SHOW; j=j+1)
           $display("data_mem[%1d] = %1h", j, core_module.data_ram_module.data_ram[j]);  
      endtask
        
        
endmodule
