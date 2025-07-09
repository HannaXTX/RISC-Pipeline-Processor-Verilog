module RegFile(clk, RegWr, A, B, W, BusW, BusA, BusB);

  input         clk;
  input         RegWr;
  input  [3:0]  A;
  input  [3:0]  B;
  input  [3:0]  W;
  input   [31:0] BusW;
  output reg [31:0] BusA;
  output reg [31:0] BusB;
	
  reg signed [31:0] regfile [14:0];

  always @(posedge clk) begin
    if (RegWr==1) begin
      regfile[W] = BusW;
      $display("RegFile: Writing %0d to R%-1d at time %0t", BusW, W, $time);
    end
  end

  always @(*) begin
      BusA = regfile[A];
      BusB = regfile[B];
  end
  
initial #1 $monitor(
  "\n[Time %0t] Register File:\n\
  -----------------------------------------\n\
  | R0 =%4d | R7  =%4d |\n\
  | R1 =%4d | R8  =%4d |\n\
  | R2 =%4d | R9  =%4d |\n\
  | R3 =%4d | R10 =%4d |\n\
  | R4 =%4d | R11 =%4d |\n\
  | R5 =%4d | R12 =%4d |\n\
  | R6 =%4d | R13 =%4d |\n\
  -----------------------------------------\n\
  | R14 (RA) = %4d      |\n\
  -----------------------------------------",
  $time,
  regfile[0],  regfile[7],
  regfile[1],  regfile[8],
  regfile[2],  regfile[9],
  regfile[3],  regfile[10],
  regfile[4],  regfile[11],
  regfile[5],  regfile[12],
  regfile[6],  regfile[13],
  regfile[14]
);
  
  initial begin
    for (integer i = 0;i<15;i++) regfile[i] = 32'h0000;
  end
	
endmodule
