# Copyright cocotb contributors
# Copyright (c) 2013 Potential Ventures Ltd
# Copyright (c) 2013 SolarFlare Communications Inc
# Licensed under the Revised BSD License, see LICENSE for details.
# SPDX-License-Identifier: BSD-3-Clause

TOPLEVEL_LANG ?= verilog

# export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)

VERILOG_SOURCES = $(wildcard ../src/*.v)
COCOTB_TOPLEVEL     := $(notdir $(basename $(VERILOG_SOURCES)))
COCOTB_TEST_MODULES := $(notdir $(basename $(wildcard ./*.py)))

include $(shell cocotb-config --makefiles)/Makefile.sim
