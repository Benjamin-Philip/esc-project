# Copyright cocotb contributors
# Copyright (c) 2013 Potential Ventures Ltd
# Copyright (c) 2013 SolarFlare Communications Inc
# Licensed under the Revised BSD License, see LICENSE for details.
# SPDX-License-Identifier: BSD-3-Clause

TOPLEVEL_LANG ?= verilog

# export PYTHONPATH := $(PWD)/../model:$(PYTHONPATH)
export PYTHONDONTWRITEBYTECODE := 1

COCOTB_DIR := ../out/aux/cocotb

VERILOG_SOURCES = $(wildcard ../src/*.v)
COCOTB_TOPLEVEL := $(MOD)
COCOTB_TEST_MODULES := test_$(MOD)

COCOTB_RESULTS_FILE := $(COCOTB_DIR)/$(MOD)/results.xml
SIM_BUILD := $(COCOTB_DIR)/$(MOD)/sim_build


include $(shell cocotb-config --makefiles)/Makefile.sim
