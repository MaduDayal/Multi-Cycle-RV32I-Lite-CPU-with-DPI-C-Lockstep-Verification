package rv32i_dpi_package;
  
  
  
  import "DPI-C" function void reset();
  import "DPI-C" function int instructionCount();
import "DPI-C" function int processInstruct(input int unsigned retiredPC, input int unsigned raw_instruction, output int unsigned expRegWriteFlag, output int unsigned expDestReg, output int unsigned expRegValue, output int unsigned expMemWriteFlag, output int unsigned expMemAddr, output int unsigned expMemData);
  
  
endpackage






