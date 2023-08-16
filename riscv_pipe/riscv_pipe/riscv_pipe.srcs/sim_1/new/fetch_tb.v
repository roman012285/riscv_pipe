`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS FETCH STAGE TB OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module fetch_tb(
);


    localparam DELAY         = 5;
    
    localparam INST_WIDTH    = 32;
    localparam PC_WIDTH      = 32;
    
    reg                       clk;
    reg                       rst;
    reg                       jump_en;   // load enable incase of branches 
    reg [PC_WIDTH-1:0]        load_pc;   // pc from execution stage in case of branch
    reg                       pc_en; 
    reg                       inst_mem_en;
    reg                       inst_mem_we;
    reg                       inst_mem_rst;
    wire [INST_WIDTH-1:0]     inst_fetch_out;
    wire [PC_WIDTH-1:0]       pc2id;
    
    
    always #DELAY clk = ~clk;
    
    fetch fetch_module(
    .clk(clk),
    .rst(rst),
    .jump_en(jump_en),
    .load_pc(load_pc),
    .pc_en(pc_en), 
    .inst_mem_en(inst_mem_en),
    .inst_mem_we(inst_mem_we),
    .inst_mem_rst(inst_mem_rst),
    .inst_fetch_out(inst_fetch_out),
    .pc2id(pc2id)
    );
    
    
    initial begin
       clk          = 0;
       rst          = 1;
       load_pc      = 32'h04560002;
       jump_en      = 1'b1;
       inst_mem_en  = 1;
       inst_mem_we  = 0;
       inst_mem_rst = 0;
       pc_en        = 1'b0;
       #(2*DELAY);
       
       $display("\ncheck_reset");
       $display("pc = %1h\n", fetch_module.PC); 
       
       rst          = 1'b0;
       jump_en      = 1'b0;
       pc_en        = 1'b1;
       
       #(2*DELAY);
       $display("inc_pc");
       $display("pc = %1h\n", fetch_module.PC);
       
       #(2*DELAY);                             
       $display("inc_pc");                    
       $display("pc = %1h\n", fetch_module.PC);
       
       jump_en      = 1'b1;
       #(2*DELAY);                             
       $display("update_pc");                    
       $display("pc = %1h\n", fetch_module.PC);
       
       $finish();
    end
    
endmodule
