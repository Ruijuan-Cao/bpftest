# Programs to build
BINARY := xdpsock

# Libbpf dependencies
LIBBPF = ../libbpf.a

# Tell kbuild to always build the programs
# always := $(tprogs-y)
KERN_OBJ += xdpsock_kern.o

# Notice: the kbuilddir can be redefined on make cmdline
kbuilddir ?= /lib/modules/$(shell uname -r)/build/
KERNEL = $(kbuilddir)

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
LINUXINCLUDE += -I/usr/include/bpf


CFLAGS := -O2 -Wall -Werror
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

NOSTDINC_FLAGS := -nostdinc -isystem $(shell gcc -print-file-name=include)


TPROGS_LDLIBS			+= $(LIBBPF) -lelf -lpthread

HOSTCFLAGS := -O2 -Wall #-H
HOSTCFLAGS += -D__KERNEL__ -D__ASM_SYSREG_H -D__BPF_TRACING__
HOSTCFLAGS += -D__TARGET_ARCH_x86
HOSTCFLAGS += -Werror
HOSTCFLAGS += -Wno-unused-value -Wno-pointer-sign
HOSTCFLAGS += -Wno-compare-distinct-pointer-types
HOSTCFLAGS += -Wno-gnu-variable-sized-type-not-at-end
HOSTCFLAGS += -Wno-tautological-compare
HOSTCFLAGS += -Wno-unknown-warning-option
HOSTCFLAGS += -Wno-address-of-packed-member

# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
#  make M=samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
LLC ?= llc
CLANG ?= clang


# Trick to allow make to be run from this directory
all: $(KERN_OBJ) $(BINARY)

print:
	echo $(BINARY)_user.c
	echo $(HOSTCFLAGS)

# BPF kernel object
$(KERN_OBJ): $(KERN_OBJ:%.o=%.c)
	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(HOSTCFLAGS) \
		-S -emit-llvm -c $<
	$(LLC) -march=bpf -filetype=obj -o $@ $(KERN_OBJ:%.o=%.ll)


# Userspace program with dynamic(shared) lib
$(BINARY): %: $(BINARY)_user.c Makefile
	gcc -g $(CFLAGS) -o $(BINARY) $< $(TPROGS_LDLIBS)

# Catchall for the objects
%.o: %.c
	gcc $(CFLAGS) -o $@ -c $<

.PHONY: clean
clean:
	rm -rf *.o *.ll $(BINARY)


