module adder_subtracter (
    input [63:0] a,
    input [63:0] b,
    input sub,
    output [63:0] sum
);

   wire [63:0] b_final;
   assign b_final = b ^ {64{sub}};

   carry_select_adder adder (
       a,
       b_final,
       sub,
       sum
   );
endmodule
