module Fetch(clk, stall, kill, Reg, Ext_Imm, ZF, LTZ, PC_Control, Special_DWI, PC_out, Inst_Out);
  input        clk,stall,kill,ZF,LTZ;
  input [31:0] Reg,Ext_Imm;
  input [5:0]  PC_Control;
  output reg Special_DWI;
  output reg [31:0] PC_out;
  output reg [31:0] Inst_Out;
  wire [31:0] Next_PC;
  reg  [31:0] PC;
  wire [31:0] PC_adjusted;
  wire [31:0] Inst_In;

  reg HALT;

  // Instruction Memory and PC Control
  InstructionMemory Get_INST(PC, Inst_In);
  PC_Control_Unit Control_Units(PC, Reg, Ext_Imm, ZF, LTZ, PC_Control, Next_PC, Special_DWI);

  initial begin
    PC = 0;
    PC_out = 0;
    Special_DWI=0;
    HALT=0;
  end

  always @(*) begin // IF THERES AN SDW OR LDW HALT FETCHING
   if (Inst_In[31:26] == `SDW ||Inst_In[31:26]  == `LDW )
      HALT=1;
  end
  
  always @(posedge clk) begin  // DELAY SPECIAL_DW FOR NEXT CYCLE OF LDW OR SDW
   if (Inst_In[31:26] == `SDW ||Inst_In[31:26]  == `LDW )
    Special_DWI <= 1;

  end

  always @(posedge clk) begin
    if (!stall && !HALT) begin //STOP UPDATING PC IF THERES A HALT OR STALL
      PC <= Next_PC;
      PC_out <= Next_PC;
      Special_DWI<=0;
    end
    HALT=0; // RETURN HALT BACK TO NORMAL FOR NEXT PC

    // $display("FETCH: PC=%0d Next_PC=%0d PC_OUT=%0d Opcode=%d stall=%b kill=%b, SpecialDW=%b",
    //          PC, Next_PC, PC_out, PC_Control, stall, kill, Special_DWI);
  end

  always @(*) begin
    if (kill)  // KILL THE INSTRUCTION
      Inst_Out = 32'hDEADDEAD;
    else
      Inst_Out = Inst_In;
  end

endmodule


module Decode(
  input clk,MEMRD_EX,Special_DW,
  input [3:0] Rd_EX, Rd_MEM, Rd_WB, Rd_WB_in,
  input EX_RegWr, MEM_RegWr, WB_RegWr,Special_WB_LDW,
  input [31:0] PC, Inst, BusW, aluForward, memForward, WBForward,
  input [1:0] WBdata_wb,

//   input [1:0]  WBdata_mem;
  output wire [3:0] Rs, Rt, Rd,
  output reg signed [31:0] Imm_Ext,
  output wire [31:0] Rs_out, Selected_R_out,
  output wire [3:0] Selected_R,
  output wire [5:0] Opcode,
  output wire [31:0] BusA, BusB,
  output wire RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr,Special_DW_Out,
  output wire [1:0] WBdata, ALUOp,
  output reg killout,stallout,ZF,LTZF
);
  wire [13:0] Imm;
  wire [1:0] ForwardA, ForwardB;
  wire [3:0] Rd_raw = (Inst == 32'hDEADDEAD) ? 4'b0 : Inst[25:22];


  wire kill,stall,ZFw,LTZFw;
  // GET DATA FROM INSTRUCTION UNLESS THERES A KILL
  assign Opcode = Inst[31:26];
  assign Rd     = actual_Rd;
  assign {Rs, Rt, Imm} = (Inst == 32'hDEADDEAD) ? {4'b0, 4'b0, 14'b0} : {Inst[21:18], Inst[17:14], Inst[13:0]};
  output wire signed [31:0] Imm_Extw;
  
  // always @(*) begin
  //     $display("4.Decode:Inst=%b \nOpcode=%b Rd=%0d Rs=%0d Rt=%0d Imm=%0d",Inst, Opcode, Rd, Rs, Rt, Imm);
  wire [3:0] actual_Rd = (Opcode == `CLL) ? 4'd14 : Rd_raw; // CHANGE REG DESTINATION TO 14 ACCORDING TO INSTRUCTION
  wire [3:0] Selected_R_1 = (RegDst == 0) ? Rt : Rd;  // SELECT R FOR OPERATION ACCORDING TO SIGNAL
  assign Selected_R = (Special_DW == 1) ? Selected_R_1 + 1 : Selected_R_1; // IF LDW OR SDW SECOND CYCLE CHOSE RD+1

  assign Special_DW_Out = Special_DW;

  wire [3:0] Rd_WB_in_o = (Special_WB_LDW) ? Rd_WB_in + 1 : Rd_WB_in; // IF LDW OR SDW SECOND CYCLE CHOSE RD+1


  Control_Unit CU(Opcode, RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr, WBdata, ALUOp); // GET SIGNALS
  Forward A(Rs, Rd_EX, Rd_MEM, Rd_WB, EX_RegWr, MEM_RegWr, WB_RegWr, ForwardA); // FORWARD Rs
  Forward B(Selected_R, Rd_EX, Rd_MEM, Rd_WB, EX_RegWr, MEM_RegWr, WB_RegWr, ForwardB); // FORWARD Chosen R2
  
  RegFile Read_Write(.clk(clk),.RegWr(WB_RegWr),.A(Rs),.B(Selected_R),.W(Rd_WB_in_o),.BusW(BusW),.BusA(BusA),.BusB(BusB)); 
  // WRITE OR READ FROM REGFILE
  Extender Extend(ExtOp, Imm, Imm_Extw);
  // EXTEND IMM
  Comparator Check_Branch(Rs_out,ZFw,LTZFw);
  // GET BRANCH RESULT
  Stall S(MEMRD_EX, ForwardA, ForwardB,WBdata_wb, stall);
  // PROPAGATE STALL
  Kill K(Opcode, ZFw,LTZFw, kill);
  // PROPAGATE KILL

  // MUXES TO FORWARD VALUES IN DIFFERENT STAGES
  mux4x1 FA(BusA, aluForward, memForward, WBForward, ForwardA, Rs_out);
  mux4x1 FB(BusB, aluForward, memForward, WBForward, ForwardB, Selected_R_out);
 
  reg [1:0] isLDW;
  initial begin
    Imm_Ext=0;
    killout = 0;
    stallout = 0;
    ZF = 0;
    LTZF = 0;
    isLDW=0;
  end

always @(*) begin
    if ((Opcode == `SDW || Opcode == `LDW) && (Selected_R_1 % 2 == 1) && !Special_DW) begin //EXCEPTION HANDLING
        $display("Exception: SDW instruction with odd source register detected! Rd=%0d", Selected_R_1);
        $finish();
    end
end

  always @(*)begin
  
    killout = kill;
    stallout = stall;
    ZF = ZFw;
    LTZF = LTZFw;
    Imm_Ext = Imm_Extw;
  end


  

endmodule


module Execute(
    input signed [31:0] OPER1, OPER2, immExt, pc_in,
    input [3:0] regDst_in,
    input [1:0] ALU_OP, WBData_in,
    input aluSrc, regWr_in, memRd_in, memWr_in,Special_IN,
    output reg [31:0] pc_out, ALU_Output,
    output reg memRd_ex, memWr_out, regWr_ex,Special_OUT,
    output reg [1:0] WBData_out,
    output reg [3:0] regDst_ex,
    output reg [31:0] SRC2_OUT
);
  reg [31:0] True_OPER2;
  wire [31:0] ALU_Result;  

  ALU_Component alu(OPER1, True_OPER2, ALU_OP, ALU_Result);

  always @(*) begin
    // CHOOSE IMM+1 ON SECOND CYCLE WHEN LDW OR SDWs
    if (Special_IN)
        True_OPER2 = aluSrc ? (immExt + 1) : OPER2;
      else
        True_OPER2 = aluSrc ? immExt : OPER2;
    ALU_Output  = ALU_Result;
    SRC2_OUT    = OPER2;
    pc_out      = pc_in;
    memRd_ex    = memRd_in;
    memWr_out   = memWr_in;
    regWr_ex    = regWr_in;
    WBData_out  = WBData_in;
    regDst_ex   = regDst_in;
    Special_OUT = Special_IN;
  end
endmodule


module Memory(clk,alu_Result,Rd,regW,dataIn,pc,MR,MW,WBData,regW_mem,DataOut,Rd_mem,WBData_mem,Special_IN,Special_OUT);
  
  input clk,MR,MW,regW,Special_IN;
  input signed [31:0]alu_Result;
  input [31:0]pc,dataIn;
  input[3:0] Rd;
  input [1:0] WBData;
  output reg signed [31:0] DataOut;
  output reg regW_mem,Special_OUT;
  output reg [3:0] Rd_mem;
  output reg [1:0]WBData_mem;
  
  wire [31:0] DataMemory_Out;
  DataMemory Access_Memory(clk,alu_Result,dataIn,MW,MR,DataMemory_Out); // ACCESS THE MEMORY FOR WRITE OR READ
 
  always @(*) begin
        Rd_mem = Rd;
        WBData_mem = WBData;
        regW_mem  = regW;
        Special_OUT = Special_IN;
        case (WBData) // ACCORDING TO WRITE BACK CONTROL SIGNAL FOR EACH INSTRUCTION CHOOSE THE OUTPUT
            2'b00: DataOut = alu_Result;
            2'b01: DataOut = DataMemory_Out;
            2'b10: DataOut = pc+1;

        endcase

    end

endmodule