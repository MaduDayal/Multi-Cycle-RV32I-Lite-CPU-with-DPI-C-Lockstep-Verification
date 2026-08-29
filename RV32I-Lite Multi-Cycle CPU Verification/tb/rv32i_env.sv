
class rv32i_env;
  retire_scoreboard rSb;
  retire_monitor rMon;
  rv32i_functional_coverage rCov;
  
  function new(mailbox #(retire_transaction) monToSb, virtual riscvInf.retireMonitor retireMon, mailbox #(retire_transaction) monToCov);
    this.rSb = new(monToSb);
    this.rMon = new(retireMon, monToSb, monToCov);
    this.rCov = new(monToCov);
  endfunction
  
  task run();
    fork
      rSb.run();
      rMon.run();
      rCov.run();
    join_none
    
    
  endtask
  
endclass















