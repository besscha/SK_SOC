.DEFAULT_GOAL := Vsoc

./obj_dir/Vsoc: soc.sv test.cpp DRAM.cpp ALU.sv memory.sv branch.sv PC.sv regfile.sv decoder.sv param.vh 
	verilator -Wall soc.sv test.cpp -cc --exe --trace --top-module soc
	make -C obj_dir -f Vsoc.mk

.PHONY: Vsoc
Vsoc: ./obj_dir/Vsoc
	@./obj_dir/Vsoc

test_files := $(wildcard test/*.txt)

.PHONY: test
test: ./obj_dir/Vsoc
	@echo "Running tests..."
	@for test_file in $(test_files); do \
		echo "Running test: $$test_file"; \
		rm ./test.txt; \
		cp $$test_file ./test.txt; \
		./obj_dir/Vsoc; \
	done

.PHONY: clean
clean:
	rm -rf obj_dir