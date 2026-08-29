import instruction_generator_package::*;

class rv32i_program_builder;
  logic [31:0] Program [0:63];
  int num_words;
  int num_legal_retire;
  int instructIndex;
  logic cpuHalt; // illegal_instruct, address_range_error, alignment_error
  
  function new();
    this.Program = '{default: 0};
    this.num_words = 0;
    this.num_legal_retire = 0;
    this.cpuHalt = 1'b0;
    
    this.instructIndex = 0;
  endfunction
  
  function void clear();
    this.Program = '{default: 0};
    this.num_words = 0;
    this.num_legal_retire = 0;
    this.cpuHalt = 1'b0;
    this.instructIndex = 0;
  endfunction
  
  function void addLegalInstruction(logic [31:0] instruct);
    Program[instructIndex] = instruct;
    
    instructIndex++;
    num_words++;
    num_legal_retire++;
  endfunction
  
  function void addFaultInstruction(logic [31:0] instruct);
    Program[instructIndex] = instruct;
    
    instructIndex++;
    num_words++;
  endfunction
  
  function void addSkippedInstruction(logic [31:0] instruct);
    Program[this.instructIndex] = instruct;
    this.instructIndex++;
    this.num_words++;
  endfunction
  
  function void build_alu_test();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd10, INST_ADDI));
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd3, INST_ADDI));
    
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd3, ADD));
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd4, SUB));
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd5, AND));
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd6, OR));
    addFaultInstruction(32'b0);
  endfunction
  
  function void immediateSignExtTest();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd0, INST_ADDI));
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd5, INST_ADDI));
    addLegalInstruction(encode_i(5'd2, 5'd3, -3, INST_ADDI));
    addLegalInstruction(encode_i(5'd0, 5'd4, 12'd2047, INST_ADDI));
    addLegalInstruction(encode_i(5'd2, 5'd5, -2048, INST_ADDI));
    addFaultInstruction(32'b0);
  endfunction
  
  function void loadStoreTest();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd10, INST_ADDI)); // 1: 10
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd3, INST_ADDI)); // 2: 3
    
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd3, ADD)); // 3: 13
    addLegalInstruction(encode_s(5'd1, 5'd3, 5'd10)); // DATA - 20: 13
    addLegalInstruction(encode_i(5'd0, 5'd5, 12'd20, INST_LW)); // Reg - 5: 13
    
    addFaultInstruction(32'b0);
  endfunction
  
  function void beqTakenTest();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd9, INST_ADDI)); // 1: 9
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd9, INST_ADDI)); // 2: 9
    addLegalInstruction(encode_b(5'd1, 5'd2, 12'd8));
    addSkippedInstruction(encode_r(5'd1, 5'd2, 5'd3, ADD));
    addLegalInstruction(encode_i(5'd1, 5'd16, 12'd5, INST_ADDI));
        
    addFaultInstruction(32'b0);
  endfunction
  
  function void beqNotTakenTest();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd9, INST_ADDI)); // 1: 9
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd9, INST_ADDI)); // 2: 9
    addLegalInstruction(encode_b(5'd1, 5'd0, 12'd8));
    addLegalInstruction(encode_r(5'd1, 5'd2, 5'd3, ADD));
    addLegalInstruction(encode_i(5'd1, 5'd16, 12'd5, INST_ADDI));
        
    addFaultInstruction(32'b0);
  endfunction
  
  
  function void RegZeroIllegalInstruct();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd3, INST_ADDI));
    addLegalInstruction(encode_i(5'd1, 5'd0, 12'd9, INST_ADDI));
    addLegalInstruction(encode_i(5'd0, 5'd3, 12'd0, INST_ADDI));
    
    addFaultInstruction(32'b0);
  endfunction
  
  function void misalignedMemAccessTest();
    clear();
    
    addLegalInstruction(encode_i(5'd0, 5'd1, 12'd12, INST_ADDI));
    addLegalInstruction(encode_i(5'd0, 5'd2, 12'd9, INST_ADDI));
    
    addFaultInstruction(encode_s(5'd2, 5'd1, 12'd10));
  endfunction
  
  function void mixedInstructionPrograms();
    clear();
    addLegalInstruction(encode_i(5'd0,  5'd1,  12'd12, INST_ADDI));
    addLegalInstruction(encode_i(5'd0,  5'd2,  12'd5,  INST_ADDI));
    addLegalInstruction(encode_r(5'd1,  5'd2,  5'd3,  ADD));
    addLegalInstruction(encode_r(5'd1,  5'd2,  5'd4,  SUB));
    addLegalInstruction(encode_r(5'd1,  5'd2,  5'd5,  AND));
    addLegalInstruction(encode_r(5'd1,  5'd2,  5'd6,  OR));
    addLegalInstruction(encode_i(5'd2,  5'd7,  -3,     INST_ADDI));

    addLegalInstruction(encode_s(5'd0,  5'd3,  12'd20));
    addLegalInstruction(encode_i(5'd0,  5'd8,  12'd20, INST_LW));

    addLegalInstruction(encode_b(5'd3, 5'd8, 13'd8));
    addSkippedInstruction(encode_i(5'd0, 5'd9, 12'd99, INST_ADDI));

    addLegalInstruction(encode_i(5'd8, 5'd16, -2, INST_ADDI));

    addLegalInstruction(encode_b(5'd1, 5'd2, 13'd8));
    addLegalInstruction(encode_r(5'd16, 5'd7, 5'd17, ADD));

    addLegalInstruction(encode_s(5'd0, 5'd17, 12'd128));
    addLegalInstruction(encode_i(5'd0, 5'd18, 12'd128, INST_LW));

    addLegalInstruction(encode_r(5'd18, 5'd2,  5'd19, SUB));
    addLegalInstruction(encode_r(5'd19, 5'd6,  5'd20, AND));
    addLegalInstruction(encode_r(5'd7,  5'd2,  5'd21, OR));
    addLegalInstruction(encode_i(5'd21, 5'd22, -7, INST_ADDI));
    addLegalInstruction(encode_r(5'd22, 5'd1,  5'd23, ADD));
    addLegalInstruction(encode_r(5'd23, 5'd7,  5'd24, SUB));
    addLegalInstruction(encode_r(5'd24, 5'd2,  5'd25, OR));
    addLegalInstruction(encode_r(5'd25, 5'd6,  5'd26, AND));

    addLegalInstruction(encode_b(5'd26, 5'd6, 13'd8));
    addSkippedInstruction(
      encode_i(5'd0, 5'd27, 12'd123, INST_ADDI)
    );

    addLegalInstruction(encode_i(5'd26, 5'd28, 12'd1, INST_ADDI));

    addLegalInstruction(encode_b(5'd28, 5'd26, 13'd8));
    addLegalInstruction(encode_r(5'd28, 5'd7, 5'd29, ADD));

    addLegalInstruction(encode_s(5'd0, 5'd29, 12'd252));
    addLegalInstruction(encode_i(5'd0, 5'd30, 12'd252, INST_LW));

    addFaultInstruction(32'b0);
       
  endfunction
endclass















