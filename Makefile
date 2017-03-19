#include ../stack.mk

IVORYFLAGS ?= --const-fold --verbose
#TESTS      := cansendrecv-test can2uart-test blink-test spi-test
TESTS      := encoder-test
AADL_TESTS := 
CLEANS     := $(foreach test,$(TESTS),$(test)-clean) \
	            $(foreach test,$(AADL_TESTS),$(test)_clean)
GDB := arm-none-eabi-gdb \
		--ex 'target extended-remote /dev/f4gdb' \
		--ex 'monitor connect_srst disable' \
		--ex 'monitor swdp_scan' \
		--ex 'set mem inaccessible-by-default off' \
		--ex 'attach 1'

.PHONY: test clean $(TESTS) $(AADL_TESTS) $(CLEANS)
test: $(TESTS) $(AADL_TESTS)
clean: $(CLEANS)

define MKTEST
$(1):
	stack build . --exec '$(1)-gen --src-dir=build/$(1) $(IVORYFLAGS)'
	make -C build/$(1)
$(1)-clean:
	rm -rf build/$(1)
$(1)-gdb: $(1)
	$(GDB) build/$(1)/image
$(1)-gdb-load: $(1)
	$(GDB) --ex 'load' build/$(1)/image
$(1)-gdb-run: $(1)
	$(GDB) --ex 'load' --ex 'run' build/$(1)/image
endef

define MK_AADL_TEST
$(1):
	stack build . --exec '$(1)_gen --src-dir=build_aadl/$(1) $(IVORYFLAGS)'
$(1)_clean:
	rm -rf build_aadl/$(1)
endef

$(foreach test,$(TESTS),$(eval $(call MKTEST,$(test))))
$(foreach test,$(AADL_TESTS),$(eval $(call MK_AADL_TEST,$(test))))