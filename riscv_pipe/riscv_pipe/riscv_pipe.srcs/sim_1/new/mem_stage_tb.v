`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS MEMORY STAGE TB OF RISC-V (32I) ISA
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////


module mem_stage_tb(

    );
    
    localparam DELAY          = 5;
    localparam REG_WIDTH      = 32;
    localparam DATA_DEPTH     = 2048;
    localparam REG_ADDR_WIDTH = 5;
    localparam FUNCT3_WIDTH   = 3;
        
    reg clk;
    reg rst;
    
    //----- from execution stage -----//
    reg                          data_mem_en;    // enables memory in load-store instructions
    reg                          data_mem_we;    // write enable in store instructions
    reg [REG_WIDTH-1:0]          rs2_mem;        // used in store instructions
    reg [$clog2(DATA_DEPTH)-1:0] addr_mem;       // adder to store rs2 or load to rd
    reg [FUNCT3_WIDTH-1:0]       funct3_mem;     // defines what type of load instruction
    reg                          mem_wb;         // when '1' is load instruction. when '0' something else
    
    //----- to write back stage -----//
    reg                         gpr_en_ex;       
    reg                         gpr_we_ex;        // write enable to gpr. pass as is to next stage
    reg [REG_ADDR_WIDTH-1:0]    addr_rd_ex;       // rd address to write back into. pass as is to next stage
    reg [REG_WIDTH-1:0]         data_rd_ex;       // rd data to write back into.
    wire                        gpr_en_wb;    
    wire                        gpr_we_wb;        // write enable to gpr. pass as is to next stage
    wire [REG_ADDR_WIDTH-1:0]   addr_rd_wb;       // rd address to write back into. pass as is to next stage
    wire [REG_WIDTH-1:0]        data_rd_wb;       // rd data to write back into.
    wire [REG_WIDTH-1:0]        data_rd_wb_mem;   // rd data to write back into when loaded from memory. 
    wire [FUNCT3_WIDTH-1:0]     funct3_mem_wb;    // defines what type of load instruction. pass as is to next stage
    wire                        mem_mem_wb;       // when '1' is load instruction. when '0' something else. pass as is to next stage

    mem_stage mem_stage_module(
    .clk(clk), 
    .rst(rst),
    
    //----- from execution stage -----//
    .data_mem_en(data_mem_en),   
    .data_mem_we(data_mem_we),   
    .rs2_mem(rs2_mem),        
    .addr_mem(addr_mem),
    .funct3_mem(funct3_mem),
    .mem_wb(mem_wb),    
    
    //----- to write back stage -----//
    .gpr_en_ex(gpr_en_ex),       
    .gpr_we_ex(gpr_we_ex),        
    .addr_rd_ex(addr_rd_ex),      
    .data_rd_ex(data_rd_ex),        
    .gpr_en_wb(gpr_en_wb),    
    .gpr_we_wb(gpr_we_wb),        
    .addr_rd_wb(addr_rd_wb),       
    .data_rd_wb(data_rd_wb),
    .data_rd_wb_mem( data_rd_wb_mem),       
    .funct3_mem_wb(funct3_mem_wb),
    .mem_mem_wb(mem_mem_wb)   
 );

    always #DELAY clk = !clk;
    
    initial begin
        clk = 0;
        rst = 1;
        
        data_mem_en = 1'b0;
        data_mem_we = 1'b0;
        rs2_mem     = 32'h12345678;
        addr_mem    = 3'h002;
        
        funct3_mem  = 3'b001;
        mem_wb      = 1'b0; 
        
        gpr_en_ex   = 1'b1;
        gpr_we_ex   = 1'b1;
        
        addr_rd_ex  = 5'b00101;
        data_rd_ex  = 32'h1234abcd;
        
        #(2*DELAY);
        $display("\ngpr_en_wb = %1h\ngpr_en_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        $display("funct3_mem_wb = %1h\nmem_mem_wb = %1h",funct3_mem_wb, mem_mem_wb); 
        $display("data_rd_wb_mem = %1h", data_rd_wb_mem);      
        
        rst = 0;
        data_mem_en = 1'b0;
        data_mem_we = 1'b0;
       
        
        #(2*DELAY);
        $display("\ngpr_en_wb = %1h\ngpr_en_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        $display("funct3_mem_wb = %1h\nmem_mem_wb = %1h",funct3_mem_wb, mem_mem_wb);
        $display("data_rd_wb_mem = %1h", data_rd_wb_mem);
        
        data_mem_en = 1'b1;
        data_mem_we = 1'b0;
       
        
        #(2*DELAY);
        $display("\ngpr_en_wb = %1h\ngpr_en_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        $display("funct3_mem_wb = %1h\nmem_mem_wb = %1h",funct3_mem_wb, mem_mem_wb);
        $display("data_rd_wb_mem = %1h", data_rd_wb_mem);
        
        data_mem_en = 1'b1;
        data_mem_we = 1'b1;
        
        
        #(2*DELAY);
        $display("\ngpr_en_wb = %1h\ngpr_en_wb = %1h\naddr_rd_wb = %1h\ndata_rd_wb = %1h\n\n", gpr_en_wb, gpr_we_wb, addr_rd_wb, data_rd_wb);
        $display("funct3_mem_wb = %1h\nmem_mem_wb = %1h",funct3_mem_wb, mem_mem_wb);
        $display("data_rd_wb_mem = %1h\n", data_rd_wb_mem);
       
        red_mem();
        
        $finish();
    end
    
    integer i;
    task red_mem(); begin
        for(i=0; i< 10; i = i + 1) 
            $display("data_mem[%1d] = %1h",i,  mem_stage_module.data_ram.data_ram[i]); 
    end
    endtask
    
    
endmodule
