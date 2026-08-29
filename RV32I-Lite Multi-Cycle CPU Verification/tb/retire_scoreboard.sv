import rv32i_dpi_package::*;

class retire_scoreboard;
  mailbox #(retire_transaction) monTrans;

  
  int num_pass;
  int num_fail;
  int total_instructions;
  
  function new(mailbox #(retire_transaction) monTrans);
    this.monTrans = monTrans;
    this.num_pass = 0;
    this.num_fail = 0;
	this.total_instructions = 0;
  endfunction
  
  task run();
    retire_transaction temp;
    int unsigned regWriteFlag, memWriteFlag;
    int unsigned regWriteData, memWriteData;
    int unsigned rd, memAddr;
    logic transaction_pass;
    int status;
    
    forever begin
      monTrans.get(temp);
      transaction_pass = 1'b1;
      status = processInstruct(temp.retire_PC, temp.raw_instruction, regWriteFlag, rd, regWriteData, memWriteFlag, memAddr, memWriteData);
      
      total_instructions++;
      
      if(status != 0) begin
        temp.summary();
        num_fail++;
        case(status)
          1: $fatal(1, "ERROR - Retired PC does not match actual PC.");
          2: $fatal(1, "ERROR - Instruction is invalid.");
          3: $fatal(1, "ERROR - Memory Address out of range.");
          default: $fatal(1, "ERROR: Unknown DPI reference-model status %0d.", status);
        endcase
      end
      
      if(temp.wroteRdReg != regWriteFlag) begin
        transaction_pass = 1'b0;
        $error("ERROR - Expected Reg r/w: %0d, Actual Reg r/w: %0d", regWriteFlag, temp.wroteRdReg);
      end
      else if(regWriteFlag == 32'd1) begin
        if(temp.rdReg != rd) begin
          transaction_pass = 1'b0;
          $error("ERROR - Expected result reg: %0d, Actual result reg: %0d", rd, temp.rdReg);
        end
        else if(temp.rdValue != regWriteData) begin
          transaction_pass = 1'b0;
          $error("ERROR - Expected reg result value: %0d, Actual reg result value: %0d", regWriteData, temp.rdValue);
        end
      end
      
      
      if(temp.write_to_memory != memWriteFlag) begin
        transaction_pass = 1'b0;
        $error("ERROR - Expected Mem r/w: %0d, Actual Mem r/w: %0d", memWriteFlag, temp.write_to_memory);
      end
      else if(memWriteFlag == 32'd1) begin
        if(temp.mem_addr != memAddr) begin
          transaction_pass = 1'b0;
          $error("ERROR - Expected mem address: %0d, Actual mem address: %0d", memAddr, temp.mem_addr);
        end
        else if(temp.mem_writeData != memWriteData) begin
          transaction_pass = 1'b0;
          $error("ERROR - Expected mem write value: %0d, Actual mem write value: %0d", memWriteData, temp.mem_writeData);
        end
      end

      if(transaction_pass == 1'b1) num_pass++;
      else begin
        num_fail++;
        temp.summary();
        $fatal(1, "Retirement transaction failed scoreboard comparison.");
      end
    end
    
  endtask
  
  
  function void summary();
    $display("");
    $display("################## SCOREBOARD SUMMARY ##################");
    $display("ACTUAL Total Instructions: %0d", total_instructions);
    $display("Number of Instructions Passed: %0d", num_pass);
    $display("Number of Instructions failed: %0d", num_fail);
    $display("REFERENCE Total Instructions: %0d", instructionCount());
    if(num_fail == 0 && (num_pass == total_instructions) && (instructionCount() == total_instructions)) $display("FINAL RESULT: PASS");
    else $display("FINAL RESULT: FAIL");
    $display("########################################################");
    $display("");
  endfunction
endclass











