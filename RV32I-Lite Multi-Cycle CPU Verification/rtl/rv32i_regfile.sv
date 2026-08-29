import rv32i_package::*;

module rv32i_regfile(
  input logic [4:0] rs1, rs2, rd,
  input logic CLK, rd_write, RESET,
  input logic [31:0] rdValue,
  output logic [31:0] rs1Value, rs2Value
);
  
  logic [31:0] regValues [0:31];
  
  always_comb begin
    if(RESET) begin
      rs1Value = '0;
      rs2Value = '0;
    end
    else begin
      rs1Value = regValues[rs1];
      rs2Value = regValues[rs2];
    end
  end
  
  always_ff @(posedge CLK) begin
    regValues[0] <= '0;
    
    if(RESET) regValues <= '{default: 0};
    else if(rd != 5'b0 && rd_write) begin
      regValues[rd] <= rdValue;
    end
  end
endmodule










