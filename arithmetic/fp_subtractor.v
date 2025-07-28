module fp_subtractor(
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] diff
);
  // Module-level intermediate signals
  reg        sign_a, sign_b;
  reg [7:0]  exp_a, exp_b;
  reg [22:0] frac_a, frac_b;
  reg [23:0] mant_a, mant_b;
  
  reg [7:0]  exp_diff;
  reg [23:0] mantissa_small, mantissa_large;
  reg [7:0]  exp_large;
  reg        sign_large;
  reg [24:0] mantissa_sum;  // Extra bit for possible carry or borrow
  integer    i;
  
  always @(*) begin
    // 1. Extract fields from the operands.
    // a remains unchanged; for subtraction, we treat it as a + (-b).
    sign_a = a[31];
    // Invert the sign bit of b to represent -b.
    sign_b = ~b[31];
    exp_a  = a[30:23];
    exp_b  = b[30:23];
    frac_a = a[22:0];
    frac_b = b[22:0];

    // For normalized numbers, add the implicit '1'.
    // For denormalized numbers (exp==0), use the fraction as-is.
    mant_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    mant_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    // 2. Align the exponents.
    if(exp_a > exp_b) begin
      exp_diff       = exp_a - exp_b;
      mantissa_large = mant_a;
      mantissa_small = mant_b >> exp_diff;
      exp_large      = exp_a;
      sign_large     = sign_a;
    end
    else begin
      exp_diff       = exp_b - exp_a;
      mantissa_large = mant_b;
      mantissa_small = mant_a >> exp_diff;
      exp_large      = exp_b;
      sign_large     = sign_b;
    end

    // 3. Perform addition or subtraction.
    // Since we computed a + (-b), if the signs are the same, add the mantissas.
    if(sign_a == sign_b) begin
      mantissa_sum = mantissa_large + mantissa_small;
    end
    else begin
      // Different signs: subtract the smaller magnitude from the larger.
      if(mantissa_large >= mantissa_small) begin
        mantissa_sum = mantissa_large - mantissa_small;
      end
      else begin
        mantissa_sum = mantissa_small - mantissa_large;
        sign_large   = ~sign_large;  // The result takes the sign of the operand with the larger magnitude.
      end
    end

    // 4. Normalize the result.
    // If there is a carry-out from addition, shift right and increment the exponent.
    if(mantissa_sum[24] == 1'b1) begin
      mantissa_sum = mantissa_sum >> 1;
      exp_large    = exp_large + 1;
    end
    else begin
      // Otherwise, shift left until the MSB is 1 (or the exponent reaches zero).
      for(i = 0; i < 24; i = i + 1) begin
        if(mantissa_sum[23] == 1'b0 && exp_large > 0) begin
          mantissa_sum = mantissa_sum << 1;
          exp_large    = exp_large - 1;
        end
      end
    end

    // 5. Assemble the final IEEE‑754 result.
    diff[31]    = sign_large;
    diff[30:23] = exp_large;
    diff[22:0]  = mantissa_sum[22:0];
  end

endmodule