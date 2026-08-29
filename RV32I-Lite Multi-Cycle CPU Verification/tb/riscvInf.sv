interface riscvInf(input logic CLK, input logic RESET);
  
  logic retire_valid, retire_rd_write, retire_mem_write, halted, illegal_error, alignment_error, address_range_error;
  logic [31:0] retire_pc, retire_instr, retire_rd_value, retire_mem_addr, retire_mem_wdata;
  logic [4:0] retire_rd;
  
  clocking rClock @(posedge CLK);
    input #3ns RESET, retire_valid, retire_rd_write, retire_mem_write, retire_pc, retire_instr, retire_rd_value, retire_mem_addr, retire_mem_wdata, retire_rd;
  endclocking
  
  
  modport DUTmp(input CLK, input RESET, output retire_valid, output retire_pc, output retire_instr, output retire_rd_write, 
                output retire_rd, output retire_rd_value, output retire_mem_write, output retire_mem_addr, output retire_mem_wdata, output address_range_error, output halted, output illegal_error, output alignment_error);
  
  modport retireMonitor(clocking rClock);
  
endinterface















