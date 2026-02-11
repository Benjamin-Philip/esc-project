VERILOG_SOURCES := $(wildcard src/*.v)
MODULES := $(notdir $(basename $(VERILOG_SOURCES)))

OUT_DIR := out
WAVES_DIR := $(OUT_DIR)/waves
AUX_DIR := out/aux

all: $(foreach mod, $(MODULES), $(WAVES_DIR)/$(mod).fst)

$(WAVES_DIR)/%.fst: $(VERILOG_SOURCES) test/test_%.py
	$(MAKE) -C test MOD=$* WAVES=1
	-mkdir -p $(WAVES_DIR)
	cp $(AUX_DIR)/$*/sim_build/$*.fst $@

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
