.DEFAULT_GOAL := VTop

OBJ = $(wildcard ./soc/*.*)
OBJ += $(wildcard ./memory/*.*)
OBJ += Top.sv
OBJ += interface.sv


./obj_dir/VTop: $(OBJ) test.cpp RAM.cpp Makefile
	verilator -Wall test.cpp ./nemu/nemu.c -I $(OBJ) -DDIFF -cc -LDFLAGS " -ldl -L ./nemu/riscv32-nemu-interpreter-so" --exe --trace --top-module Top
	# verilator --gdbbt -Wall Top.sv test.cpp ./nemu/nemu.c -I $(OBJ) -DDIFF -cc -CFLAGS "-g" -LDFLAGS "-g -ldl -L ./nemu/riscv32-nemu-interpreter-so" --exe --trace --top-module Top
	make -C obj_dir -f VTop.mk


VTop: ./obj_dir/VTop
	@./obj_dir/VTop

test_files := $(wildcard test/*.bin)

.PHONY: test
test: ./obj_dir/VTop
	@echo "Running tests..."
	@for test_file in $(test_files); do \
		echo "Running test: $$test_file"; \
		rm ./test.bin; \
		cp $$test_file ./test.bin; \
		./obj_dir/VTop; \
	done

.PHONY: clean
clean:
	rm -rf obj_dir