`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART CONNECTS ALL STAGES OF RISC-V (32I) ISA
// AND PERFORMES TB
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module top_tb(
);

    localparam DELAY = 5;
    localparam OP = "READ";
    
    reg clk;
    reg rst;
    
    always #DELAY clk = ~clk;
    
    top #(.OP(OP)) top_module(
        .clk(clk),
        .rst(rst)
);

    initial begin
        //checking_rst();
        clk = 0;
        rst = 1;
        #(10*DELAY);
        
        
        rst = 0;
        #(20*DELAY);
        show_gpr();
        //$display("\ndata_memory");
        //show_data_mem();

        $finish();
    end


    task checking_rst(); begin
        clk = 0;
        rst = 1;
        
        $display("checking reset. Because of complexity in design please look at wave form");
        #(10*DELAY);
        $display("cycle1. time = %0t", $time);
    end
    endtask
    
    integer i;
    localparam N = 32;
    task show_gpr(); begin
        for(i = 0; i < N; i = i + 1)
            $display("gpr[%1d] = %1h", i, top_module.decode_module.gpr_module.gpr_mem[i]);
    end
    endtask
    
    localparam M = 10; 
    integer j;
    task show_data_mem(); begin
        for(j = 0; j < M; j = j + 1)
            $display("data[%1d] = %1h", j, top_module.mem_stage_module.data_ram.data_ram[j]);
    end
    endtask
    
 
    
endmodule
