XDP_TARGETS  := test_kern
USER_TARGETS := test_user

BINARY := test
KERN_OBJ := test_kern.o

INCLUDE_OBJS := operation.o

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
LINUXINCLUDE += -I$(KERNEL)include/linux/kconfig.h
LINUXINCLUDE += -I$(KERNEL)tools/lib

# flags
HOSTCFLAGS := -O2 -Wall #-H
HOSTCFLAGS += -D__KERNEL__ -D__ASM_SYSREG_H -D__BPF_TRACING__
HOSTCFLAGS += -D__TARGET_ARCH_$(ARCH)
HOSTCFLAGS += -Werror -Wno-unused-function -Wno-unused-variable
HOSTCFLAGS += -Wno-unused-value -Wno-pointer-sign
HOSTCFLAGS += -Wno-compare-distinct-pointer-types
HOSTCFLAGS += -Wno-gnu-variable-sized-type-not-at-end
HOSTCFLAGS += -Wno-tautological-compare
HOSTCFLAGS += -Wno-unknown-warning-option
HOSTCFLAGS += -Wno-address-of-packed-member

CFLAGS := -O2 -Wall -Werror -Wno-unused-function -Wno-unused-variable
CFLAGS += -I$(KERNEL)usr/include
CFLAGS += -I$(KERNEL)tools/include
CFLAGS += -I$(KERNEL)tools/lib
CFLAGS += -I$(KERNEL)tools/perf/include
CFLAGS += -L$(KERNEL)tools/lib/bpf
CFLAGS += -L$(shell pwd)/lib

ifdef SYSROOT
CFLAGS += --sysroot=$(SYSROOT)
TPROGS_LDFLAGS := -L$(SYSROOT)/usr/lib
endif

TPROGS_LDLIBS			+= $(LIBBPF) -lelf -lpthread

# make
all: $(KERN_OBJ) $(BINARY) 

clean:
	rm -rf *.o *.ll $(BINARY)

# make KERN_OBJ
$(KERN_OBJ):$(KERN_OBJ:%.o=%.c)
	$(CLANG) -g -c -O2$(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(HOSTCFLAGS) \
		-S -emit-llvm $<
	$(LLC) -march=bpf -filetype=obj -o $@ $(KERN_OBJ:%.o=%.ll)

# include
$(INCLUDE_OBJS): operation.c
	$(CC) $(CFLAGS) -c -o $@ $<

# Userspace program with dynamic(shared) lib
$(BINARY): %: $(BINARY)_user.c Makefile $(INCLUDE_OBJS)
	$(CC) -g $(CFLAGS) -o $(BINARY) $(INCLUDE_OBJS) $< $(TPROGS_LDLIBS)

# Catchall for the objects
%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<
