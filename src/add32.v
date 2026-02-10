module add32 (
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);

   wire carry;

   add16 lower_byte (
       a[15:0],
       b[15:0],
       cin,
       sum[15:0],
       carry
   );
   add16 upper_byte (

       a[31:16],
       b[31:16],
       carry,
       sum[31:16],
       cout
   );
endmodule
