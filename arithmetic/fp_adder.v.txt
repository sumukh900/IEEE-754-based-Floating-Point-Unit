module fp_adder(
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] sum
);
  // Declare all intermediate signals at module level.
  reg        sign_a, sign_b;
  reg [7:0]  exp_a, exp_b;
  reg [22:0] frac_a, frac_b;
  reg [23:0] mant_a, mant_b;
  
  reg [7:0]  exp_diff;
  reg [23:0] mantissa_small, mantissa_large;
  reg [7:0]  exp_large;
  reg        sign_large;
  reg [24:0] mantissa_sum;  // Extra bit for possible carry
  integer    i;
  
  always @(*) begin
    // 1. Extract sign, exponent, and fraction fields.
    sign_a = a[31];
    sign_b = b[31];
    exp_a  = a[30:23];
    exp_b  = b[30:23];
    frac_a = a[22:0];
    frac_b = b[22:0];

    // For normalized numbers, the mantissa has an implicit '1'.
    // For denormalized numbers (exp == 0), we use the fraction directly.
    mant_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    mant_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    // 2. Align exponents.
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

    // 3. Perform addition or subtraction depending on sign.
    if(sign_a == sign_b) begin
      // Same sign: add mantissas.
      mantissa_sum = mantissa_large + mantissa_small;
    end
    else begin
      // Different signs: subtract the smaller from the larger.
      if(mantissa_large >= mantissa_small) begin
        mantissa_sum = mantissa_large - mantissa_small;
      end
      else begin
        mantissa_sum = mantissa_small - mantissa_large;
        sign_large   = ~sign_large;  // Result takes the sign of the larger magnitude.
      end
    end

    // 4. Normalize the result.
    // If addition produced a carry out, shift right and increment exponent.
    if(mantissa_sum[24] == 1'b1) begin
      mantissa_sum = mantissa_sum >> 1;
      exp_large    = exp_large + 1;
    end
    else begin
      // Normalize by left-shifting until the MSB is 1 or exponent reaches zero.
      for(i = 0; i < 24; i = i + 1) begin
        if(mantissa_sum[23] == 1'b0 && exp_large > 0) begin
          mantissa_sum = mantissa_sum << 1;
          exp_large    = exp_large - 1;
        end
      end
    end

    // 5. Assemble the final result.
    // Drop the implicit bit (bit 23) for the fraction field.
    sum[31]    = sign_large;
    sum[30:23] = exp_large;
    sum[22:0]  = mantissa_sum[22:0];
  end

endmodule