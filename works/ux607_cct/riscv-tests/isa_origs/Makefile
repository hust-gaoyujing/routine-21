#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 32

#INTERNAL_CODE_BEGIN
NDSE := 0

#INTERNAL_CODE_END

src_dir := .

include $(src_dir)/rv64ui/Makefrag
include $(src_dir)/rv64uc/Makefrag
include $(src_dir)/rv64um/Makefrag
include $(src_dir)/rv64ua/Makefrag
include $(src_dir)/rv32ui/Makefrag
include $(src_dir)/rv32uc/Makefrag
include $(src_dir)/rv32um/Makefrag
include $(src_dir)/rv32ua/Makefrag
#include $(src_dir)/rv32imc_0/Makefrag
#include $(src_dir)/rv32imc_1/Makefrag
#include $(src_dir)/rv32imc_2/Makefrag

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------


RISCV_PREFIX ?= riscv-nuclei-elf
RISCV_GCC ?= $(RISCV_PREFIX)-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -g -fvisibility=hidden -nostdlib -nostartfiles -I../../../vsim
RISCV_OBJDUMP ?= $(RISCV_PREFIX)-objdump --disassemble-all -S
RISCV_OBJCOPY ?= $(RISCV_PREFIX)-objcopy -O verilog 
RISCV_SIM ?= ${PWD}/../../prebuilt_tools/prefix/bin/spike

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.spike.rpt: % 
	$(RISCV_SIM)  --isa=rv32imafdcp -l $< >& $<.spike.rpt

%.dump: % 
	$(RISCV_OBJDUMP) $< > $@
	$(RISCV_OBJCOPY) $<   $<.verilog
	sed -i 's/@800/@000/g' $<.verilog
	sed -i 's/@00002FB8/@00002000/g' $<.verilog
	sed -i 's/@00004FB8/@00004000/g' $<.verilog
	sed -i 's/@00005FB8/@00005000/g' $<.verilog
	sed -i 's/@00006FB8/@00006000/g' $<.verilog

%.out: %
	$(RISCV_SIM) --isa=rv64gc $< 2> $@

%.out32: %
	$(RISCV_SIM) --isa=rv32gc $< 2> $@

define compile_template

$$($(1)_p_tests): $(1)-p-%: $(1)/%.S
	$$(RISCV_GCC) $(2) $$(RISCV_GCC_OPTS) -I$(src_dir)/../env/p -I$(src_dir)/macros/scalar -T$(src_dir)/../env/p/link.ld $$< -o $$@
$(1)_tests += $$($(1)_p_tests)

$(1)_tests_dump = $$(addsuffix .dump, $$($(1)_tests))

$(1): $$($(1)_tests_dump)

.PHONY: $(1)

tests += $$($(1)_tests)

endef
ifeq ($(XLEN),64)
  $(eval $(call compile_template,rv64ui,-march=rv64imafdc -mabi=lp64))
  $(eval $(call compile_template,rv64uc,-march=rv64imafdc -mabi=lp64))
  $(eval $(call compile_template,rv64um,-march=rv64imafdc -mabi=lp64))
  $(eval $(call compile_template,rv64ua,-march=rv64imafdc -mabi=lp64))
else
  $(eval $(call compile_template,rv32ui,-march=rv32imafdc -mabi=ilp32))
  $(eval $(call compile_template,rv32uc,-march=rv32imafdc -mabi=ilp32))
  $(eval $(call compile_template,rv32um,-march=rv32imafdc -mabi=ilp32))
  $(eval $(call compile_template,rv32ua,-march=rv32imafdc -mabi=ilp32))

  #$(eval $(call compile_template,rv32imc_0,-march=rv32imafdc -mabi=ilp32))
  #$(eval $(call compile_template,rv32imc_1,-march=rv32imafdc -mabi=ilp32))
  #$(eval $(call compile_template,rv32imc_2,-march=rv32imafdc -mabi=ilp32))
endif

tests_spike_rpt = $(addsuffix .spike.rpt, $(tests))
tests_verilog = $(addsuffix .verilog, $(tests))
tests_dump = $(addsuffix .dump, $(tests))
tests_hex = $(addsuffix .hex, $(tests))
tests_out = $(addsuffix .out, $(spike_tests))
tests32_out = $(addsuffix .out32, $(spike32_tests))

#run: $(tests_out) $(tests32_out)
run: $(tests_spike_rpt)

junk += $(tests) $(tests_spike_rpt) $(tests_verilog) $(tests_dump) $(tests_hex) $(tests_out) $(tests32_out)
elf_junk += $(tests)

#------------------------------------------------------------
# Default

all: $(tests_dump)
#	rm -rf $(elf_junk)

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)

