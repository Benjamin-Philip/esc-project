VERILOG_SOURCES := $(wildcard src/*.v)
MODULES := $(notdir $(basename $(VERILOG_SOURCES)))

OUT_DIR := out
AUX_DIR := out/aux
WAVES_DIR := $(AUX_DIR)/waves
RTL_DIR := $(AUX_DIR)/rtl
IMG_DIR := $(OUT_DIR)/img

all: waves rtl
waves: $(foreach mod, $(MODULES), $(WAVES_DIR)/$(mod).fst)
rtl: $(foreach mod, $(MODULES), $(IMG_DIR)/$(mod).pdf)

$(WAVES_DIR)/%.fst: $(VERILOG_SOURCES) test/test_%.py
	$(MAKE) -C test MOD=$* WAVES=1
	-mkdir -p $(WAVES_DIR)
	cp $(AUX_DIR)/cocotb/$*/sim_build/$*.fst $@

$(RTL_DIR)/%.json: $(VERILOG_SOURCES)
	-mkdir -p $(RTL_DIR)
	yosys -p "prep -top $*; opt_clean; write_json -selected $@" $(VERILOG_SOURCES)

$(RTL_DIR)/adder_subtracter.svg: $(RTL_DIR)/adder_subtracter.json
	netlistsvg $< -o $@
	sed -i 's/0x0/0/g' $@
	sed -i 's/0x10000000000000000/1/g' $@

%.svg: %.json
	netlistsvg $< -o $@

$(IMG_DIR)/%.pdf: $(RTL_DIR)/%.svg
	inkscape --export-type=pdf --export-filename=$@ $< 


.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
