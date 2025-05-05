`timescale 1ns/1ps
module fp_adder_tb;
  reg  [31:0] a, b;
  wire [31:0] sum;
  
  // Instantiate the floating-point adder module.
  fp_adder dut (
    .a(a),
    .b(b),
    .sum(sum)
  );
  
  initial begin
    // Display header information
    $display("Time\t\t   a\t\t   b\t\t   sum");
    $monitor("%0t\t%h\t%h\t%h", $time, a, b, sum);
    
    // Test Case 1: 1.0 + 2.0
    // 1.0 in IEEE-754 single precision: 0x3F800000
    // 2.0 in IEEE-754 single precision: 0x40000000
    a = 32'h3F800000; b = 32'h40000000;
    #10;
    
    // Test Case 2: 3.5 + (-1.25)
    // 3.5 in IEEE-754: 0x40600000, -1.25 in IEEE-754: 0xBFA00000
    a = 32'h40600000; b = 32'hBFA00000;
    #10;
    
    // Test Case 3: (-1.5) + (-2.0)
    // -1.5 in IEEE-754: 0xBFC00000, -2.0 in IEEE-754: 0xC0000000
    a = 32'hBFC00000; b = 32'hC0000000;
    #10;
    
    // Test Case 4: 1.0 + 0.5
    // 1.0 in IEEE-754: 0x3F800000, 0.5 in IEEE-754: 0x3F000000
    a = 32'h3F800000; b = 32'h3F000000;
    #10;
    
    // End simulation
    $finish;
  end
endmodule