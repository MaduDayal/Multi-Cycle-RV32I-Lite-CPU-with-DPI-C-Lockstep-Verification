/*
import rv32i_package::*;


bind rv32i_lite_code assertReset cpuStateResetAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .currentStage(state), .PC(PC), .retire_valid());


bind rv32i_lite_code assertResetsafety rWResetSafety(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .regWriteEn(saved_reg_write), .memWriteEn(saved_mem_write), .retire_valid());


bind rv32i_lite_code assertAlignedPC cpuStateResetAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .currentStage(state), .PC(PC), .retire_valid());


bind rv32i_lite_code assertPCKnown pcAlignAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .PC(PC));


bind rv32i_lite_code assertBEQTargetValid beqTargetAddrValid(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .retire_valid(), .regWrite(saved_reg_write));


bind rv32i_lite_code assertRegZero cpuStateResetAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .currentStage(state), .PC(PC), .retire_valid(), .memWriteEn(saved_mem_write), .address_range_error(), .alignment_error(), .state(state), .InstructionType(inType), .branchComparison(branch), .PC(PC), .branchTarget(branch_target));



bind rv32i_lite_code assertRegZeroWrite cpuStateResetAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .regZero());


bind rv32i_lite_code assertRegWriteInfoKnown destInfoKnown(.CLK(dutMp.CLK), .regWriteEn(dutMp.RESET), .destReg(resultReg), .writeData(memDataWrite));


bind rv32i_lite_code assertLegalState validStateAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state));


bind rv32i_lite_code assertFetchToDecode fetchToDecodeAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state));


bind rv32i_lite_code assertArithmeticToWriteback nextStateWritebackAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state), .InstructionType(inType));


bind rv32i_lite_code assertSWnoWrite swNoWriteAssert(.CLK(dutMp.CLK), .retire_valid(), .retire_rd_write(), .retire_mem_write(), .retire_instruct());


bind rv32i_lite_code illegalInstructHalt illegalInstructToHalt(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state), .illegal_instruct(illegal_instruct), .retire_valid(), .regWriteEn(saved_reg_write), .memWriteEn(saved_mem_write), .illegal_error());


bind rv32i_lite_code memEffectsAlignedAddr properMisalignedAddrAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .memWriteEn(saved_mem_write), .state(state), .memAddr(memAddr), .memWriteData(memDataWrite), .InstructionType(inType), .alignmentError(), .address_range_error());


bind rv32i_lite_code assertMisalignedMemoryHalt haltMemMisalignedAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state), .instruct(inType), .aluResult(aluResult), .alignmentError(), .retire_valid(), .memWriteEn(saved_mem_write), .regWriteEn(saved_reg_write));


bind rv32i_lite_code assertOutOfRangeMemoryHalt haltIfAddrRangeErrorAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .address_range_error(), .retire_valid(), .state(), .instruct(), .aluResult(), .memWriteEn(saved_mem_write), .regWriteEn(saved_reg_write));


bind rv32i_lite_code assertHaltPersistence keepHaltAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .state(state));


bind rv32i_lite_code assertHaltNoEffects haltConsistentAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .retire_valid(), .memWriteEn(saved_mem_write), .regWriteEn(saved_reg_write), .state(state));


bind rv32i_lite_code assertRetirementInfoKnown resetRetirementKnownAssert(.CLK(dutMp.CLK), .RESET(dutMp.RESET), .retire_valid(), retire_memWriteEn(), retire_regWriteEn(), retire_PC(), retire_instruct());

*/












