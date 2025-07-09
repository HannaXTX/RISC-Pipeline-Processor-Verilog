module DataMemory(
  input clk,
  input [31:0] address, data_in,
  input MW, MR,
  output reg [31:0] data_out
);
  
  reg [31:0] Memory [10:0];
  integer i;
  
  initial begin
    $readmemh("DF.dat", Memory);
  end 

 always @(*) begin
  if (MR) begin
    data_out = Memory[address];
    $display("READ from MEM[%0d] = %0d", address, data_out);
  end 
  else 
    data_out = 32'h00000000;

end

  always @(posedge clk) begin 
    if (MW) begin
      Memory[address] = data_in;
      $display("WROTE %0d TO MEM[%0d]", data_in, address);


      // Display all memory values after write
        // $display("\nMemory contents at time = %0t:\n", $time);
      for (i = 0; i <= 10; i = i + 1) begin
        $display("M[%0d] = %0d", i, Memory[i]);
      end
    end
  end

endmodule




// module DataMemory_tb();

//   reg clk = 0;
//   reg [31:0] address;
//   reg [31:0] data_in;
//   reg MW, MR;
//   wire [31:0] data_out;

//   DataMemory uut (
//     .clk(clk),
//     .address(address),
//     .data_in(data_in),
//     .MW(MW),
//     .MR(MR),
//     .data_out(data_out)
//   );

//   always #5 clk = ~clk;

//   initial begin

//     $display("Starting test...");
//     MR = 0; MW = 0;

//     #10;


//     address = 32'd0; MR = 1;
//     #10 $display("Read MEM[0] = %0d", data_out);

//     MR = 0; MW = 1;
//     address = 32'd4; 
//     data_in = 32'd12345;
//     #10 MW = 0;

//     MR = 1;
//     #10 $display("Read MEM[1] after write = %0d", data_out);

//     $finish;
//   end

// endmodule
  
  
