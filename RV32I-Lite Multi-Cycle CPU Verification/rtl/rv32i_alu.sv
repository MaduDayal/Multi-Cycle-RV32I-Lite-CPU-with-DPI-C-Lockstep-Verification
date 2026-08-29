import rv32i_package::*;

module rv32i_alu (
  input logic [31:0] op1, op2,
  input ALU_OP opCode,
  output logic [31:0] res,
  output logic equal
);
  
  
  always_comb begin
    equal = (op1 == op2);
    case(opCode)
      ADD: begin
        res = op1 + op2;
      end
      SUB: begin
        res = op1 - op2;
      end
      AND: begin
        res = op1 & op2;
      end
      OR: begin
        res = op1 | op2;
      end
      default: res = 32'b0;
  	endcase
  end
  
endmodule















