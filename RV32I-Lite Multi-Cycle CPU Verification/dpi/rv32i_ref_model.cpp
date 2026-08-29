#include "svdpi.h"
#include <cstdint>
#include <iostream>

static uint32_t ref_registers[32];
static uint32_t ref_data_memory[64];
static uint32_t expectedPC;

static uint32_t instruction_count;

extern "C" void reset() {
  
 expectedPC = 0;
 instruction_count = 0;
 
 for(int i = 0; i < 64; i++) {
   	ref_data_memory[i] = 0;
 }
  
 for(int i = 0; i < 32; i++) {
 	ref_registers[i] = 0;
 }
  
  
  	
 std::cout << "Reference Model Resetted." << std::endl; 
}
  
  
extern "C" int instructionCount() {
 return instruction_count;  
}
  
  
extern "C" int processInstruct(uint32_t retiredPC, uint32_t raw_instruction, uint32_t* expRegWriteFlag, uint32_t* expDestReg, uint32_t* expRegValue, uint32_t* expMemWriteFlag, uint32_t* expMemAddr,  uint32_t* expMemData) {
  *expRegWriteFlag = 0;
  *expDestReg = 0;
  *expRegValue = 0;
  
  *expMemWriteFlag = 0;
  *expMemAddr = 0;
  *expMemData = 0;
  
  if(retiredPC != expectedPC) {
  	return 1;
  }
  
  
  int opcode = raw_instruction & ((1 << 7) - 1);
  int rd = (raw_instruction >> 7) & ((1 << 5) - 1);
  int funct3 = (raw_instruction >> 12) & 7;
  int rs1 = (raw_instruction >> 15) & 31;
  int rs2 = (raw_instruction >> 20) & 31;
  int funct7 = (raw_instruction >> 25) & ((1 << 7) - 1);
  
  if(opcode == 51 && funct3 == 0 && funct7 == 0) { // ADD
  	uint32_t result = ref_registers[rs1] + ref_registers[rs2];  
    *expRegWriteFlag = (rd != 0) ? 1 : 0;
    *expDestReg = rd;
    *expMemWriteFlag = false;
    *expRegValue = result;
    
    
    if(rd != 0) {
      ref_registers[rd] = *expRegValue;
      
    }
    expectedPC += 4;
  }
  else if(opcode == 51 && funct3 == 0 && funct7 == 32) { // SUB
  	uint32_t result = ref_registers[rs1] - ref_registers[rs2];
    *expRegWriteFlag = (rd != 0) ? 1 : 0;
    *expDestReg = rd;
    *expMemWriteFlag = false;
    *expRegValue = result;
    
    if(rd != 0) {
      ref_registers[rd] = *expRegValue;
       
    }
    expectedPC += 4; 
  }
  else if(opcode == 51 && funct3 == 7 && funct7 == 0) { // AND
  	uint32_t result = ref_registers[rs1] & ref_registers[rs2];
    
    *expRegWriteFlag = (rd != 0) ? 1 : 0;
    *expDestReg = rd;
    *expMemWriteFlag = false;
    *expRegValue = result;
    
    if(rd != 0) {
      ref_registers[rd] = *expRegValue;
       
    }
    expectedPC += 4; 
  }
  else if(opcode == 51 && funct3 == 6 && funct7 == 0) {  // OR
  	uint32_t result = ref_registers[rs1] | ref_registers[rs2];
    
    *expRegWriteFlag = (rd != 0) ? 1 : 0;
    *expDestReg = rd;
    *expMemWriteFlag = false;
    *expRegValue = result;
    
    if(rd != 0) {
      ref_registers[rd] = *expRegValue;
    }
    expectedPC += 4;
  }
  else if(opcode == 19 && funct3 == 0) { // ADDI
    uint32_t immediate = (uint32_t) raw_instruction >> 20;
    int32_t finalImm = ((int32_t)(immediate << 20)) >> 20;
    
    uint32_t result = ref_registers[rs1] + finalImm;
    
    *expRegWriteFlag = (rd != 0) ? 1 : 0;
    *expDestReg = rd;
    *expMemWriteFlag = false;
    *expRegValue = result;
    
    if(rd != 0) {
      ref_registers[rd] = result;  
    }
    
    expectedPC += 4;
  }
  else if(opcode == 3 && funct3 == 2) { // LW
  	uint32_t immediate = (uint32_t) raw_instruction >> 20;
    int32_t finalImm = ((int32_t)(immediate << 20)) >> 20;
    uint32_t loadValue;
    uint32_t memAddress = ref_registers[rs1] + finalImm;
    
    
       
    if(memAddress < 256 && memAddress % 4 == 0) {
      loadValue = ref_data_memory[memAddress / 4];
      *expRegWriteFlag = (rd != 0) ? 1 : 0;
      *expDestReg = rd;
      *expMemWriteFlag = false;
      *expRegValue = loadValue;
      *expMemAddr = memAddress;
    }
    else {
      return 3;  
    }
    
    if(rd != 0) {
      ref_registers[rd] = loadValue;  
    }
    
    expectedPC += 4;
  }
  else if(opcode == 35 && funct3 == 2) { // SW
  	uint32_t memWriteValue = ref_registers[rs2];
    uint32_t immediate = (((raw_instruction >> 25) & ((1 << 7) - 1)) << 5) | ((raw_instruction >> 7) & 31);
    int32_t finalImm = ((int32_t)(immediate << 20)) >> 20;
    uint32_t memAddress = ref_registers[rs1] + finalImm;
    
        
    if(memAddress >= 256 || !(memAddress % 4 == 0)) {
      return 3;  
    }
    else {
      *expMemWriteFlag = 1;
      *expMemAddr = memAddress;
      *expMemData = memWriteValue;
      
      ref_data_memory[memAddress / 4] = memWriteValue;
      expectedPC += 4;
    }
    
    
  }
  else if(opcode == 99 && funct3 == 0) { // BEQ
    uint32_t immediate = 0;
    immediate |= ((raw_instruction >> 31) & 0x1) << 12;
	immediate |= ((raw_instruction >> 7) & 0x1) << 11;
	immediate |= ((raw_instruction >> 25) & 0x3F) << 5;
	immediate |= ((raw_instruction >> 8) & 0xF) << 1;
    
    int32_t finalImm = ((int32_t)(immediate << 19)) >> 19;
    //*expMemWriteFlag = false;
    //*expRegWriteFlag = false;
    
    if(ref_registers[rs1] == ref_registers[rs2]) {
      expectedPC += finalImm;  
    }
    else {
      expectedPC += 4;  
    }
  }
  else {
  	return 2;  
  }
  
  instruction_count++;
  ref_registers[0] = 0;
  
  return 0;
}



