#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer
import random as rand


@cocotb.test()
async def random(dut):
    for i in range(5):
        a = await randint()
        b = await randint(upto=a)
        sub = await randint(upto=1)
        await test_case(dut, a, b, sub)


async def test_case(dut, a, b, sub):
    dut.a.value = a
    dut.b.value = b
    dut.sub.value = sub
    await Timer(2, unit="ps")

    val = a + b if sub == 0 else a - b
    sum = bin(val)[2:].zfill(64)[-64:]

    result = str(dut.sum.value)
    status = result == sum
    cocotb.log.debug(f"{a=}; {b=}, {sub=}, {sum=}, {result=}, {status=}")

    assert result == sum


async def randint(upto=2**64 - 1):
    return rand.randint(0, upto)
