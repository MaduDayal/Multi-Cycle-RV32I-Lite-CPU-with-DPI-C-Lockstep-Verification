import rv32i_package::*;


module rv32i_lite_core(
  riscvInf.DUTmp dutMp
);
  // OUTPUTS
  logic [31:0] rs1Value, rs2Value, instruct, memDataRead, immediate, aluResult, alu_result_reg, op1_reg, op2_reg, branch_target;
  logic use_immediate, reg_write, mem_read, mem_write, writeback_from_memory, branch, illegal_instruct, equal;
  instruct_t inType;
  ALU_OP aluOp;
  immType immediateType;
  
  
  // INPUTS
  logic [4:0] rs1Reg, rs2Reg, resultReg;
  logic [31:0] resultValue, currentPC, PC, memAddr, memDataWrite;
  logic [31:0] aluOp1, aluOp2;
  
  // SIGNALS NOT CONTROLLED BY MODULES: aluOp1, aluOp2, resultValue, PC, memDataWrite, state, rs1Reg, rs2Reg, resultReg, memAddr
  
  cpuStage state;
  
  
  
  instruct_t saved_inType;
  ALU_OP saved_aluOp;
  logic saved_reg_write;
  logic saved_mem_read;
  logic saved_mem_write;
  logic saved_writeback_from_memory;
  logic saved_use_immediate;
  logic [31:0] saved_immediate_value, instruction_reg, load_data_reg;
  
  
  instruction_memory instructFile(.address(PC), .RESET(dutMp.RESET), .instruct(instruct));
  
  rv32i_decoder decode(.instruct(instruction_reg), .inType(inType), .aluOp(aluOp), .immediateType(immediateType), .use_immediate(use_immediate), .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write), .writeback_from_memory(writeback_from_memory), .branch(branch), .illegal_instruct(illegal_instruct));
  
  rv32i_regfile registers(.rs1(rs1Reg), .rs2(rs2Reg), .rd(resultReg), .CLK(dutMp.CLK), .rd_write(state == WRITEBACK && saved_reg_write), .RESET(dutMp.RESET), .rdValue(resultValue), .rs1Value(rs1Value), .rs2Value(rs2Value));
  
  rv32i_imm_gen immediateGenerator(.instruct(instruction_reg), .imInput(immediateType), .immediate(immediate));
  
  rv32i_alu ALU(.op1(aluOp1), .op2(aluOp2), .opCode(saved_aluOp), .res(aluResult), .equal(equal));
  
  data_memory Memory(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .addr(memAddr), .write_data(memDataWrite), .mem_read(state == MEMORY && saved_mem_read), .mem_write(state == MEMORY && saved_mem_write), .read_data(memDataRead));
  
  
  always_ff @(posedge dutMp.CLK) begin
    dutMp.retire_valid <= 1'b0;
    dutMp.retire_rd_write <= 1'b0;
    dutMp.retire_mem_write <= 1'b0;
    
    dutMp.retire_pc <= '0;
    dutMp.retire_instr <= '0;
    dutMp.retire_rd_value <= '0;
    dutMp.retire_mem_addr <= '0;
    dutMp.retire_mem_wdata <= '0;
    dutMp.retire_rd <= '0;
    
    
    
    if(dutMp.RESET) begin
      dutMp.illegal_error <= 1'b0;
      dutMp.alignment_error <= 1'b0;
      dutMp.address_range_error <= 1'b0;
      
      PC <= '0;
      state <= FETCH;
      load_data_reg <= '0;
      
      
      alu_result_reg <= '0;
      op1_reg <= '0;
      op2_reg <= '0;
      saved_use_immediate <= 1'b0;
      
      currentPC <= '0;
      instruction_reg <= '0;
      saved_inType <= INST_ILLEGAL;
      saved_aluOp <= ADD;
      saved_reg_write <= 1'b0;
      saved_mem_read <= 1'b0;
      saved_mem_write <= 1'b0;
      saved_writeback_from_memory <= 1'b0;
      saved_immediate_value <= '0;
    end
    else begin
      case(state)
        FETCH: begin
          instruction_reg <= instruct;
          currentPC <= PC;
          PC <= PC + 32'd4;
          state <= DECODE;
        end
        DECODE: begin
          // rs1Reg <= instruct[19:15];
          // rs2Reg <= instruct[24:20];
          // resultReg <= instruct[11:7];
		  saved_use_immediate <= use_immediate;
          
          //aluOp1 <= op1_reg;

          //if(saved_use_immediate) aluOp2 <= saved_immediate_value;
          //else aluOp2 <= op2_reg;
          
          op1_reg <= rs1Value;
          op2_reg <= rs2Value;
          
          saved_immediate_value <= immediate;
          saved_inType <= inType;
          saved_aluOp <= aluOp;
          saved_reg_write <= reg_write;
          saved_mem_read <= mem_read;
          saved_mem_write <= mem_write;
          saved_writeback_from_memory <= writeback_from_memory;
          
          
          if(illegal_instruct) begin
            state <= HALT;
            dutMp.retire_mem_write <= 1'b0;
            dutMp.retire_valid <= 1'b0;
            dutMp.retire_rd_write <= 1'b0;
            
            // dutMp.halted <= state == HALT;
            dutMp.illegal_error <= 1'b1;
            // dutMp.alignment_error <= aluResult[1:0] != 2'b00;
          end
          else state <= EXECUTE;
        end
        EXECUTE: begin
                    
          alu_result_reg <= aluResult;

          if(saved_inType == INST_LW || saved_inType == INST_SW) begin
            if(aluResult >= 32'd256) begin
              dutMp.address_range_error <= 1'b1;
              state <= HALT;
            end
            else if(aluResult[1:0] == 2'b00) state <= MEMORY;
            else if(aluResult[1:0] != 2'b00) begin
              dutMp.alignment_error <= 1'b1;
              state <= HALT;
            end
            else state <= HALT;
          end
          else if(saved_inType == INST_BEQ) begin
            if(!equal) begin
              state <= FETCH;
              dutMp.retire_valid <= 1'b1;
          	  dutMp.retire_pc <= currentPC;
          	  dutMp.retire_instr <= instruction_reg;
          	  dutMp.retire_rd_write <= 1'b0;
              dutMp.retire_mem_write <= 1'b0;
            end
            else begin
              if(branch_target >= 32'd256) begin
                state <= HALT;
                dutMp.address_range_error <= 1'b1;
              end
              else if(branch_target[1:0] != 2'b00) begin
                state <= HALT;
                dutMp.alignment_error <= 1'b1;
              end
              else begin
                PC <= branch_target;
                dutMp.retire_valid <= 1'b1;
          		dutMp.retire_pc <= currentPC;
          		dutMp.retire_instr <= instruction_reg;
          		dutMp.retire_rd_write <= 1'b0;
            	dutMp.retire_mem_write <= 1'b0;
                state <= FETCH;
              end
            end
            
            
          end
          else state <= WRITEBACK;
          
          
        end
        MEMORY: begin
          //memAddr <= alu_result_reg;
          if(saved_inType == INST_LW) begin
            load_data_reg <= memDataRead;
            state <= WRITEBACK;
          end
          else if(saved_inType == INST_SW) begin
            dutMp.retire_instr <= instruction_reg;
            dutMp.retire_pc <= currentPC;
            dutMp.retire_valid <= 1'b1;
            
            dutMp.retire_rd_write <= 1'b0;
            dutMp.retire_mem_write <= 1'b1;
            dutMp.retire_mem_addr <= alu_result_reg;
            dutMp.retire_mem_wdata <= op2_reg;
            state <= FETCH;
          end
          else state <= HALT;
          
        end
        WRITEBACK: begin
          // if(saved_inType == INST_LW) resultValue <= memDataRead;
          // else if(saved_inType == INST_SW && saved_writeback_from_memory) begin end
          // else resultValue <= aluResult;
          if(saved_inType == INST_ADD || saved_inType == INST_SUB || saved_inType == INST_AND || saved_inType == INST_OR || saved_inType == INST_ADDI || saved_inType == INST_LW) begin
            dutMp.retire_instr <= instruction_reg;
            dutMp.retire_pc <= currentPC;
            dutMp.retire_valid <= 1'b1;
            
            dutMp.retire_rd_write <= resultReg != '0 && saved_reg_write;
            dutMp.retire_rd <= resultReg;
            // dutMp.retire_rd_value <= alu_result_reg;
            dutMp.retire_rd_value <= resultValue;
            
            dutMp.retire_mem_write <= 1'b0;
          end
          state <= FETCH;
        end
        HALT: state <= HALT;
        default: state <= HALT;
      endcase
    end  
        
  end
  
  always_comb begin
    if(dutMp.RESET) begin
      rs1Reg = '0;
      rs2Reg = '0;
      resultReg = '0;
      aluOp1 = '0;
      aluOp2 = '0;
      memAddr = '0;
	  memDataWrite = '0;
      resultValue = '0;
    end
    else begin
      rs1Reg = instruction_reg[19:15];
      rs2Reg = instruction_reg[24:20];
      resultReg = instruction_reg[11:7];
      
      aluOp1 = op1_reg;

      if(saved_use_immediate) aluOp2 = saved_immediate_value;
      else aluOp2 = op2_reg;
      
      memAddr = alu_result_reg;
      memDataWrite = op2_reg;
      
      // if(saved_inType == INST_SW && saved_writeback_from_memory) memDataWrite = op2_reg;
      
      if(saved_writeback_from_memory) resultValue = load_data_reg;
      else resultValue = alu_result_reg;
                
    end
    
    dutMp.halted = !dutMp.RESET && (state == HALT);
    branch_target = currentPC + saved_immediate_value;
  end
  
endmodule




