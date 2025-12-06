`timescale 1ns / 1ps

module counter_tb;
  logic clk = 0;
  logic rst = 1;
  logic enable = 0;
  logic [7:0] value;

  // Instantiate DUT
  counter #(
      .WIDTH(8)
  ) dut (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .value(value)
  );

  // Clock generator: 100MHz
  always #5 clk = ~clk;

  initial begin
    $dumpfile("counter.vcd");
    $dumpvars(0, counter_tb);

    // Reset for 20ns
    #12 rst = 0;

    // Enable counting
    #10 enable = 1;

    // Run for a bit
    #100;

    $finish;
  end

endmodule

