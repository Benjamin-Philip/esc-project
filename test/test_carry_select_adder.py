#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer
import random as rand


@cocotb.test()
async def random(dut):
    for i in range(5):
        a = await randint()
        b = await randint()
        cin = await randint(upto=1)
        await test_case(dut, a, b, cin)


@cocotb.test()
async def carry_both(dut):
    await test_case(dut, 2**64 - 1, 2**64 - 1, 0)
    await test_case(dut, 2**64 - 1, 2**64 - 1, 1)


async def test_case(dut, a, b, cin):
    dut.a.value = a
    dut.b.value = b
    dut.cin.value = cin
    await Timer(2, unit="ps")

    sum = bin(a + b + cin)[2:].zfill(64)[-64:]
    cocotb.log.debug(f"{a=:b}, {b=:b}, {sum=}")

    assert str(dut.sum.value) == sum, f"{dut.sum.value} not equal to expected sum {sum}"


async def randint(upto=2**64 - 1):
    return rand.randint(0, upto)
