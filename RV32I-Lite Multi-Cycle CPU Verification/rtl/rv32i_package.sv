
package rv32i_package;
  typedef enum logic [1:0] {I_imm, S_imm, B_imm, NONE_imm} immType;
  typedef enum logic [1:0] {ADD, SUB, AND, OR} ALU_OP;
  typedef enum logic [3:0] {INST_ADD, INST_SUB, INST_AND, INST_OR, INST_ADDI, INST_LW, INST_SW, INST_BEQ, INST_ILLEGAL} instruct_t;

  typedef enum logic [2:0] {FETCH, DECODE, EXECUTE, MEMORY, WRITEBACK, HALT} cpuStage;

  
endpackage













