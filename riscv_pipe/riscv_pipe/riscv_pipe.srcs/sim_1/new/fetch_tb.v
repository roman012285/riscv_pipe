`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FETCH STAGE TB OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module fetch_tb(
);


    localparam DELAY         = 5;
    
    localparam MUX_FETCH_SEL = 2;
    localparam IMM           = 32;
    localparam INST_WIDTH    = 32;
    
    reg                       clk;
    reg                       rst;
    reg  [MUX_FETCH_SEL-1:0]  m_sel;
    reg  [IMM-1:0]            imm; 
    reg                       inst_mem_en;
    reg                       inst_mem_we;
    reg                       inst_mem_rst;
    wire [INST_WIDTH-1:0]     inst_fetch_out;
    
    
    always #DELAY clk = ~clk;
    
    fetch fetch_module(
    .clk(clk),
    .rst(rst),
    .m_sel(m_sel),
    .imm(imm), 
    .inst_mem_en(inst_mem_en),
    .inst_mem_we(inst_mem_we),
    .inst_mem_rst(inst_mem_rst),
    .inst_fetch_out(inst_fetch_out)
    );
    
    
    initial begin
       clk =          0;
       rst =          1;
       imm =          32'h00000002;
       inst_mem_en  = 1;
       inst_mem_we  = 0;
       inst_mem_rst = 0;
       #(2*DELAY);
        
       $display("\n");
        
       if(!fetch_module.PC) 
           $display("reset PC - PASS\n");
       else begin
           $display("reset PC - FAILED\n");
           $stop();
       end
                
       rst = 0;
       m_sel = 2'b00;
       #(2*DELAY);
       
       if(inst_fetch_out == 1)
           $display("mem[0] = 1 - PASS\n");
       else begin
           $display("mem[0] != 1 - FAIL\n");
           $stop();      
       end
               
       if(fetch_module.PC == 32'h00000001) 
           $display("INC PC - PASS\n");
       else begin
              $display("INC PC - FAIL\n");
              $stop();
       end
       
       m_sel = 2'b01;
       #(2*DELAY);
        
      if(inst_fetch_out == 2)
           $display("mem[1] = 2 - PASS\n");
       else begin
           $display("mem[1] != 2 - FAIL\n");
           $stop();      
       end 
       
       if(fetch_module.PC == 32'h00000003) 
           $display("IMM PC - PASS\n");
       else begin
           $display("IMM PC - FAIL\n");
           $stop();
       end
               
       m_sel = 2'b10;
       #(2*DELAY);
       
      if(inst_fetch_out == 32'hab12c456)
           $display("mem[3] = ab12c456 - PASS\n");
       else begin
           $display("mem[3] != ab12c456 - FAIL\n");
           $stop();      
       end
       
       if(fetch_module.PC == 32'h00000003) 
           $display("FREEZE PC - PASS\n");
       else begin
           $display("failed FREEZE PC\n");
           $stop();
       end
               
       m_sel = 2'b11;
       #(2*DELAY);
       
       if(inst_fetch_out == 32'hab12c456)
           $display("mem[3] = ab12c456 - PASS\n");
       else begin
           $display("mem[3] != ab12c456 - FAIL\n");
           $stop();      
       end
       
       if(fetch_module.PC == 32'h00000000)
           $display("m_sel == 2'b11 - PASS\n");
       else begin
           $display("m_sel = 2'b11 - FAIL\n");
           $stop();
         end
        
       #(2*DELAY);
       if(inst_fetch_out == 1)
           $display("mem[0] = 1 - PASS\n");
       else begin
           $display("mem[0] != 1 - FAIL\n");
           $stop();      
       end
           
       
        $finish();
    end
    
endmodule
