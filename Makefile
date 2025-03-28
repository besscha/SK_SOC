

./obj_dir/Vsoc: soc.sv test.cpp ALU.sv memory.sv branch.sv PC.sv regfile.sv decoder.sv param.vh 
	verilator -Wall soc.sv test.cpp -cc --exe --trace --top-module soc
	make -C obj_dir -f Vsoc.mk

.PHONY: Vsoc
Vsoc: ./obj_dir/Vsoc
	@./obj_dir/Vsoc

test_files := $(wildcard test/*.txt)

.PHONY: test
test:
	@echo "Running tests..."
	@for test_file in $(test_files); do \
		echo "Running test: $$test_file"; \
		rm ./t.txt; \
		cp $$test_file ./t.txt; \
		./obj_dir/Vsoc; \
	done

.PHONY: ALU
ALU:
	verilator -Wall $@/$@.sv ./$@/test.cpp --cc --exe --trace --top-module ALU
	make -C obj_dir -f VALU.mk
	./obj_dir/VALU

.PHONY: men
men:
	verilator -Wall $@/memory.sv ./$@/main.cpp --cc --exe --trace --top-module memory
	make -C obj_dir -f Vmemory.mk
	./obj_dir/Vmemory

.PHONY: clean
clean:
	rm -rf obj_dir