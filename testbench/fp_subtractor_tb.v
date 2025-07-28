`timescale 1ns/1ps
module fp_subtractor_tb;
  reg  [31:0] a, b;
  wire [31:0] diff;
  
  // Instantiate the subtractor module.
  fp_subtractor dut (
    .a(a),
    .b(b),
    .diff(diff)
  );
  
  initial begin
    // Display header information.
    $display("Time\t\t   a\t\t   b\t\t   diff");
    $monitor("%0t\t%h\t%h\t%h", $time, a, b, diff);
    
    // Test Case 1: 3.0 - 2.0 = 1.0
    // 3.0 in IEEE-754: 0x40400000, 2.0: 0x40000000, expected result: 0x3F800000
    a = 32'h40400000; b = 32'h40000000;
    #10;
    
    // Test Case 2: 2.5 - (-1.5) = 4.0
    // 2.5 in IEEE-754: 0x40200000, -1.5: 0xBFC00000, expected result: 0x40800000
    a = 32'h40200000; b = 32'hBFC00000;
    #10;
    
    // Test Case 3: (-1.0) - (2.0) = -3.0
    // -1.0 in IEEE-754: 0xBF800000, 2.0: 0x40000000, expected result: 0xC0400000
    a = 32'hBF800000; b = 32'h40000000;
    #10;
    
    // Test Case 4: 1.0 - 1.0 = 0.0
    // 1.0 in IEEE-754: 0x3F800000
    a = 32'h3F800000; b = 32'h3F800000;
    #10;
    
    $finish;
  end
endmodule