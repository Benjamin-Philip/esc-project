module add16 (
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);

   wire carry;

   add8 lower_byte (
       a[7:0],
       b[7:0],
       cin,
       sum[7:0],
       carry
   );
   add8 upper_byte (

       a[15:8],
       b[15:8],
       carry,
       sum[15:8],
       cout
   );
endmodule
