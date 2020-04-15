XDP_TARGETS  := test_kern
USER_TARGETS := test_user

# tools
LLC ?= llc
CLANG ?= clang
CC ?= gcc

# Libbpf dependencies
LIBBPF = ../libbpf.a

# Includes to the current Kernel
LINUXINCLUDE := -I$(KERNEL)arch/x86/include
LINUXINCLUDE += -I$(KERNEL)arch/x86/include/generated/uapi
LINUXINCLUDE += -I$(KERNEL)arch/x86/include/generated
LINUXINCLUDE += -I$(KERNEL)include
LINUXINCLUDE += -I$(KERNEL)arch/x86/include/uapi
LINUXINCLUDE += -I$(KERNEL)include/uapi
LINUXINCLUDE += -I$(KERNEL)include/generated/uapi
LINUXINCLUDE += -include $(KERNEL)include/linux/kconfig.h
LINUXINCLUDE += -I$(KERNEL)tools/lib

# flags
HOSTCFLAGS := -O2 -Wall #-H
HOSTCFLAGS += -D__KERNEL__ -D__ASM_SYSREG_H -D__BPF_TRACING__
HOSTCFLAGS += -D__TARGET_ARCH_$(ARCH)
HOSTCFLAGS += -Werror
HOSTCFLAGS += -Wno-unused-value -Wno-pointer-sign
HOSTCFLAGS += -Wno-compare-distinct-pointer-types
HOSTCFLAGS += -Wno-gnu-variable-sized-type-not-at-end
HOSTCFLAGS += -Wno-tautological-compare
HOSTCFLAGS += -Wno-unknown-warning-option
HOSTCFLAGS += -Wno-address-of-packed-member

# make
all: $(BINARY) $(KERN_OBJ)

clean:
	rm -rf *.o *.ll $(BINARY)

# make KERN_OBJ
$(KERN_OBJ):$(KERN_OBJ:%.o=%.c)
	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(HOSTCFLAGS) \
		-S -emit-llvm -c $<
	$(LLC) -march=bpf -filetype=obj -o $@ $(KERN_OBJ:%.o=%.ll)

# Userspace program with dynamic(shared) lib
$(BINARY): %: $(BINARY)_user.c Makefile
	$(CC) -g $(CFLAGS) -o $(BINARY) $< $(TPROGS_LDLIBS)

# Catchall for the objects
%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<