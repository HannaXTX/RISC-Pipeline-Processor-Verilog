
// BY HANNA KAIBNI 1220214
// & CARLOS KHAMASHTA 1220050
`timescale 1ns / 1ps
module Processor(input clk);

  // === IF/ID Wires ===
  wire [31:0] PC, Inst_Fetch, PC_ID, Inst_ID;
  wire stallout, killout;

  // === Decode Stage Wires ===
  wire [31:0] BusA, BusB, Selected_R_out;
  wire [31:0] Imm_Ext;
  wire [31:0] SRC1, SRC2;
  wire [3:0] Rs, Rt, Rd, Selected_R;
  wire [5:0] Opcode;
  wire RegDst, RegWr, ExtOp, ALUSrc, MemRd, MemWr;
  wire [1:0] WBData, ALUOp;
  wire ZF, LTZF;

  // === ID to EX Buffer Wires ===
  wire [31:0] Imm_Eout, BA_Eout, BB_Eout, PC_B_ID_EX;
  wire [3:0] Rd2_out;
  wire [1:0] ALUOp_EX, WBdata_EX;
  wire RegDst_EX, REGWR_EX, ExtOp_EX, ALUSrc_EX, MemRd_EX, MemWr_EX;

  // === EX Stage Wires ===
  wire [31:0] pc_ex, Result_EX, Buffer_EX, SRC2_OUT;
  wire [3:0] regDst_ex;
  wire [1:0] WBData_ex;
  wire memRd_ex, memWr_ex, regWr_ex, ZeroFlag;

  // === EX to MEM Buffer Wires ===
  wire [31:0] Data_of_SRC2_out;
  wire [31:0] pc_mem;
  wire [3:0] Rd_mem;
  wire [1:0] WBData_mem;
  wire regWr_mem, memRd_mem, memWr_mem;

  // === MEM to WB Wires ===
  wire [31:0] memOut;
  wire [3:0] Rd_wb;
  wire regWr_wb;
  wire [31:0] WBForward;

  // === Memory  Wires ===
  wire regWr_WB1;
  wire [31:0] regDst_WB1;
  wire [3:0] Rd_WB;
  wire [1:0] WBData_WB;

  // === Special Wires for LDW and SDW ===
  wire Special_DW, Special_DW_D, Special_DW_DE, Special_DW_EX;
  wire Special_DW_EM, Special_DW_M, Special_DW_MW, Special_DW_WB;

  // === Fetch Stage ===
  Fetch Fetch_Stage(
    .clk(clk), .stall(stallout), .kill(killout), .Inst_Out(Inst_Fetch),.Ext_Imm(Imm_Ext), 
    .ZF(ZF), .Reg(SRC1), .LTZ(LTZF), .PC_out(PC),.PC_Control(Opcode),.Special_DWI(Special_DW)
  );
  
  IF_to_ID IF_TO_ID_BUFFER(
    .clk(clk), .INST_Fin(Inst_Fetch), .PC_Fin(PC),
    .stall(stallout), .kill(killout), .INST_Dout(Inst_ID), .PC_Dout(PC_ID),.Special_IN(Special_DW),.Special_OUT(Special_DW_D)
  );

  // === Decode Stage ===
  Decode Decode_Stage(.clk(clk),.RegDst(RegDst), .RegWr(RegWr),.MEMRD_EX(memRd_ex),
    .ExtOp(ExtOp), .ALUSrc(ALUSrc), .MemRd(MemRd), .MemWr(MemWr),
    .WBdata(WBData), .ALUOp(ALUOp), .Rd_EX(regDst_ex), .Rd_MEM(Rd_mem),
    .Rd_WB(Rd_wb), .Rd_WB_in(Rd_wb), .EX_RegWr(regWr_ex),.MEM_RegWr(regWr_mem),
    .WB_RegWr(regWr_wb),.Inst(Inst_ID), .BusW(WBForward),
    .aluForward(Result_EX),.memForward(memOut),.WBForward(WBForward),     
    .WBdata_wb(WBData_mem), .Rs(Rs), .Rt(Rt),
    .Rd(Rd),.Imm_Ext(Imm_Ext), .Rs_out(SRC1), .Selected_R_out(SRC2),
    .Selected_R(Selected_R), .Opcode(Opcode), .BusA(BusA), .BusB(BusB),
    .stallout(stallout),.killout(killout),.ZF(ZF),.LTZF(LTZF),
    .Special_DW(Special_DW_D),.Special_DW_Out(Special_DW_DE),.Special_WB_LDW(Special_DW_WB)
  );

  ID_to_EX ID_TO_EX_BUFFER(.clk(clk), .stall(stallout), .Rd2_in(Rd),
    .BA_Din(SRC1), .BB_Din(SRC2), .Imm_Din(Imm_Ext),.RegDst_D(RegDst),
    .RegWr_D(RegWr), .ExtOp_D(ExtOp),.ALUSrc_D(ALUSrc),
    .MemRd_D(MemRd), .MemWr_D(MemWr),.WBdata_D(WBData), .ALUOp_D(ALUOp),
    .Rd2_out(Rd2_out), .BA_Eout(BA_Eout), .BB_Eout(BB_Eout),.Imm_Eout(Imm_Eout),
    .RegDst_EX(RegDst_EX), .RegWr_EX(REGWR_EX),.ExtOp_EX(ExtOp_EX), .ALUSrc_EX(ALUSrc_EX),
    .MemRd_EX(MemRd_EX),.MemWr_EX(MemWr_EX),.WBdata_EX(WBdata_EX), .ALUOp_EX(ALUOp_EX),
    .PC_B_ID_EXin(PC_ID),.PC_B_ID_EXout(PC_B_ID_EX),.Special_IN(Special_DW_DE),.Special_OUT(Special_DW_EX)
    );

    

  // === Execute Stage ===
  Execute Execute_Stage(
    .OPER1(BA_Eout), .OPER2(BB_Eout), .immExt(Imm_Eout), .pc_in(PC_B_ID_EX),
    .regDst_in(Rd2_out),.ALU_OP(ALUOp_EX),
    .WBData_in(WBdata_EX), .aluSrc(ALUSrc_EX), .regWr_in(REGWR_EX),
    .memRd_in(MemRd_EX), .memWr_in(MemWr_EX),
    .pc_out(pc_ex), .ALU_Output(Result_EX),
    .memRd_ex(memRd_ex), .memWr_out(memWr_ex), .regWr_ex(regWr_ex), .WBData_out(WBData_ex),
    .regDst_ex(regDst_ex),.SRC2_OUT(SRC2_OUT),.Special_IN(Special_DW_EX),.Special_OUT(Special_DW_EM)
  );

  EX_to_MEM EX_TO_MEM_BUFFER(
    .clk(clk), .Alu_Ein(Result_EX), .Data_Ein(SRC2_OUT), .Rd3_in(regDst_ex),
    .RegWr_Ein(regWr_ex), .MemRd_Ein(memRd_ex), .MemWr_Ein(memWr_ex), 
    .WBdata_Ein(WBData_ex),.Alu_Mout(Buffer_EX), .Data_Mout(Data_of_SRC2_out), 
    .Rd3_out(Rd_mem), .WBdata_Mout(WBData_mem), 
    .RegWr_Mout(regWr_mem), .MemRd_Mout(memRd_mem), .MemWr_Mout(memWr_mem),
    .PC_EX(pc_ex),.PC_MEM(pc_mem),.Special_IN(Special_DW_EM),.Special_OUT(Special_DW_M)
  );

  // === Memory Stage ===
  Memory Memory_Stage(
    .clk(clk), .alu_Result(Buffer_EX), .Rd(Rd_mem), .regW(regWr_mem), .dataIn(Data_of_SRC2_out),
    .pc(pc_mem), .MR(memRd_mem), .MW(memWr_mem),.WBData(WBData_mem), 
    .regW_mem(regWr_WB1), .DataOut(memOut), .Rd_mem(Rd_WB), .WBData_mem(WBData_WB),.Special_IN(Special_DW_M),.Special_OUT(Special_DW_MW)
  );

  MEM_to_WB WB_Stage(.clk(clk), .WBData_Min(memOut), 
  .RegWr_Min(regWr_WB1), .Rd4_in(Rd_WB), .WBData_Wout(WBForward),
  .RegWr_Wout(regWr_wb), .Rd4_out(Rd_wb),.Special_IN_WB(Special_DW_MW),.Special_OUT_WB(Special_DW_WB));

  
  
always @(posedge clk) begin
  // $display("\n================ Cycle %0t =================", $time);

  // $display("IF->| PC = %-10d | Instruction = %h | Opcode %d |S = %b |K = %b ", PC, Inst_Fetch, Inst_Fetch[31:26], stallout, killout);
  // $display("SPDW = %0b ", Special_DW);
  // // === Instruction Decode (ID) ===
  // $display("ID->| PC = %-10d | ImmExt = %-10d | Opcode = %02h | ZF= %b LTZF = %b", PC_ID, Imm_Ext, Opcode,ZF,LTZF);
  // $display("    | Rs = %0d | Rt = %0d | Rd = %0d | Selected Reg = %0d", Rs, Rt, Rd, Selected_R);
  // $display("    | src1 = %-10d | src2 = %-10d SPDW = %0b", SRC1, SRC2,Special_DW_D);
  // $display("    | RegDst = %b | ALUSrc = %b | ALUOp = %b | RegWr = %b | MemRd = %b | MemWr = %b | WBData = %b",
  //          RegDst, ALUSrc, ALUOp, RegWr, MemRd, MemWr, WBData);

  // // === Execute (EX) ===
  // $display("EX->| PC = %-10d | ALUResult = %-10d | DATA OF SRC2 = %0d , SPDW = %0b", pc_ex, Result_EX,SRC2_OUT,Special_DW_EX);
  // $display("    | regDst = %0d | WBData = %b | ZeroFlag = %b", regDst_ex, WBData_ex);
  // $display("    | RegWr = %b | MemRd = %b | MemWr = %b | ALUOp = %b", regWr_ex, memRd_ex, memWr_ex, ALUOp_EX);

  // // === Memory Access (MEM) ===
  // $display("MEM->| PC = %-10d | MemOut = %-10d", pc_mem, memOut);
  // $display("     | regDst = %0d | MemRd = %b | MemWr = %b | RegWr = %0b | WBData = %b",
  //          Rd_mem, memRd_mem, memWr_mem, regWr_WB1, WBData_mem);

  // // === Write Back (WB) ===
  // $display("WB-> | PC = %-10d | Data = %-10d | RegDst = %0d | RegWr = %b", pc_mem-1, WBForward, Rd_wb, regWr_wb);
  // $display("PCs: IF=%0d ID=%0d EX=%0d MEM=%0d WB=%0d", PC, PC_ID, pc_ex, pc_mem,pc_mem-1);
  // $display("Special_DW pipeline signals: Fetch=%b, D=%b, DE=%b, EM=%b, M=%b, MW=%b, WB=%b",
  //          Special_DW, Special_DW_D, Special_DW_DE, Special_DW_EM, Special_DW_M, Special_DW_MW, Special_DW_WB);

  //   $display("Time: %0t | MemRd: D=%b, ID_EX=%b, EX=%b, EX_MEM=%b, MEM=%b",
  //          $time, MemRd, MemRd_EX, memRd_ex, memRd_mem, memRd_mem);


end

endmodule

