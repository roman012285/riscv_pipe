`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS EXECUTION TB STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module execution_tb(
 );
 
    localparam DELAY          = 5;
    localparam REG_WIDTH      = 32;
    localparam FUNC_SIZE      = 4;
    localparam PC_WIDTH       = 32;
    localparam OP_CODE_WIDTH  = 7;
    localparam FUNCT3_WIDTH   = 3;
    localparam DATA_DEPTH     = 2048;
    localparam REG_ADDR_WIDTH = 5;
    localparam IMM_ID         = 32;
    
    
    reg clk;
    reg rst;
    
  //----- from decode stage -----//
    reg [REG_WIDTH-1:0]         alu_in1;    // alu1 input  
    reg [REG_WIDTH-1:0]         alu_in2;    // alu2 input 
    reg [FUNC_SIZE-1:0]         funct3_alu; // op code passed to alu
    reg [PC_WIDTH-1:0]          pc;         // pass from decode stage
    reg [OP_CODE_WIDTH-1:0]     op_code;    // instruction[6:0]
    reg [FUNCT3_WIDTH-1:0]      funct3;     // instruction[14:12] 
 
  
    //----- to data memory stage -----//
    reg                           data_mem_en_idex;   // enables memory read in load-store instructions. pass as is to next stage
    reg                           data_mem_we_idex;   // write enable in store instructions. pass as is to next stage
    reg [REG_WIDTH-1:0]           rs2_idex;           // used in store instructions in mem stage. pass as is to next stage
    reg [IMM_ID-1:0]              immidiate; 
    wire                          data_mem_en_mem;    // enables memory in load-store instructions. passed as is to next stage
    wire                          data_mem_we_mem;    // write enable in store instructions. passed as is to next stage
    wire [REG_WIDTH-1:0]          rs2_mem;            // used in store instructions. passed as is to next stage
    wire [$clog2(DATA_DEPTH)-1:0] addr_mem;           // adder to store rs2 or load to rd
    
    //----- to write back stage -----//
    reg                         gpr_en_idex;       
    reg                         gpr_we_idex;     // write enable to gpr. pass as is to next stage
    reg  [REG_ADDR_WIDTH-1:0]   addr_rd_idex;    // rd address to write back into. pass as is to next stage
    wire                        gpr_en_wb;    
    wire                        gpr_we_wb;       // write enable to gpr. pass as is to next stage
    wire [REG_ADDR_WIDTH-1:0]   addr_rd_wb;      // rd address to write back into. pass as is to next stage
    wire [REG_WIDTH-1:0]        data_rd_wb;       // rd data to write back into.
    
    //----- to fetch stage -----//
    wire [PC_WIDTH-1:0]         pc_fetch;
    
    always #DELAY clk = ~clk;
    
    execution execution_module(
    .clk(clk),
    .rst(rst),
    
    //----- from decode stage -----//
    .alu_in1(alu_in1),          // alu1 input  
    .alu_in2(alu_in2),          // alu2 input 
    .funct3_alu(funct3_alu),    // op code passed to alu
    .pc(pc),                    // pass from decode stage
    .op_code(op_code),          // instruction[6:0]
    .funct3(funct3),            // instruction[14:12] 
 
  
    //----- to data memory stage -----//
    .data_mem_en_idex(data_mem_en_idex),    // enables memory read in load-store instructions. pass as is to next stage
    .data_mem_we_idex(data_mem_we_idex),    // write enable in store instructions. pass as is to next stage
    .rs2_idex(rs2_idex),                    // used in store instructions in mem stage. pass as is to next stage
    .immidiate(immidiate),
    .data_mem_en_mem(data_mem_en_mem),      // enables memory in load-store instructions. passed as is to next stage
    .data_mem_we_mem(data_mem_we_mem),      // write enable in store instructions. passed as is to next stage
    .rs2_mem(rs2_mem),                      // used in store instructions. passed as is to next stage
    .addr_mem(addr_mem),                    // adder to store rs2 or load to rd
    
    //----- to write back stage -----//
    .gpr_en_idex(gpr_en_idex),       
    .gpr_we_idex(gpr_we_idex),     // write enable to gpr. pass as is to next stage
    .addr_rd_idex(addr_rd_idex),   // rd address to write back into. pass as is to next stage
    .gpr_en_wb(gpr_en_wb),    
    .gpr_we_wb(gpr_we_wb),         // write enable to gpr. pass as is to next stage
    .addr_rd_wb(addr_rd_wb),       // rd address to write back into. pass as is to next stage
    .data_rd_wb(data_rd_wb),        // rd data to write back into. 
    .pc_fetch(pc_fetch)
);
    
    initial begin
        clk              = 0;
        rst              = 1;
        
        // wont be changed during sumulation
        pc               = 32'h12345678;
        data_mem_en_idex = 1'b1;
        data_mem_we_idex = 1'b1;
        rs2_idex         = 32'h12345678; 
        gpr_en_idex      = 1'b1;
        gpr_we_idex      = 1'b1;
        addr_rd_idex     = 5'b01010; 
        immidiate        = 32'h00000003;      
         
        #(2*DELAY);

        $display("\nRESET CHECK, ALL REGS MUST BE ZERO!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("-----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        
        ////////////////////////////////////////////////////////////////////////
        
        rst     = 0;
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000007;
        
        funct3_alu = 4'b1000;       // op code passed to alu
        op_code    = 7'b0110011;    // instruction[6:0]
        funct3     = 3'b000;        // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING R and I TYPE  INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
        ////////////////////////////////////////////////////////////////////////
        
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h12345678;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b0100011 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING S TYPE (sb) INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
        ////////////////////////////////////////////////////////////////////////
        
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h12345678;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b0100011 ;    // instruction[6:0]
        funct3     = 3'b001;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING S TYPE (sh) INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
       ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000073;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b0000011 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING I TYPE MEM INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        
        ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000005;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b1100011 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING B TYPE (beq) INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
    
        ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000005;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b1100111 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING JALR INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
        ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000005;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b1101111 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING JAL INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
        ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000005;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b0010111 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING AUIPC INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
         ////////////////////////////////////////////////////////////////////////
         
        alu_in1 = 32'h00000005;
        alu_in2 = 32'h00000005;
        
        funct3_alu = 4'b0000;        // op code passed to alu
        op_code    = 7'b0110111 ;    // instruction[6:0]
        funct3     = 3'b000;         // instruction[14:12] 
        #(2*DELAY);
        
        $display("\nCHECKING LUI INSTRUCTION!!!");
        
        $display("memory stage registers:");
        $display("----------------------");
        $display("data_mem_en_mem = %1h\ndata_mem_we_mem = %1h\nrs2_mem = %1h\naddr_mem = %1h\npc_fetch = %1h", data_mem_en_mem, data_mem_we_mem, rs2_mem, addr_mem, pc_fetch);
    
        $display("\nwrite back stage registers:");
        $display("----------------------------");
        $display("gpr_en_wb = %1h\ngpr_we_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
 
          
                     
    
    end
    
endmodule
