
class rv32i_functional_coverage;
  
  mailbox #(retire_transaction) fromMonitor;
  retire_transaction temp;
  
  function new(mailbox #(retire_transaction) fromMonitor);
    this.fromMonitor = fromMonitor;
    
  endfunction
  
  task run();
        
    forever begin
      fromMonitor.get(temp);
      temp.cGroup.sample();
            
    end
  endtask
  
  
  function void coverageSummary();
    $display("########## COVERAGE SUMMARY ##########");
    $display("Functional Coverage: %0.2f%%", temp.cGroup.get_coverage());
    
  endfunction
  
endclass














