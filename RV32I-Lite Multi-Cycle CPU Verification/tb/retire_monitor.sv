
class retire_monitor;
  virtual riscvInf.retireMonitor retireMon;
  mailbox #(retire_transaction) monToSb;
  mailbox #(retire_transaction) monToCov;
  
  function new(virtual riscvInf.retireMonitor retireMon, mailbox #(retire_transaction) monToSb, mailbox #(retire_transaction) monToCov);
    this.retireMon = retireMon;
    this.monToSb = monToSb;
    this.monToCov = monToCov;
  endfunction
  
  task run();
    retire_transaction monTrans;
    wait(retireMon.rClock.RESET == 1'b0);
    
    forever begin
      @(retireMon.rClock);
      if(retireMon.rClock.retire_valid && !retireMon.rClock.RESET) begin
        monTrans = new(retireMon.rClock.retire_pc, retireMon.rClock.retire_instr, retireMon.rClock.retire_rd_value, retireMon.rClock.retire_rd_write, retireMon.rClock.retire_rd, retireMon.rClock.retire_mem_write, retireMon.rClock.retire_mem_addr, retireMon.rClock.retire_mem_wdata);
        
        monToSb.put(monTrans.copy());
        monToCov.put(monTrans.copy());
      end
           
      
    end
    
    
  endtask
  
endclass














