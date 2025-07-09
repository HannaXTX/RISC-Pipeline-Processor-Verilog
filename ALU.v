module ALU_Component(
  input signed [31:0] OPER1,
  input signed [31:0] OPER2,
  input [1:0] ALU_OP,
  output reg signed [31:0] Result
);

  always @(*) begin
    case (ALU_OP)
      `OR:  Result = OPER1 | OPER2;
      `ADD: Result = OPER1 + OPER2;
      `SUB: Result = OPER1 - OPER2;
      `CMP: Result = (OPER1 > OPER2) ? 32'd1 :
                     (OPER1 < OPER2) ? -32'd1 : 32'd0;
      default: Result = 32'd0;
    endcase
    
    // Print ALU operation details
    // $display("ALU_OP=%b OPER1=%0d OPER2=%0d Result=%0d",
    //           ALU_OP, OPER1, OPER2, Result);
  end

endmodule

