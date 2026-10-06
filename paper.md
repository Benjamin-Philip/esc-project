---
title: A 64-bit Adder-Subtractor
author:
    - Balu Nayak (B08)
    - Bathini Bhargava (B10)
    - Benjamin Philip (B11)
    - Abhinanthan Reddy (B22)
    - Bysani Pranay (B27)
    - Sai Harshit (B32)
    - Ramith B M (B60)
    - Chiranth D S (B71)
abstract: |
    This project presents the design and implementation of a high-performance **64-bit
    Adder-Subtractor**, a core component of the Arithmetic Logic Unit (ALU). Utilizing **Two’s
    Complement** logic, the circuit performs both operations through a unified hardware
    architecture where a mode-select signal toggles between addition and subtraction. 
    The design integrates XOR-based bitwise inversion with a parallel adder—such as a **Carry
    Select** along with a **Ripple Carry** architecture—to optimize for propagation delay, as
    well  as area, and  power efficiency. Verified through Icarus Verilog and CocoTB,
    the module provides a scalable and robust solution for large-integer arithmetic in modern
    64-bit processors.
# documentclass: extreport
# classoption:
#     - 14pt
#     - a4paper
#     - twoside
geometry: margin=1in
---
# 1-bit Adder

The 1-bit Adder forms the basis of any multi-bit adder. The simplest adder has
the following truth table:

| A | B | Sum |
|---+---+-----|
| 0 | 0 |  0  |
| 0 | 1 |  1  |
| 1 | 0 |  1  |
| 1 | 1 |  0  |

The last row has a sum of 0 since the sum is 2 (base 10), which must be carried
over in binary. Clearly, the sum is 1 only when A or B, but not both have the
value 1. This matches the description of the XOR gate. However, how do we convey
a sum of 2 instead of 0? This introduces the concept of `Cout` or carry out to
the truth table:

| A | B | Sum | Cout |
|---+---+-----+------|
| 0 | 0 |  0  |   0  |
| 0 | 1 |  1  |   0  |
| 1 | 0 |  1  |   0  |
| 1 | 1 |  0  |   1  |

`Cout` only has a value of 1 when both A and B have 1. Thus, Cout is an AND
gate. If we handle carry-outs, we must handle carry-ins as well, giving us the
full truth table:

| A | B | Cin | Sum | Cout |
|---+---+-----+-----+------|
| 0 | 0 |  0  |  0  |   0  |
| 0 | 1 |  0  |  1  |   0  |
| 1 | 0 |  0  |  1  |   0  |
| 1 | 1 |  0  |  0  |   1  |
| 0 | 0 |  1  |  1  |   0  |
| 0 | 1 |  1  |  0  |   1  |
| 1 | 0 |  1  |  1  |   0  |
| 1 | 1 |  1  |  1  |   1  |

Now, sum is 1 only when the sum of A and B or Cin is 1, but not both, i.e. `(A XOR B) XOR Cin`.
cout is 1 when a pair of 1s can be found, i.e. `(A AND B) OR (A AND Cin) OR (B and Cin)`.
With, this we can design our 1-bit adder:

![1-bit adder schematic](./out/img/add1-rtl.pdf)

Which translates into the following verilog module:

```verilog{include="src/add1.v"}
```

Simulating the above truth table, we get the following timing diagram:

![1-bit adder timing diagram](./out/img/add1-waves.pdf)

# 8-bit Adder

To build an 8-bit adder, we accept 8 wires for A and B each. We then use 8 1-bit
adders for each place, and pass the carry from each place into the succeeding
place. This is called a Ripple-Carry Adder: 

![8-bit adder schematic](./out/img/add8-rtl.pdf)

Implementing the verilog module:

```verilog{include="src/add8.v"}
```

and simulating with random inputs, we get the following timing diagram^[All values henceforth are in hexadecimal for brevity. Results can be verified with any hexadecimal calculator.]:

![8-bit adder timing diagram](./out/img/add8-waves.pdf)

# 16 and 32-bit Adders
## 16-bit Adder

We can build the 16-bit adder by taking 2 8-bit adders serially connected
together. The first 8 most significant bits are passed into the `upper_byte`
adder and the rest into the `lower_byte` adder.

![16-bit adder schematic](./out/img/add16-rtl.pdf)

Implementing the verilog module:

```verilog{include="src/add16.v"}
```

and simulating with random inputs:

![16-bit adder timing diagram](./out/img/add16-waves.pdf)

## 32-bit Adder

We repeat the same for the 32-bit adder, using the 16-bit adder instead of the
8-bit one:

![32-bit adder schematic](./out/img/add32-rtl.pdf)

Implementing the verilog module:

```verilog{include="src/add32.v"}
```

and simulating with random inputs:

![32-bit adder timing diagram](./out/img/add32-waves.pdf)

# 64-bit Carry-Select Adder

However, we do not repeat the same pattern for 64-bit adder. In the Ripple-Carry
architecture, the last bit has to wait for all preceding bits to be computed.
This adds significant delays for adders of 64-bit, 128-bit, and larger integer
adders. 

Instead, we replace the sequential `upper_bytes` calculation in the pattern, and
we calculate the `upper_bytes` with carry and without carry. We then select the
upper bytes to use based on the lower bytes' carry using a 2-1 multiplexer:

![64-bit carry-select adder schematic](./out/img/carry_select_adder-rtl.pdf)

Since we compute the upper bytes in parallel to the lower bytes, we get a $2x$
speed improvement over a Ripple-Carry design, for a $1.5x$ increase in area and
power (3 32-bit adders instead of 2).

Implementing the verilog module:

```verilog{include="src/carry_select_adder.v"}
```

and simulating with random inputs:

![64-bit carry-select adder timing diagram](./out/img/carry_select_adder-waves.pdf)

# 64-bit Adder-Subtractor

Finally, to support subtraction, we selectively apply 2's complement on `B` based on the value of a new 1-bit input, `sub` using a multiplexer. In order to apply 2's complement on B, we must find B's 1's complement and add 1. This means negating every bit of `B`, and passing 1 as `cin` to the Carry-Select Adder:

![64-bit adder-subtractor schematic](./out/img/adder_subtractor-rtl.pdf)

This design only supports unsigned inputs and outputs. Therefore all results for
$A < B$ are invalid.

Implementing the verilog module:

```verilog{include="src/adder_subtractor.v"}
```

and simulating with random inputs:

![64-bit adder-subtractor timing diagram](./out/img/adder_subtractor-waves.pdf)

# Result and Conclusion

A fast 64-bit Adder-Subtractor supporting unsigned 64-bit integer addition and
subtraction was implemented. Possible improvements include signed integer
support, and a hybrid carry-select carry-lookahead design.

# Appendix: Software Bill of Materials

Design simulation:

- Icarus Verilog
- CocoTB testbench enviroment

Schematic rendering:

- Yosys synthesis suite
- netlistsvg renderer

Timing diagram rendering:

- GTKWave's fst2vcd converter
- A custom vcd2wavejson converter
- wavedrom-cli

Document Typesetting:

- Pandoc document converter
- LuaLaTeX pdf engine
- rsvg-convert

General environment:

- Fedora 43
- GNU make
- git
