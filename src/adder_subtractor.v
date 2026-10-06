module adder_subtractor (
    input [63:0] a,
    input [63:0] b,
    input sub,
    output [63:0] sum
);

   wire [63:0] mask;
   wire [63:0] b_final;

   assign mask = sub ? ~64'b0 : 64'b0;
   assign b_final = b ^ mask;

   carry_select_adder adder (
       a,
       b_final,
       sub,
       sum
   );
endmodule
