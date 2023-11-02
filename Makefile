## Directories

HDL_DIR := hdl
IP_DIR := ip
SIM_DIR := sim
OBJ_DIR := obj
XDC_DIR := xdc

# Source Files

HDL_FILES := $(wildcard $(HDL_DIR)/*)
IP_FILES := $(wildcard $(IP_DIR)/*/*.xci)

# User input for the testbench file when running simulate

TB_FILE := 

build: $(HDL_FILES) $(IP_FILES)
	./remote/r.py build.py build.tcl $(HDL_FILES) $(IP_FILES) $(XDC_DIR)/top_level.xdc $(OBJ_DIR)/

.PHONY: simulate
simulate: $(HDL_FILES) $(IP_FILES)
	if [ -z "$(TB_NAME)" ]; \
	then\
		echo "Please provide a TB_NAME";\
	else\
		iverilog -g2012 -o $(SIM_DIR)/$(TB_NAME).out $(HDL_FILES) $(IP_FILES);\
		vvp $(SIM_DIR)/$(TB_NAME).out;\
	fi

.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)/* *.vcd $(SIM_DIR)/*.out