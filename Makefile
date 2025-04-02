.DEFAULT_GOAL := VTop

OBJ = $(wildcard ./module/*.*)

./obj_dir/VTop: Top.sv test.cpp $(OBJ) RAM.cpp Makefile
	verilator -Wall Top.sv test.cpp ./nemu/nemu.c -I $(OBJ) -DDIFF -cc -LDFLAGS " -ldl -L ./nemu/riscv32-nemu-interpreter-so" --exe --trace --top-module Top
	# verilator --gdbbt -Wall Top.sv test.cpp ./nemu/nemu.c -I $(OBJ) -DDIFF -cc -CFLAGS "-g" -LDFLAGS "-g -ldl -L ./nemu/riscv32-nemu-interpreter-so" --exe --trace --top-module Top
	make -C obj_dir -f VTop.mk


VTop: ./obj_dir/VTop
	@./obj_dir/VTop

test_files := $(wildcard test/*.txt)

.PHONY: test
test: ./obj_dir/VTop
	@echo "Running tests..."
	@for test_file in $(test_files); do \
		echo "Running test: $$test_file"; \
		rm ./test.txt; \
		cp $$test_file ./test.txt; \
		./obj_dir/VTop; \
	done

.PHONY: clean
clean:
	rm -rf obj_dir