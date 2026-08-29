import rv32i_package::*;

module rv32i_decoder(
  input logic [31:0] instruct,
  output instruct_t inType,
  output ALU_OP aluOp,
  output immType immediateType,
  output logic use_immediate, reg_write, mem_read, mem_write, writeback_from_memory, branch, illegal_instruct
);
  
  
  always_comb begin
    inType = INST_ILLEGAL;
    aluOp = ADD;
    immediateType = NONE_imm;
    use_immediate = 1'b0;
    reg_write = 1'b0;
    mem_read = 1'b0;
    mem_write = 1'b0;
    writeback_from_memory = 1'b0;
    branch = 1'b0;
    illegal_instruct = 1'b1;
          
    case(instruct[6:0])
      7'b0110011: begin
        if(instruct[14:12] == 3'b0 && instruct[31:25] == 7'b0) begin
          inType = INST_ADD; 
          aluOp = ADD;
          reg_write = 1'b1;
          illegal_instruct = 1'b0;
        end
        else if(instruct[14:12] == 3'b0 && instruct[31:25] == 7'b0100000) begin
          inType = INST_SUB; 
          aluOp = SUB;
          reg_write = 1'b1;
          illegal_instruct = 1'b0;
        end
        else if(instruct[14:12] == 3'b111 && instruct[31:25] == 7'b0) begin 
          inType = INST_AND;
          aluOp = AND;
          reg_write = 1'b1;
          illegal_instruct = 1'b0;
        end
        else if(instruct[14:12] == 3'b110 && instruct[31:25] == 7'b0) begin 
          inType = INST_OR; 
          aluOp = OR;
          reg_write = 1'b1;
          illegal_instruct = 1'b0;
        end
        else inType = INST_ILLEGAL;
        
        
      end
      7'b0010011: begin
        if(instruct[14:12] == 3'b0) begin
          immediateType = I_imm;
          inType = INST_ADDI;
          aluOp = ADD;
          use_immediate = 1'b1;
          reg_write = 1'b1;
          illegal_instruct = 1'b0;
        end
        else inType = INST_ILLEGAL;
      end
      7'b0000011: begin
        if(instruct[14:12] == 3'b010) begin
          immediateType = I_imm;
          inType = INST_LW;
          mem_read = 1'b1;
          reg_write = 1'b1;
          aluOp = ADD;
          illegal_instruct = 1'b0;
          writeback_from_memory = 1'b1;
          use_immediate = 1'b1;
        end
        else inType = INST_ILLEGAL;
      end
      7'b0100011: begin
        if(instruct[14:12] == 3'b010) begin
          immediateType = S_imm;
          inType = INST_SW;
          mem_write = 1'b1;
          use_immediate = 1'b1;
          illegal_instruct = 1'b0;
          aluOp = ADD;
        end
        else inType = INST_ILLEGAL;
      end
      7'b1100011: begin
        if(instruct[14:12] == 3'b0) begin
          immediateType = B_imm;
          inType = INST_BEQ;
          branch = 1'b1;
          use_immediate = 1'b0;
          illegal_instruct = 1'b0;
        end
        else inType = INST_ILLEGAL;
      end
      default: begin
        inType = INST_ILLEGAL;
      	immediateType = NONE_imm;
      end
    endcase
    
  end
    
  
  
endmodule

/*
instruct types

INST_ADD
INST_SUB
INST_AND
INST_OR
INST_ADDI
INST_LW
INST_SW
INST_BEQ
INST_ILLEGAL
*/


/*
ALU OPERATIONS


ALU_ADD
ALU_SUB
ALU_AND
ALU_OR
*/

/*
funct3 = instruction[14:12]
funct7 = instruction[31:25]
*/



