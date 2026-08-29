
package instruction_generator_package;
  import rv32i_package::*;
  
  
  function logic [31:0] encode_r(logic [4:0] rs1, logic [4:0] rs2, logic [4:0] rd, ALU_OP opType);
    logic [31:0] instruct = '0;
  
    instruct[24:20] = rs2;
    instruct[19:15] = rs1;
    instruct[11:7] = rd;
    
    case(opType)
      ADD: begin
        instruct[6:0] = 7'b0110011;
        instruct[14:12] = 3'b0;
        instruct[31:25] = 7'b0;
      end
      SUB: begin
        instruct[6:0] = 7'b0110011;
        instruct[14:12] = 3'b0;
        instruct[31:25] = 7'b0100000;
      end
      AND: begin
        instruct[6:0] = 7'b0110011;
        instruct[14:12] = 3'b111;
        instruct[31:25] = 7'b0;
      end
      OR: begin
        instruct[6:0] = 7'b0110011;
        instruct[14:12] = 3'b110;
        instruct[31:25] = 7'b0;
      end
        
    endcase
  
    return instruct;
  endfunction
  
  function logic [31:0] encode_i(logic [4:0] rs1, logic [4:0] rd, logic [11:0] immediate, instruct_t instructionType);
    logic [31:0] instruct = '0;
    instruct[19:15] = rs1;
    instruct[11:7] = rd;
    instruct[31:20] = immediate;
    
    case(instructionType)
      INST_ADDI: begin
        instruct[6:0] = 7'b0010011;
        instruct[14:12] = 3'b0;
      end
      INST_LW: begin
        instruct[6:0] = 7'b0000011;
        instruct[14:12] = 3'b010;
      end
    endcase
    
    return instruct;
  endfunction
  
  function logic [31:0] encode_s(logic [4:0] rs1, logic [4:0] rs2, logic [11:0] immediate);
  	logic [31:0] instruct = '0;
    
    instruct[6:0] = 7'b0100011;
    instruct[31:25] = immediate[11:5];
    instruct[24:20] = rs2;
    instruct[19:15] = rs1;
    instruct[14:12] = 3'b010;
    instruct[11:7] = immediate[4:0];
    
    return instruct;
  endfunction
  
  function logic [31:0] encode_b(logic [4:0] rs1, logic [4:0] rs2, logic [12:0] immediate);
    logic [31:0] instruct = '0;
    
    instruct[31] = immediate[12];
    instruct[30:25] = immediate[10:5];
    instruct[24:20]  = rs2;
    instruct[19:15] = rs1;
    instruct[14:12] = 3'b0;
    instruct[11:8] = immediate[4:1];
    instruct[7] = immediate[11];
    instruct[6:0] = 7'b1100011;
    
    return instruct;
  endfunction
  
endpackage










