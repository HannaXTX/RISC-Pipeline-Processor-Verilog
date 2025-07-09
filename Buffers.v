module IF_to_ID(clk,INST_Fin, PC_Fin, stall, kill, INST_Dout, PC_Dout,Special_IN,Special_OUT);
  input clk,stall,kill,Special_IN;
  input [31:0] INST_Fin,PC_Fin;
  output reg [31:0] INST_Dout, PC_Dout;
  output reg Special_OUT;
always @(posedge clk) begin
  if (!stall) begin
    if (kill)
      INST_Dout <= 32'hDEADDEAD;
    else
      INST_Dout <= INST_Fin;
    PC_Dout <= PC_Fin;
    Special_OUT <= Special_IN;

    // $display("Time=%0t, stall=%b, kill=%b, INST_Dout=%h, PC_Dout=%0d, INST_Fin=%h, PC_Fin=%0d",
    //          $time, stall, kill, INST_Dout, PC_Dout, INST_Fin, PC_Fin);
  end
end

endmodule


module ID_to_EX (
  input clk,
  input stall,
  input [3:0] Rd2_in,
  input [31:0] BA_Din, BB_Din,Imm_Din,PC_B_ID_EXin,
  input RegDst_D, RegWr_D, ExtOp_D, ALUSrc_D, MemRd_D, MemWr_D,Special_IN,
  input [1:0] ALUOp_D,WBdata_D,
  output reg [3:0] Rd2_out,
  output reg [31:0] BA_Eout, BB_Eout,Imm_Eout,PC_B_ID_EXout,
  output reg RegDst_EX, RegWr_EX, ExtOp_EX, ALUSrc_EX, MemRd_EX, MemWr_EX,Special_OUT,
  output reg [1:0] ALUOp_EX,WBdata_EX
);

  always @(posedge clk) begin
    if (!stall) begin
      {RegDst_EX, RegWr_EX, ExtOp_EX, ALUSrc_EX, MemRd_EX, MemWr_EX,
       WBdata_EX, ALUOp_EX,PC_B_ID_EXout,Special_OUT} =
      {RegDst_D,  RegWr_D,  ExtOp_D,  ALUSrc_D,  MemRd_D,  MemWr_D,  
      WBdata_D,  ALUOp_D,PC_B_ID_EXin, Special_IN};

      BA_Eout   <= BA_Din;
      BB_Eout   <= BB_Din;
      Imm_Eout <= Imm_Din;
      Rd2_out <= Rd2_in;


    end
    else begin
      {RegDst_EX, RegWr_EX, ExtOp_EX, ALUSrc_EX,
      MemRd_EX, MemWr_EX, WBdata_EX, ALUOp_EX} <= 0;

      BA_Eout   <= BA_Din;
      BB_Eout   <= BB_Din;
      Imm_Eout <= Imm_Din;
      Rd2_out <= Rd2_in;
    end
    
//          5fs $display("Time=%0t | stall=%b | Rd2_in=%b | BA_Din=%h | BB_Din=%h | Imm_Din=%h | RegDst_D=%b | RegWr_D=%b | ExtOp_D=%b | ALUSrc_D=%b | MemRd_D=%b | MemWr_D=%b | WBdata_D=%b | ALUOp_D=%b || Rd2_out=%b | BA_Eout=%h | BB_Eout=%h | Imm_Eout=%h | RegDst_EX=%b | RegWr_EX=%b | ExtOp_EX=%b | ALUSrc_EX=%b | MemRd_EX=%b | MemWr_EX=%b | WBdata_EX=%b | ALUOp_EX=%b",
//       $time, stall, Rd2_in, BA_Din, BB_Din, Imm_Din,
//       RegDst_D, RegWr_D, ExtOp_D, ALUSrc_D, MemRd_D, MemWr_D, WBdata_D, ALUOp_D,
//       Rd2_out, BA_Eout, BB_Eout, Imm_Eout,
//       RegDst_EX, RegWr_EX, ExtOp_EX, ALUSrc_EX, MemRd_EX, MemWr_EX, WBdata_EX, ALUOp_EX
//     );
end

endmodule


module EX_to_MEM(clk,Alu_Ein,Data_Ein,Rd3_in,RegWr_Ein,MemRd_Ein,MemWr_Ein,WBdata_Ein,
                 Alu_Mout,Data_Mout,Rd3_out,WBdata_Mout,RegWr_Mout,
                  MemRd_Mout, MemWr_Mout,PC_EX,PC_MEM,Special_IN,Special_OUT); 
  
  input clk,RegWr_Ein,MemRd_Ein,MemWr_Ein;
  input [31:0] Alu_Ein,Data_Ein,PC_EX;
  input [3:0] Rd3_in;
  input [1:0] WBdata_Ein;
  output reg [31:0] Alu_Mout,Data_Mout;
  output reg [1:0] WBdata_Mout;
  output reg RegWr_Mout, MemRd_Mout, MemWr_Mout;
  output reg [3:0] Rd3_out;
  output reg [31:0] PC_MEM;
  input Special_IN;
  output reg Special_OUT;
  
 always @(posedge clk) begin
  {RegWr_Mout, MemRd_Mout, MemWr_Mout, WBdata_Mout, Rd3_out, Data_Mout, Alu_Mout, PC_MEM,Special_OUT} <=
  {RegWr_Ein,  MemRd_Ein,  MemWr_Ein,  WBdata_Ein,  Rd3_in,  Data_Ein,  Alu_Ein, PC_EX,Special_IN};
  end
endmodule


module MEM_to_WB(clk,WBData_Min,RegWr_Min,Rd4_in,WBData_Wout,RegWr_Wout,Rd4_out,Special_IN_WB,Special_OUT_WB);
  input clk,RegWr_Min;
  input [3:0] Rd4_in;
  input [31:0] WBData_Min;
  input Special_IN_WB;
  output reg Special_OUT_WB;
  output reg RegWr_Wout;
  output reg [3:0] Rd4_out;
  output reg [31:0] WBData_Wout;

  // initial Special_OUT_WB=0;
  
    
  always @(posedge clk)begin
    {RegWr_Wout,Rd4_out,WBData_Wout,Special_OUT_WB}<={RegWr_Min,Rd4_in,WBData_Min,Special_IN_WB};
  end
  // always @(*)begin
  //    = Special_IN_WB;
  // end


  
  
endmodule

