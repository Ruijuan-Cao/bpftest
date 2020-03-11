# Programs to build
BINARY := xdpsock

# Libbpf dependencies
LIBBPF = /usr/lib64/libbpf.a

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

CFLAGS += -Wall -O2
CFLAGS += -Wmissing-prototypes
CFLAGS += -Wstrict-prototypes

CFLAGS += -I$(objtree)/usr/include
CFLAGS += -I$(srctree)/tools/lib/bpf/
CFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
CFLAGS += -I$(srctree)/tools/lib/
CFLAGS += -I$(srctree)/tools/include
CFLAGS += -I$(srctree)/tools/perf
CFLAGS += -DHAVE_ATTR_TEST=0

ifdef SYSROOT
CFLAGS += --sysroot=$(SYSROOT)
TPROGS_LDFLAGS := -L$(SYSROOT)/usr/lib
endif

NOSTDINC_FLAGS := -nostdinc -isystem $(shell gcc -print-file-name=include)

TPROGS_LDLIBS			+= $(LIBBPF) -lelf

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

# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
#  make M=samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
LLC ?= llc
CLANG ?= clang

# Trick to allow make to be run from this directory
all: $(KERN_OBJ) $(BINARY)

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

