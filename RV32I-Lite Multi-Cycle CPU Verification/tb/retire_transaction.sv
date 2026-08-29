import rv32i_package::*;

class retire_transaction;
  
  logic [31:0] retire_PC;
  logic [31:0] raw_instruction;
  instruct_t instructionType;
  
  logic wroteRdReg;
  logic [4:0] rdReg;
  logic [31:0] rdValue;
  
  logic write_to_memory;
  logic [31:0] mem_addr;
  logic [31:0] mem_writeData;
  
  const int transID;
  static int nextID = 1;
  
  covergroup cGroup;
    rdRegLocations: coverpoint rdReg iff (wroteRdReg) {
      bins lowerHalf = {[1:15]};
      bins upperHalf = {[16:31]};
    }
    
    instructionDist: coverpoint instructionType {
      bins rType[] = {INST_ADD, INST_SUB, INST_AND, INST_OR};
      bins iType[] = {INST_ADDI, INST_LW};
      bins sType[] = {INST_SW};
      bins bType[] = {INST_BEQ};
    }
    
    memAddrLocations: coverpoint mem_addr iff (write_to_memory) {
      bins lowerAddr = {[0:127]};
      bins upperAddr = {[128:255]};
    }
    
    instructLocations: coverpoint retire_PC {
      bins lowerInstructs = {[0:127]};
      bins upperInstructs = {[128:255]};
      
    }
    
    destRegInstruct: cross rdRegLocations, instructionDist iff (wroteRdReg);
    option.per_instance = 0;
  endgroup
  
  function new(logic [31:0] retire_PC, logic [31:0] raw_instruction, logic [31:0] rdValue, logic retire_rd_write, logic [4:0] retire_rd,
               logic retire_mem_write, logic [31:0] retire_mem_addr, logic [31:0] retire_mem_wdata);
    cGroup = new;
    
  	this.retire_PC = retire_PC;
    this.raw_instruction = raw_instruction;
    this.rdValue = rdValue;
    
    this.rdReg = retire_rd;
    this.instructionType = instructType(raw_instruction);
    this.wroteRdReg = retire_rd_write;
    
    this.write_to_memory = retire_mem_write;
    this.mem_addr = retire_mem_addr;
    this.mem_writeData = retire_mem_wdata;
    
    transID = nextID;
    nextID++;
  endfunction
  
  function instruct_t instructType(logic [31:0] instruct);
    instruct_t inType = INST_ILLEGAL;
    case(instruct[6:0])
      7'b0110011: begin
        if(instruct[14:12] == 3'b0 && instruct[31:25] == 7'b0) begin
          inType = INST_ADD; 
        end
        else if(instruct[14:12] == 3'b0 && instruct[31:25] == 7'b0100000) begin
          inType = INST_SUB; 
        end
        else if(instruct[14:12] == 3'b111 && instruct[31:25] == 7'b0) begin 
          inType = INST_AND;
        end
        else if(instruct[14:12] == 3'b110 && instruct[31:25] == 7'b0) begin 
          inType = INST_OR; 
        end
        else inType = INST_ILLEGAL;
                
      end
      7'b0010011: begin
        if(instruct[14:12] == 3'b0) begin
          inType = INST_ADDI;
        end
        else inType = INST_ILLEGAL;
      end
      7'b0000011: begin
        if(instruct[14:12] == 3'b010) begin
          inType = INST_LW;
        end
        else inType = INST_ILLEGAL;
      end
      7'b0100011: begin
        if(instruct[14:12] == 3'b010) begin
          inType = INST_SW;
        end
        else inType = INST_ILLEGAL;
      end
      7'b1100011: begin
        if(instruct[14:12] == 3'b0) begin
          inType = INST_BEQ;
        end
        else inType = INST_ILLEGAL;
      end
      default: inType = INST_ILLEGAL;
    endcase
    
    return inType;
  endfunction
  
  
  
  
  function retire_transaction copy();
    retire_transaction c = new(this.retire_PC, this.raw_instruction, this.rdValue, this.wroteRdReg, this.rdReg, this.write_to_memory, this.mem_addr, this.mem_writeData);
    
    return c;
  endfunction
  
  function void summary();
    $display("############ Transaction ID %0d Summary ############", this.transID);
    $display("PC=%0h, INST=%s, RD_WRITE=%0b, RD=%0d, RD VALUE=%0h", this.retire_PC, instructionType.name(), this.wroteRdReg, this.rdReg, this.rdValue);
    $display("MEM_WRITE=%0b, MEM_ADDR=%0h, WRITE_VALUE=%0h", this.write_to_memory, this.mem_addr, this.mem_writeData);
  endfunction
endclass














