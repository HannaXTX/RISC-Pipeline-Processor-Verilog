module Control_Unit(input [5:0] Opcode,output reg RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr,output reg [1:0] WBdata, ALUOp);
  
  
  reg [9:0] CU_Memory [15:0];
  
  initial begin 
    // READ FROM Control Signals File
    $readmemb("Control_Signals.dat",CU_Memory);
  end
  
  always @(Opcode)begin
    // Output the Control Signal according to OPCODE to each reg
    if (Opcode < 16)begin
      RegDst  = CU_Memory[Opcode][9];
      RegWr   = CU_Memory[Opcode][8];
      ExtOp   = CU_Memory[Opcode][7];
      ALUSrc  = CU_Memory[Opcode][6];
      MemRd   = CU_Memory[Opcode][5];
      MemWr   = CU_Memory[Opcode][4];
      WBdata  = CU_Memory[Opcode][3:2];
      ALUOp   = CU_Memory[Opcode][1:0];
    end
    else
      {RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr, WBdata, ALUOp} = 0;

  end
    
    
endmodule



// Check if 9:8 gives right output   
//       # 5fs $display("CU_Memory[%0d] = %b", Opcode, CU_Memory[Opcode]);
    
//       # 5fs $display("5.Control Signals for Opcode=%b -> RegDst=%b, RegWr=%b, ExtOp=%b, ALUSrc=%b, MemRd=%b, MemWr=%b, WBdata=%b, ALUOp=%b",
//              Opcode, RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr, WBdata, ALUOp);


module PC_Control_Unit(
    input  [31:0] currentPC,     
    input  [31:0] Reg,       
    input  signed [31:0] Ext_Imm,       
    input         ZERO,      
    input         LTZ,      
    input  [5:0]  PC_Select,   
    output reg [31:0] NextPC,
    input Special_DW
);
      // THIS UNIT CONTROLS THE PROGRAM COUNTER
      // initial $monitor("2.PC_Control_Unit: PC_Select=%d, currentPC=%0d, Reg=%0d, Ext_Imm=%0d, Z=%b, LTZ=%b => NextPC=%0d",
      //  PC_Select, currentPC, Reg, Ext_Imm, ZERO, LTZ, NextPC);
    initial NextPC = 1'b0;
    always @(*) begin
        
        case (PC_Select)
                `OR, `ADD, `SUB, `CMP, `ORI, `ADDI, `LW, `SW: // THESE INSTRUCTIONS DO NOT CHANGE THE ORDER OF EXECUTION SO PC+1
    			      NextPC = currentPC + 32'd1;
            `J,`CLL: NextPC = currentPC + Ext_Imm-1;  // NEXT PC IS DETERMINED BY THE GIVEN IMMIEDIATE AND CURRENT PC
            `JR: NextPC = Reg; // NEXT PC IS STORED IN REG 14
            `BZ: begin  // CONDINTIONAL BRANCHES BGZ BLZ BZ
                if (ZERO) begin
              NextPC = currentPC + Ext_Imm-1;
              $display("BRANCH TAKEN: NextPC = %0d (currentPC = %0d + Ext_Imm = %0d)", 
                      NextPC, currentPC, Ext_Imm-1);
            end
                else
                    NextPC = currentPC + 32'd1;
            	end
            `BLZ: begin
                if (LTZ)
                    NextPC = currentPC + Ext_Imm-1;
                else
                    NextPC = currentPC + 32'd1;
            	end
            `BGZ: begin
              if (ZERO == 0 && LTZ == 0) begin
                    NextPC = currentPC + Ext_Imm-1;
                    $display("BRANCH TAKEN: NextPC = %0d (currentPC = %0d + Ext_Imm = %0d)", 
                      currentPC + Ext_Imm, currentPC, Ext_Imm);
              end 
                  else
                    NextPC = currentPC + 32'd1;      
              end
            default: NextPC = currentPC+1;
        endcase
    end

endmodule
