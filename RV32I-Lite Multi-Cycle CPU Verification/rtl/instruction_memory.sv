

module instruction_memory(
  input logic [31:0] address,
  input logic RESET,
  output logic [31:0] instruct
);
  
  logic [31:0] instructMem [0:63];
  
  always_comb begin
    if(RESET) instruct = 32'b0;
    else if(address < 256 && address[1:0] == 2'b0) instruct = instructMem[address[7:2]];
    else instruct = 32'b0;
  end
endmodule









