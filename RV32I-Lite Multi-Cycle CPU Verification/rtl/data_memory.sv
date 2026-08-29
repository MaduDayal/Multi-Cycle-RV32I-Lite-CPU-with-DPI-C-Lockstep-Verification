
module data_memory(
  input logic CLK, RESET,
  input logic [31:0] addr, write_data,
  input logic mem_read, mem_write,
  output logic [31:0] read_data
);
  
  logic [31:0] data [0:63];
  
  always_comb begin
    if(RESET) read_data = 32'b0;
    else if(addr < 256 && mem_read && addr[1:0] == 2'b0) read_data = data[addr[7:2]];
    else read_data = 32'b0;
  end
  
  always_ff @(posedge CLK) begin
    if(RESET) data <= '{default: 0};
    else if(addr < 256 && mem_write && addr[1:0] == 2'b0) data[addr[7:2]] <= write_data;
    
  end
  
endmodule









