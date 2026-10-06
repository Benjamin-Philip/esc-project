#!/usr/bin/env python3

import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def no_carry(dut):
    await test_case(dut, 0b1010, 0b0101, 0b0)
    await test_case(dut, 0b10101010, 0b01010101, 0b0)


@cocotb.test()
async def with_carry(dut):
    await test_case(dut, 0b1011, 0b1111, 0b0)
    await test_case(dut, 0b10110101, 0b01001111, 0b0)


@cocotb.test()
async def with_carry_in(dut):
    await test_case(dut, 0b1010, 0b0101, 0b1)
    await test_case(dut, 0b10101010, 0b01010101, 0b1)


@cocotb.test()
async def with_carry_out(dut):
    await test_case(dut, 0b10001011, 0b10001111, 0b0)
    await test_case(dut, 0b10110101, 0b11001111, 0b0)


@cocotb.test()
async def all(dut):
    await test_case(dut, 0b10001011, 0b10001111, 0b1)
    await test_case(dut, 0b10110101, 0b11001111, 0b1)


async def test_case(dut, a, b, cin):
    dut.a.value = a
    dut.b.value = b
    dut.cin.value = cin

    await Timer(2, unit="ps")

    result = bin(a + b + cin)[2:].zfill(9)
    sum = result[1:]
    cout = result[0]

    cocotb.log.debug(f"{a=}, {b=}, {cin=}, {sum=}, {cout=}, {result=}")

    assert dut.sum.value == sum
    assert dut.cout.value == cout
