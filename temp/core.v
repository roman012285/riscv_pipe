`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// THIS PART IMPLEMENTS RISC-V (32I) ISA CORE
// Designer is a member of ENICS LABS at Bar - Ilan university
// Designer contacts : Roman Gilgor. roman329@gmail.com
//////////////////////////////////////////////////////////////////////////////////

`include "defines.v"

module core(
    input                           clk,
    input                           rst
 );
 
    // alu instantiation //
    reg   [`FUNC_SIZE-1:0]   funct3_alu;
    reg   [`REG_WIDTH-1:0]   rs1_alu, rs2_alu;
    wire  [`REG_WIDTH-1:0]   result_alu;
    wire  [`FLAGN-1 :0]      flag_alu; 
    
    alu alu_instance (
      .func_code(funct3_alu),
      .in1(rs1_alu),
      .in2(rs2_alu),
      .result(result_alu),
      .flag(flag_alu)      
 );

    // GPR instantiation //
    wire                      clk_gpr;
    reg                       we_gpr;
    reg                       en_gpr;
    reg  [$clog2(`GPRN)-1:0]  addr_rs1_gpr;
    reg  [$clog2(`GPRN)-1:0]  addr_rs2_gpr;
    reg  [$clog2(`GPRN)-1:0]  addr_rd_gpr;
    reg  [`REG_WIDTH-1:0]     data_rd_gpr;
    wire [`REG_WIDTH-1:0]     data_rs1_gpr;
    wire [`REG_WIDTH-1:0]     data_rs2_gpr;
       
    assign clk_gpr = clk;
      
    gpr gpr_instance(
      .clk(clk_gpr),
      .we(we_gpr),
      .en(en_gpr),
      .addr_rs1(addr_rs1_gpr),
      .addr_rs2(addr_rs2_gpr),
      .addr_rd(addr_rd_gpr),
      .data_rd(data_rd_gpr),
      .data_rs1(data_rs1_gpr),
      .data_rs2(data_rs2_gpr) 
);


    // instraction ram //
    reg  [$clog2(`INST_DEPTH)-1:0]  addr_inst;
    wire                            clk_inst;
    reg  [`INST_SIZE-1:0]           din_inst; 
    wire [`INST_SIZE-1:0]           dout_inst;
    
    assign clk_inst = clk;
     
    inst_ram inst_ram_module(
      .addra(addr_inst),
      .clka(clk_inst),
      .dina(din_inst), 
      .douta(dout_inst)
);

    // data  ram //
    reg  [$clog2(`DATA_DEPTH)-1:0]  addr_data;
    wire                            clk_data;
    reg  [`DATA_SIZE-1:0]           din_data; 
    wire [`DATA_SIZE-1:0]           dout_data;
    reg                             en_data;
    reg                             we_data;
    
    assign clk_data = clk;
     
    data_ram data_ram_module(
      .addra(addr_data),
      .clka(clk_data),
      .dina(din_data), 
      .douta(dout_data),
      .ena(en_data),
      .wea(we_data)
);
    
    reg [`REG_WIDTH-1:0]           IR;  // Instruction register
    reg [$clog2(`INST_DEPTH)-1:0]  PC, N_PC;  // program counter register
    
    
    // instruction core //
    always @(*) begin
        set_default();
        case(`op_code) 
             `r_type: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  result_alu;   
                      // alu
                      funct3_alu   = {`func_bit, `func};
                      rs1_alu      =  data_rs1_gpr;
                      rs2_alu      =  data_rs2_gpr; 
                      // program counter
                      N_PC = PC + 1;   
             end // end `r_type case
             `i_type_arithm: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  result_alu;
                      // alu
                      funct3_alu   = {`func_bit, `func};  
                      rs1_alu      =  data_rs1_gpr;
                      if(`func == 3'b001 | `func == 3'b101) begin
                        rs2_alu      = {{27{1'b0}},`shamt};
                        funct3_alu   = {`func_bit, `func};
                      end
                      else begin
                        rs2_alu      = {{20{`msb}},`imm_i};
                        funct3_alu   = {{1'b0}, `func};
                      end 
                      // program counter
                      N_PC = PC + 1;           
             end // end `i_type_arithm
             `i_type_dmem: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;  
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      = data_rs1_gpr;
                      rs2_alu      = {{20{`msb}},`imm_i};
                      // program counter
                      N_PC = PC + 1; 
                      // data ram 
                      addr_data = result_alu;
                      din_data  = {`INST_SIZE{1'b0}}; 
                      en_data   = 1'b1;
                      we_data   = 1'b0;
                      if(`func == 3'b000)
                        data_rd_gpr = {{25{dout_data[7]}},dout_data[6:0]};
                      else if (`func == 3'b001)
                        data_rd_gpr = {{17{dout_data[15]}},dout_data[14:0]}; 
                      else if (`func == 3'b010)
                        data_rd_gpr = dout_data; 
                      else if (`func == 3'b100)
                        data_rd_gpr = {{24{1'b0}},dout_data[7:0]};
                      else
                        data_rd_gpr = {{16{1'b0}},dout_data[15:0]};            
             end // end `i_type_dmem
             `s_type: begin
                      // gpr
                      we_gpr = 1'b0;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  data_rs1_gpr;
                      rs2_alu      =  {{20{`msb}},`imm_sl,`imm_sr};
                      // program counter
                      N_PC = PC + 1; 
                      // data ram
                      addr_data = result_alu;
                      en_data   = 1'b1;
                      we_data   = 1'b1; 
                      if(`func == 3'b000)
                        din_data  = {{24{1'b0}},data_rs2_gpr[7:0]}; 
                      else if(`func == 3'b001)
                        din_data  = {{16{1'b0}},data_rs2_gpr[15:0]};
                      else
                        din_data  = data_rs2_gpr;                         
             end // end `s_type
             `b_type: begin
                      // gpr
                      we_gpr = 1'b0;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  data_rs1_gpr;
                      rs2_alu      =  data_rs2_gpr; 
                      if(`func == 3'b000)   
                            if(flag_alu[2])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1; 
                      else if(`func == 3'b001)   
                            if(!flag_alu[2])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1; 
                      else if(`func == 3'b100)   
                            if(flag_alu[0])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1;
                     else if(`func == 3'b101)   
                            if(!flag_alu[0])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1;            
                    else if(`func == 3'b110)   
                            if(flag_alu[1])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1;
                     else if(`func == 3'b111)   
                            if(!flag_alu[1])
                                N_PC = PC + {{20{`msb}}, `b_bit, `imm_bl, `imm_br, 1'b0};
                            else
                                N_PC = PC + 1; 
                                        
             end // end `b_type
             `i_type_jalr: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  PC + 1;   
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  data_rs1_gpr;
                      rs2_alu      =  {{20{`msb}},`imm_i}; 
                      // program counter
                      N_PC = result_alu; 
             end // end `i_type_jalr
             `j_type: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  PC + 1;   
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  PC;
                      rs2_alu      =  {{12{`msb}}, `imm_jr, `l_bit, `imm_jl, 1'b0}; 
                      // program counter
                      N_PC = result_alu; 
             end // end `j_type
             `u_type_auipc: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  result_alu;   
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  PC;
                      rs2_alu      =  {`imm_u, {12{1'b0}}}; 
                      // program counter
                      N_PC = PC + 1; 
             end // end u_type_auipc
             `u_type_lui: begin
                      // gpr
                      we_gpr = 1'b1;
                      en_gpr = 1'b1;
                      addr_rs1_gpr = `rs1;
                      addr_rs2_gpr = `rs2;
                      addr_rd_gpr  = `rd;
                      data_rd_gpr  =  result_alu;   
                      // alu
                      funct3_alu   = `add;
                      rs1_alu      =  32'h00000000;
                      rs2_alu      =  {`imm_u, {12{1'b0}}}; 
                      // program counter
                      N_PC = PC + 1; 
             end // end u_type_auipc
             
             
        endcase
    end  // end always block
    
    // pc state machine
    always@(posedge clk or negedge rst) begin
        if(!rst)
            PC <= 0;
        else
            PC <= N_PC;   
    end
    
    // instruction fetch
    always @(*) begin 
       addr_inst = PC;
       IR = dout_inst;
    end
    
    
    // setting default inputs 
    task set_default(); begin
        // gpr
         we_gpr = 0;
         en_gpr = 0;
         addr_rs1_gpr = 5'b00000;
         addr_rs2_gpr = 5'b00000;
         addr_rd_gpr  = 5'b00000;
         data_rd_gpr  = 32'h00000000;
         rs1_alu      = 32'h00000000;
         rs2_alu      = 32'h00000000;
         
         //alu
         funct3_alu   = 4'b1111;
          
         //  data ram
         addr_data = {$clog2(`DATA_DEPTH){1'b0}};
         din_data  = {`DATA_SIZE{1'b0}}; 
         en_data   = 0;
         we_data   = 0;  
         
         // program counter
         N_PC = PC;
    end
    endtask
    
    
    
    

endmodule
