module Forward(
  input  [3:0] Reg, Rd_EX, Rd_MEM, Rd_WB,
  input        EX_RegWr, MEM_RegWr, WB_RegWr,
  output reg [1:0] Forward
);
  always @(*) begin

  if ((Reg == Rd_MEM) && MEM_RegWr) begin // if Reg in MEM Stage and theres a write operation FORWARD
    Forward = 2'b10;
    // $display("Forward from MEM: R%d", Reg);
  end
  else if ((Reg == Rd_EX) && EX_RegWr) begin // if Reg in EX Stage and theres a write operation FORWARD
    Forward = 2'b01; 
    // $display("Forward from EX: R%d", Reg);
  end
  else if ((Reg == Rd_WB) && WB_RegWr) begin // if Reg in WB Stage and theres a write operation FORWARD
    Forward = 2'b11; 
    // $display("Forward from WB: R%d", Reg);
  end
  else begin // NO FORWARDING
    Forward = 2'b00;  
  end
   if (Forward != 2'b00) begin
    // $display("Forward Check: Reg=%d, Rd_EX=%d, Rd_MEM=%d, Rd_WB=%d, EX_RegWr=%b, MEM_RegWr=%b, WB_RegWr=%b => Forward=%b",
    //     Reg, Rd_EX, Rd_MEM, Rd_WB, EX_RegWr, MEM_RegWr, WB_RegWr, Forward);
 end
end

endmodule
     
  module Stall(input MEM_R,input [1:0] FA,FB,WBData,output reg stall);
  initial stall = 0;
  
  always @(*) begin
   
    if ((FA == 1 || FB == 1) && MEM_R) // CHECK IF THERE IS A CASE OF FORWARDING WHILE THE MEM_R IS FORWARDED FROM EXECUTION STAGE
      stall = 1;
    else if((FA == 1 || FB == 1) && WBData==2'b10) // STALL IF THERE IS FORWARDING AND CLL INSTRUCTION
      stall = 1;
    else 
      stall=0;
    
    if (stall)begin
        $display("Stall Check at time %0t: FA=%b, FB=%b, MEM_R=%b, WBData=%b => stall=%b", 
              $time, FA, FB, MEM_R, WBData, stall);
    end
  end
endmodule


      // if (MEM_R !==1'bx)
      //       $display("STALL: FA = %b, FB = %b, MEM_R = %b => stall = %b", FA, FB, MEM_R, stall);
//       if (MEM_R !==1'bx)
//   $display("NO STALL: FA = %b, FB = %b, MEM_R = %b => stall = %b", FA, FB, MEM_R, stall);  
  
  
module Kill(input [5:0] OpCode,input ZF,LTZ,output reg kill);
    initial kill = 0;
    always @(*) begin
    if ((OpCode == `BZ) && ZF==1) kill = 1; // KILL CYCLE IF A BRANCH IS TAKEN // OR UNCONDINATIONAL BRANCH (JUMP)
    else if ((OpCode == `BGZ) && (LTZ != 1 && ZF != 1)) kill = 1;
    else if ((OpCode == `BLZ) && LTZ == 1) kill = 1;
    else if (OpCode == `J || OpCode == `JR || OpCode == `CLL) kill = 1;
    else kill = 0;
      // $display("Kill Module Debug -- Time: %0t | OpCode: 0x%02h | ZF: %b | LTZ: %b | kill: %b",
      //        $time, OpCode, ZF, LTZ, kill);
  end

endmodule








     
     
