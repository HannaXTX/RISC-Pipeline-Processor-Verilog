module Comparator (REG_VALUE,ZF,LTZF);
  input signed [31:0]REG_VALUE;
  output reg ZF,LTZF;
  always @(*)begin
      {ZF,LTZF} = 2'b00;
      ZF   = (REG_VALUE == 0) ? 1'b1 : 1'b0;
      LTZF = (REG_VALUE < 0) ? 1'b1 : 1'b0;
  //  $display("Comparator: REG_VALUE = %0d | ZF = %b | LTZF = %b", REG_VALUE, ZF, LTZF);
  end
endmodule



// module mux4x1 #(parameter WIDTH = 32)(
//   input [WIDTH-1:0] O1, O2, O3, O4,
//   input [1:0] sel,
//   output reg [WIDTH-1:0] OUT
// );

//   always @(*) begin
//     case (sel)
//       2'b00: OUT = O1;
//       2'b01: OUT = O2;
//       2'b10: OUT = O3;
//       2'b11: OUT = O4;
//     endcase
//       if (sel)begin
//         $display("MUX4x1 | sel = %b | O1 = %-10d | O2 = %-10d | O3 = %-10d | O4 = %-10d | OUT = %-10d",
//              sel, O1, O2, O3, O4, OUT);
//       end
//   end
// endmodule

module mux4x1 (
  input [31:0] O1, O2, O3, O4,
  input [1:0] sel,
  output reg [31:0] OUT
);

 initial begin
    OUT = 32'd0;
  end

  always @(*) begin

    case (sel)
      2'b00: OUT = O1;
      2'b01: OUT = O2;
      2'b10: OUT = O3;
      2'b11: OUT = O4;
      default: OUT = 32'd0; 
    endcase

    // $display("MUX4x1 | sel = %b | O1 = %-10d | O2 = %-10d | O3 = %-10d | O4 = %-10d | OUT = %-10d",
    //       sel, O1, O2, O3, O4, OUT);
    
  end
endmodule

// module Register_Incrementor(
//   input  [5:0] Opcode,
//   input  [3:0] Rd,
//   input  Special_DW,
//   output reg [3:0] Out_Reg
// );
//   initial Special_DW=0;

//   always @(*) begin
//     if ((Opcode == `LDW || Opcode == `SDW) && Rd == 4'd1) begin
//       if (!Special_DW)
//          Special_DW = 1;
//       if (Special_DW)  begin
//          Out_Reg = Rd + 1;
//          Special_DW = 0;
//       end
//     end else begin
//       Out_Reg = Rd;
//     end
//   end

// endmodule


module mux2x1 #(parameter WIDTH = 32)(
  input [WIDTH-1:0] O1, O2,
  input sel,                             
output reg [WIDTH-1:0] OUT

);

  always @(*) begin
     case (sel)
     1'b0:OUT = O1;
     1'b1:OUT = O2;
    endcase
  end
endmodule



module Extender(input sel,input [13:0] Imm,output reg [31:0] out);

  always @(*) begin
    if (!sel)
      out = {18'b0, Imm};              
    else
      out = {{18{Imm[13]}}, Imm}; 
    // $display("EXT = %d Value = %d",sel,out);
  end

endmodule