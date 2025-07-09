`timescale 1ns / 1ps
module Processor_tb;


  reg clk;

  Processor Pipelined_Processor (clk);

  initial clk = 0;
  always #5 clk = ~clk;
  

  initial begin
    $display("Starting Processor Simulation...");
    $dumpfile("Processor.vcd");
    $dumpvars(0, Processor_tb);

    #350;

    $display("Ending Simulation.");
    $finish;
  end

endmodule