module InstructionMemory(input [31:0] address, output reg [31:0] instruction);
  
  reg [31:0] Memory[63:0]; 

  initial begin 
    $readmemh("IM.dat", Memory);
    $display("Instruction Memory Initialized");
  end

  always @(*) begin 
    instruction = Memory[address]; 
    // $display("1.Fetching Instruction at address %0d: %h", address, instruction);
  end

endmodule

