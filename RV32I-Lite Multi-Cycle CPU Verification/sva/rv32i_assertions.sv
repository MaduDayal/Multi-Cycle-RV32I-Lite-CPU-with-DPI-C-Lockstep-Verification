import rv32i_package::*;

module assertReset(
  input logic CLK, RESET,
  input cpuStage currentStage,
  input logic [31:0] PC,
  input logic retire_valid
);
  
  assert property(@(posedge CLK) RESET |=> currentStage == FETCH && PC == 32'b0 && !retire_valid);
  
endmodule
    
    
    
module assertResetsafety(input logic CLK, RESET, regWriteEn, memWriteEn, retire_valid);
  assert property(@(posedge CLK) RESET |=> (!regWriteEn && !memWriteEn && !retire_valid));      
      
endmodule
   
    
    
    
module assertAlignedPC(
  input logic CLK, RESET,
  input logic [31:0] PC
);
  assert property(@(posedge CLK) disable iff (RESET) PC[1:0] == 2'b00);
  
endmodule
    

module assertPCKnown(input logic CLK, RESET, input logic [31:0] PC);
  assert property(@(posedge CLK) !RESET |-> !$isunknown(PC));
endmodule

    
    
module assertBEQTargetValid(
  input logic CLK, RESET, retire_valid, regWrite, memWrite, address_range_error, alignment_error,
  input cpuStage state,
  input instruct_t InstructionType,
  input logic branchComparison,
  input logic [31:0] PC, branchTarget
);
  assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && InstructionType == INST_BEQ && branchComparison && branchTarget[1:0] == 2'b00 && branchTarget <= 8'd255 |=> PC == branchTarget && state == FETCH && retire_valid && !regWrite && !memWrite);
    
    assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && InstructionType == INST_BEQ && branchComparison && branchTarget[1:0] != 2'b00 && branchTarget < 32'd256 |=> state == HALT && alignment_error && !regWrite && !memWrite && !retire_valid);  
    
    assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && InstructionType == INST_BEQ && branchComparison && branchTarget > 8'd255 |=> state == HALT && address_range_error && !regWrite && !memWrite && !retire_valid);  
endmodule
    
    
module assertRegZero
(
  input logic CLK, RESET,
  input logic [31:0] regZero

);
  assert property(@(posedge CLK) disable iff (RESET) regZero == 32'b0);
      
endmodule
   
module assertRegZeroWrite(
  input logic CLK, writeEn,
  input logic [4:0] rd,
  input logic [31:0] regZeroValue
);
  assert property(@(posedge CLK) (rd == 5'b0 && writeEn) |=> regZeroValue == 32'b0);
      
endmodule
    
module assertRegWriteInfoKnown(
  input logic CLK, regWriteEn,
  input logic [4:0] destReg,
  input logic [31:0] writeData

);
  assert property(@(posedge CLK) regWriteEn |-> (!$isunknown(destReg) && !$isunknown(writeData)));
  
endmodule

    
module assertLegalState(
  input logic CLK, RESET,
  input cpuStage state
);
  
  assert property(@(posedge CLK) disable iff (RESET) (state == FETCH || state == DECODE || state == EXECUTE || state == MEMORY || state == WRITEBACK || state == HALT) && !$isunknown(state));
endmodule
    
module assertFetchToDecode
(
  input logic CLK, RESET,
  input cpuStage state
      
);
  assert property(@(posedge CLK) disable iff (RESET) state == FETCH |=> state == DECODE);
endmodule
    
module assertArithmeticToWriteback
(
  input logic CLK, RESET,
  input cpuStage state,
  input instruct_t InstructType    
);
  
  assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && (InstructType == INST_ADD || InstructType == INST_SUB || InstructType == INST_AND || InstructType == INST_OR || InstructType == INST_ADDI) |=> state == WRITEBACK);
endmodule
    
    
    
    
module assertSWnoWrite
(
  input logic CLK, retire_valid, retire_rd_write, retire_mem_write, 
  input logic [31:0] retire_instruct
);
  assert property(@(posedge CLK) retire_valid && retire_instruct[6:0] == 7'b0100011 && retire_instruct[14:12] == 3'b010 |-> !retire_rd_write && retire_mem_write);
      
endmodule
    
    
    
module illegalInstructHalt
(
  input logic CLK, RESET,
  input cpuStage state,
  input logic illegal_instruct, retire_valid, regWriteEn, memWriteEn, illegal_error
            
);
      
  assert property(@(posedge CLK) disable iff (RESET) state == DECODE && illegal_instruct |=> state == HALT && illegal_error);
  assert property(@(posedge CLK) disable iff (RESET) state == DECODE && illegal_instruct |-> !retire_valid && !regWriteEn && !memWriteEn);
endmodule
    
module memEffectsAlignedAddr
(
  input logic CLK, RESET, memWriteEn,
  input cpuStage state,
  input logic [31:0] memAddr, memWriteData,
  input instruct_t InstructionType,
  input logic alignmentError, address_range_error
);
  assert property(@(posedge CLK) disable iff (RESET) memWriteEn |-> state == MEMORY && InstructionType == INST_SW && memAddr[1:0] == 2'b00 && memAddr <= 8'd255 && !alignmentError && !address_range_error && !$isunknown(memAddr) && !$isunknown(memWriteData));
endmodule
    
    
    
module assertMisalignedMemoryHalt
  (
    input logic CLK, RESET,
    input cpuStage state,
    input instruct_t instruct,
    input logic [31:0] aluResult,
    input logic alignmentError, retire_valid, memWriteEn, regWriteEn
  );
  assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && (instruct == INST_LW || instruct == INST_SW) && aluResult[1:0] != 2'b00 && aluResult < 32'd256 |=> state == HALT && alignmentError && !retire_valid && !memWriteEn && !regWriteEn);
endmodule
    
    
module assertOutOfRangeMemoryHalt
(
  input logic CLK, RESET, address_range_error, retire_valid,
  input cpuStage state,
  input instruct_t instruct,
  input logic [31:0] aluResult,
  input logic memWriteEn, regWriteEn
);
  assert property(@(posedge CLK) disable iff (RESET) state == EXECUTE && (instruct == INST_LW || instruct == INST_SW) && aluResult > 8'd255 |=> state == HALT && address_range_error && !retire_valid && !memWriteEn && !regWriteEn);
endmodule
    
    
module assertHaltPersistence
(
  input logic CLK, RESET,
  input cpuStage state
);
  
  assert property(@(posedge CLK) disable iff (RESET) state == HALT |=> state == HALT);
endmodule
    
    
module assertHaltNoEffects
(
  input logic CLK, RESET, retire_valid, memWriteEn, regWriteEn,
  input cpuStage state
);
  
  assert property(@(posedge CLK) disable iff (RESET) state == HALT |-> !retire_valid && !memWriteEn && !regWriteEn);
endmodule
    
module assertRetirementInfoKnown
(
  input logic CLK, RESET, retire_valid, retire_memWriteEn, retire_regWriteEn,
  input logic [31:0] retire_PC, retire_instruct
);
  
  assert property(@(posedge CLK) disable iff (RESET) retire_valid |-> !$isunknown(retire_PC) && !$isunknown(retire_instruct) && !$isunknown(retire_memWriteEn) && !$isunknown(retire_regWriteEn));
endmodule    
    
    
    
    