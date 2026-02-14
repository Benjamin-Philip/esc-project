VERILOG_SOURCES := $(wildcard src/*.v)
MODULES := $(notdir $(basename $(VERILOG_SOURCES)))

OUT_DIR := out
AUX_DIR := out/aux
WAVES_DIR := $(AUX_DIR)/waves
RTL_DIR := $(AUX_DIR)/rtl
IMG_DIR := $(OUT_DIR)/img

all: waves rtl
waves: $(foreach mod, $(MODULES), $(IMG_DIR)/$(mod)-waves.pdf)
rtl: $(foreach mod, $(MODULES), $(IMG_DIR)/$(mod)-rtl.pdf)

#########
# Waves #
#########

$(WAVES_DIR)/%.fst: $(VERILOG_SOURCES) test/test_%.py
	$(MAKE) -C test MOD=$* WAVES=1
	@mkdir -p $(WAVES_DIR)
	cp $(AUX_DIR)/cocotb/$*/sim_build/$*.fst $@

%.vcd: %.fst
	fst2vcd -f $< -o $@

$(WAVES_DIR)/%.json: $(WAVES_DIR)/%.vcd
	python -m vcd2wavedrom.vcd2wavedrom -i $< -o $@
	jq 'del(.signal[] | select(.name | test(".*\\..*\\.")))' $@ > $@.tmp
	mv $@.tmp $@

$(WAVES_DIR)/adder_subtractor.json: $(WAVES_DIR)/adder_subtractor.vcd
	python -m vcd2wavedrom.vcd2wavedrom -i $< -o $@
	jq 'del(.signal[] | select(.name | test(".*\\..*\\."))) | .config.hscale = 4' $@ > $@.tmp
	mv $@.tmp $@

$(WAVES_DIR)/%.svg: $(WAVES_DIR)/%.json
	wavedrom-cli -i $< -s $@

$(IMG_DIR)/%-waves.pdf: $(WAVES_DIR)/%.svg
	@mkdir -p $(IMG_DIR)
	rsvg-convert -f pdf -o $@ $<

#######
# RTL #
#######

$(RTL_DIR)/%.json: $(VERILOG_SOURCES)
	@mkdir -p $(RTL_DIR)
	yosys -p "prep -top $*; opt_clean; write_json -selected $@" $(VERILOG_SOURCES)

$(RTL_DIR)/adder_subtractor.svg: $(RTL_DIR)/adder_subtractor.json
	netlistsvg $< -o $@
	sed -i 's/0x0/0/g' $@
	sed -i 's/0x10000000000000000/1/g' $@

$(RTL_DIR)/%.svg: $(RTL_DIR)/%.json
	netlistsvg $< -o $@

$(IMG_DIR)/%-rtl.pdf: $(RTL_DIR)/%.svg
	@mkdir -p $(IMG_DIR)
	rsvg-convert -f pdf -o $@ $<


.PHONY: clean
clean:
	rm -rf $(OUT_DIR)
