module carry_select_adder (
    input [63:0] a,
    input [63:0] b,
    input cin,
    output [63:0] sum
);

   wire carry;

   add32 lower_byte (
       a[31:0],
       b[31:0],
       cin,
       sum[31:0],
       carry
   );

   wire [31:0] sum_no_carry;
   wire [31:0] sum_carry;
   wire [ 1:0] cout;

   add32 upper_byte_no_carry (
       a[63:32],
       b[63:32],
       1'b0,
       sum_no_carry,
       cout[0]
   );

   add32 upper_byte_carry (
       a[63:32],
       b[63:32],
       1'b1,
       sum_carry,
       cout[1]
   );

   assign sum[63:32] = carry ? sum_carry : sum_no_carry;
endmodule
