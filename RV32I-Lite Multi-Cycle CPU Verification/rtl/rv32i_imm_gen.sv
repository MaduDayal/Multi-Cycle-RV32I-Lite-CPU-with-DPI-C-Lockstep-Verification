import rv32i_package::*;

module rv32i_imm_gen( 
  input logic [31:0] instruct,
  input immType imInput,
  output logic [31:0] immediate
);
  
  always_comb begin
    case(imInput)
      I_imm: immediate = {{21{instruct[31]}}, instruct[30:20]};
      S_imm: immediate = {{21{instruct[31]}}, instruct[30:25], instruct[11:7]};
      B_imm: immediate = {{20{instruct[31]}}, instruct[7], instruct[30:25], instruct[11:8], 1'b0};
      default: immediate = 32'b0;
    endcase
  end
  
  
  
endmodule









