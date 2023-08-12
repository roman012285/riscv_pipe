`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS DECODE TB STAGE OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
////////////////////////////////////////////////////////////////////


module decode_tb(
);
    localparam DELAY          = 5;
    localparam INST_WIDTH     = 32;
    localparam PC_WIDTH       = 32;
    localparam REG_WIDTH      = 32;
    localparam FUNC_SIZE      = 4;
    localparam REG_ADDR_WIDTH = 5;
    
    
    ///////////// registers //////////////
    reg                       clk;
    reg                       rst;
    
    //----- from fetch stage -----//
    reg  [INST_WIDTH-1:0]    instruction;
    reg  [PC_WIDTH-1:0]      pc_from_id;
    
   //----- to execution stage -----//
    wire [REG_WIDTH-1:0]       alu_in1;    
    wire [REG_WIDTH-1:0]       alu_in2;    
    wire [FUNC_SIZE-1:0]       funct3_alu; 
    wire [PC_WIDTH-1:0]        pc2ex;      
       
    //----- to data memory stage -----//
    wire data_mem_en_idex;
    wire data_mem_we_idex;
    
    //----- to write back stage -----//
    wire                       gpr_en_idex;    
    wire                       gpr_we_idex;
    wire [REG_ADDR_WIDTH-1:0]  addr_rd_idex;
    
    //----- from write back stage -----//
    reg                       gpr_en_wb;
    reg                       gpr_we_wb;
    reg [REG_WIDTH-1:0]       rd_in_wb;
    reg [REG_ADDR_WIDTH-1:0]  addr_rd_wb;
    
    
    ////////// instantiation //////////
    decode decode_module(
    .clk(clk),
    .rst(rst),
    //----- from fetch stage -----//
    .instruction(instruction),
    .pc_from_id(pc_from_id),
    
   //----- to execution stage -----//
    .alu_in1(alu_in1),        
    .alu_in2(alu_in2),        
    .funct3_alu(funct3_alu), 
    .pc2ex(pc2ex),           
       
    //----- to data memory stage -----//
    .data_mem_en_idex(data_mem_en_idex),
    .data_mem_we_idex(data_mem_we_idex),
    
    //----- to write back stage -----//
    .gpr_en_idex(gpr_en_idex),    
    .gpr_we_idex(gpr_we_idex),
    .addr_rd_idex(addr_rd_idex),
    
    //----- from write back stage -----//
    .gpr_en_wb(gpr_en_wb),
    .gpr_we_wb(gpr_we_wb),
    .rd_in_wb(rd_in_wb),
    .addr_rd_wb(addr_rd_wb)
);

    always #DELAY clk = ~clk;
    
    
    initial begin
        clk = 0;
        rst = 1;
        $display("\ncheck reset");
        #(2*DELAY);
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex);  
        
        rst         = 0;
        $display("\nchecking add r5, r3, r2");
        instruction = 32'h0021f2b3;
        pc_from_id  = 32'h12345678;  // that value doesnt really matter at ID stage TB
        gpr_en_wb   = 1'b1;
        gpr_we_wb   = 1'b1;
        rd_in_wb    = 32'h00000002; // that value doesnt important at ID stage TB 
        addr_rd_wb  = 5'b00101;     // rd = 5 
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        
        #(2*DELAY);
        
        show_gpr();
        ///////////////////////////////////////////////////////////////////////////////////
        
        
        $display("\nchecking srai r12, r3, 7");
        // from that point we wont check decide_module inputs from write back stage
        instruction = 32'h4001d613;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
             
        $display("\nchecking sw r5, 3(r5)");
        instruction = 32'h0052a1a3;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
        
        $display("\nchecking lb r6, 3(r10)");
        instruction = 32'h00350303;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
        //branch instruction skipped from testing. There is nothing special about them at decode stage        
         
        ///////////////////////////////////////////////////////////////////////////////////
        
        $display("\nchecking jalr r5, 3(r0)");
        instruction = 32'h003002e7;
        pc_from_id  = 32'h00000005;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
                
        $display("\nchecking jal t11, 2");
        instruction = 32'h002005ef;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
        $display("\nchecking auipc t11, 1");
        instruction = 32'h00001597;
        #(2*DELAY);
        
        $display("funct3_alu = %1h\nalu_in1 = %1h\nalu_in2 = %1h",funct3_alu, alu_in1, alu_in2);
        $display("data_mem_en_idex = %1h\ndata_mem_we_idex = %1h\ngpr_en_idex = %1h", data_mem_en_idex, data_mem_we_idex, gpr_en_idex); 
        $display("gpr_we_idex = %1h\naddr_rd_idex = %1h\npc2ex = %1h", gpr_we_idex, addr_rd_idex, pc2ex); 
        ///////////////////////////////////////////////////////////////////////////////////
        
        //branch instruction skipped from testing. There is nothing special about them at decode stage
         
                  
        $finish();
    end
    
    integer i;
    localparam GPRN = 32;
    task show_gpr(); begin
        for(i=0; i < GPRN ; i=i+1) begin
            gpr_en_wb = 1'b1;
            $display("GPR[%1d] = %1h", i, decode_module.gpr_module.gpr_mem[i]);  
        end
    end
    endtask
    
endmodule