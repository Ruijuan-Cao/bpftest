# program to build
BINARY := socket

# kernel object
KERN_OBJ := socket_kern.o

# Libbpf dependencies
LIBBPF = ../libbpf.a

# kernel build path
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
LINUXINCLUDE += -I/usr/include/bpf/

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

NOSTDINC_FLAGS := -nostdinc -isystem $(shell gcc -print-file-name=include)

TPROGS_LDLIBS += $(LIBBPF) -lelf

# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
#  make M=samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
LLC ?= llc
CLANG ?= clang

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
	gcc -g $(CFLAGS) -o $(BINARY) $< $(TPROGS_LDLIBS)

# Catchall for the objects
%.o: %.c
	gcc $(CFLAGS) -o $@ -c $<