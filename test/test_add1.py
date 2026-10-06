#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer
from itertools import product


@cocotb.test()
async def add1_truth_table_test(dut):
    for a, b, cin in product([0, 1], repeat=3):
        await test_case(dut, a, b, cin)


async def test_case(dut, a, b, cin):
    dut.a.value = a
    dut.b.value = b
    dut.cin.value = cin

    await Timer(2, unit="ps")

    result = bin(a + b + cin)[2:].zfill(2)
    sum = result[-1]
    cout = result[-2]

    cocotb.log.debug(f"{a=}, {b=}, {cin=}, {sum=}, {cout=}, {result=}")

    assert dut.sum.value == sum
    assert dut.cout.value == cout
