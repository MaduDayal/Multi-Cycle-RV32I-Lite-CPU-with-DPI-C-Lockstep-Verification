
import rv32i_package::*;
import rv32i_dpi_package::*;

module tb;
  
  logic CLK, RESET;
  rv32i_env rEnv;
  rv32i_program_builder rBuilder;
  
  mailbox #(retire_transaction) monToSb = new();
  mailbox #(retire_transaction) monToCov = new();
  
  initial begin
    CLK = 1'b0;
    RESET = 1'b1;
    
    
  end
  
  always #5ns CLK = ~CLK;
  riscvInf rInf(.CLK(CLK), .RESET(RESET));
  rv32i_lite_core DUT(rInf.DUTmp);
  
  initial begin
    rEnv = new(monToSb, rInf.retireMonitor, monToCov);
    rBuilder = new();
            
    repeat(5) @(negedge CLK);
    rBuilder.mixedInstructionPrograms(); 
    // CHANGE rBuilder method to any test from rv32i_program_builder.sv
    
    for(int i = 0; i < rBuilder.num_words; i++) begin
      DUT.instructFile.instructMem[i] = rBuilder.Program[i];  
    end
        
    reset();
    rEnv.run();
        
    RESET = 1'b0;
    
    wait(rInf.halted == 1'b1);
    wait(rEnv.rSb.total_instructions == rBuilder.num_legal_retire);
    
    rEnv.rSb.summary();
    rEnv.rCov.coverageSummary();
    $finish;
  end
  
  initial begin
    #5000ns;
    $fatal(1, "TIMEOUT: CPU or verification environment did not complete.");
  end
  
  assertReset cpuStateResetAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .currentStage(DUT.state), .PC(DUT.PC), .retire_valid(rInf.retire_valid));


  assertResetsafety rWResetSafety(.CLK(rInf.CLK), .RESET(rInf.RESET), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .retire_valid(rInf.retire_valid));


  assertAlignedPC pcAlignedAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .PC(DUT.PC));


  assertPCKnown pcKnownResetAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .PC(DUT.PC));


  assertBEQTargetValid beqTargetAddrValid(.CLK(rInf.CLK), .RESET(rInf.RESET), .retire_valid(rInf.retire_valid), .regWrite(DUT.saved_reg_write), .memWrite(DUT.saved_mem_write), .address_range_error(rInf.address_range_error), .alignment_error(rInf.alignment_error), .state(DUT.state), .InstructionType(DUT.saved_inType), .branchComparison(DUT.equal), .PC(DUT.PC), .branchTarget(DUT.branch_target));


  assertRegZero regZeroisZeroAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .regZero(DUT.registers.regValues[0]));



  assertRegZeroWrite assertRegAtZeroisZero(.CLK(rInf.CLK), .writeEn(DUT.saved_reg_write), .rd(DUT.resultReg), .regZeroValue(DUT.registers.regValues[0]));


  assertRegWriteInfoKnown destInfoKnown(.CLK(rInf.CLK), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write), .destReg(DUT.resultReg), .writeData(DUT.resultValue));


  assertLegalState validStateAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state));


  assertFetchToDecode fetchToDecodeAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state));


  assertArithmeticToWriteback nextStateWritebackAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state), .InstructType(DUT.saved_inType));


  assertSWnoWrite swNoWriteAssert(.CLK(rInf.CLK), .retire_valid(rInf.retire_valid), .retire_rd_write(rInf.retire_rd_write), .retire_mem_write(rInf.retire_mem_write), .retire_instruct(rInf.retire_instr));


  illegalInstructHalt illegalInstructToHalt(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state), .illegal_instruct(DUT.illegal_instruct), .retire_valid(rInf.retire_valid), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .illegal_error(rInf.illegal_error));


  memEffectsAlignedAddr properMisalignedAddrAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .state(DUT.state), .memAddr(DUT.memAddr), .memWriteData(DUT.memDataWrite), .InstructionType(DUT.saved_inType), .alignmentError(rInf.alignment_error), .address_range_error(rInf.address_range_error));


  assertMisalignedMemoryHalt haltMemMisalignedAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state), .instruct(DUT.saved_inType), .aluResult(DUT.aluResult), .alignmentError(rInf.alignment_error), .retire_valid(rInf.retire_valid), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write));


  assertOutOfRangeMemoryHalt haltIfAddrRangeErrorAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .address_range_error(rInf.address_range_error), .retire_valid(rInf.retire_valid), .state(DUT.state), .instruct(DUT.saved_inType), .aluResult(DUT.aluResult), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write));


  assertHaltPersistence keepHaltAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .state(DUT.state));


  assertHaltNoEffects haltConsistentAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .retire_valid(rInf.retire_valid), .memWriteEn(DUT.state == MEMORY && DUT.saved_mem_write), .regWriteEn(DUT.state == WRITEBACK && DUT.saved_reg_write), .state(DUT.state));


  assertRetirementInfoKnown resetRetirementKnownAssert(.CLK(rInf.CLK), .RESET(rInf.RESET), .retire_valid(rInf.retire_valid), .retire_memWriteEn(rInf.retire_mem_write), .retire_regWriteEn(rInf.retire_rd_write), .retire_PC(rInf.retire_pc), .retire_instruct(rInf.retire_instr));
  
  
endmodule





