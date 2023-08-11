`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS DECODE TB STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module decode_tb(
);

    localparam DELAY             = 5;
    localparam INST_WIDTH        = 32;
    localparam PC_WIDTH          = 32;
    localparam REG_WIDTH         = 32;
    localparam INST_ID2EX_WIDTH  = 32;
    localparam IMM_ID2EX         = 32;
        
    reg clk;
    reg rst;
    
    // from fetch stage
    reg  [INST_WIDTH-1:0]        inst_decode_in;
    reg  [PC_WIDTH-1:0]          pc_from_id;
    // to decode stage
    wire [REG_WIDTH-1:0]         rs1_id2ex;
    wire [REG_WIDTH-1:0]         rs2_id2ex;
    wire [REG_WIDTH-1:0]         rd_id2ex;
    wire [INST_ID2EX_WIDTH-1:0]  inst_id2ex; // passing the whole instruction
    wire [IMM_ID2EX-1:0]         imm_id2ex;  // passing immidiate relative to op_code
    wire [PC_WIDTH-1:0]          pc2ex;
    // gpr control signals
    reg gpr_en;
    reg gpr_we;
    
    
    decode decode_module(
        .clk(clk),
        .inst_decode_in(inst_decode_in),
        .pc_from_id(pc_from_id),
        .rs1_id2ex(rs1_id2ex),
        .rs2_id2ex(rs2_id2ex),
        .rs1_id2ex(rd_id2ex),
        .inst_id2ex(inst_id2ex),
        .imm_id2ex(imm_id2ex),
        .pc2ex(pc2ex)
    );

    always #DELAY clk = ~clk;
    
    
    initial begin
        
    
    
    end

endmodule
