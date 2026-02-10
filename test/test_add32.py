#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer
import random as rand


@cocotb.test()
async def random(dut):
    for i in range(10):
        a = await randint()
        b = await randint()
        cin = await randint(upto=1)
        await test_case(dut, a, b, cin)


@cocotb.test()
async def carry_both(dut):
    await test_case(dut, 2**32 - 1, 2**32 - 1, 0)
    await test_case(dut, 2**32 - 1, 2**32 - 1, 1)


async def test_case(dut, a, b, cin):
    dut.a.value = a
    dut.b.value = b
    dut.cin.value = cin

    await Timer(2, unit="ps")

    result = bin(a + b + cin)[2:].zfill(33)
    sum = result[1:]
    cout = result[0]

    cocotb.log.debug(f"{a=:b}, {b=:b}, {cin=}, {sum=}, {cout=}, {result=}")

    assert dut.sum.value == sum, f"{dut.sum.value} not equal to expected sum {sum}"
    assert dut.cout.value == cout, f"{dut.cout.value} not equal to expected cout {cout}"


async def randint(upto=2**32 - 1):
    return rand.randint(0, upto)
