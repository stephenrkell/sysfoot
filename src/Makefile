THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
SRCROOT := $(realpath $(dir $(THIS_MAKEFILE)))/..

SYS := $(shell uname -s | tr A-Z a-z )

CONTRIB := $(SRCROOT)/contrib
CONFIG ?= $(CONTRIB)/config.mk

default: trace-sysfoot.so

$(CONTRIB)/config.mk:
	$(MAKE) -C $(CONTRIB)

ifeq ($(SYS),freebsd)
LIBC_A ?= /usr/lib/libc_pic.a
endif
include $(CONFIG)

CFLAGS += -DSYSTRAP_DEFINE_FILE

ifeq ($(LIBRUNT_DIR),)
$(error Please install the librunt source tree and set LIBRUNT_DIR to point to it)
endif
ifeq ($(LIBSYSTRAP_DIR),)
$(error Please install the libsystrap source tree and set LIBSYSTRAP_DIR to point to it)
endif
# don't insist on libfootprints
# ifeq ($(LIBFOOTPRINTS_DIR),)
# $(error Please install the libfootprints source tree and set LIBFOOTPRINTS_DIR)
# endif
ifeq ($(SYSCALL_INTERFACES_DIR),)
$(error Please install syscall-interfaces and set SYSCALL_INTERFACES_DIR to it)
endif

#ifeq ($(ANTLR3C_DIR),)
#$(error Please install the libantlr3c source tree and set ANTLR3C_DIR)
#endif

ifeq ($(realpath $(LIBSYSTRAP_DIR)/src/libsystrap.a),)
$(error Please build libsystrap first)
endif

# We don't currently use llvm, but once did; if we do again...
# LLVM_CXXFLAGS ?= $(shell llvm-config --cxxflags)
# LIBLLVM_ARCHIVE ?= -lllvm_X86 -lllvm
# LIBSTDCXX_ARCHIVE ?= -lstdc++
# CFLAGS += $(LLVM_INCLUDES)

FOOTPRINTS_A := $(LIBFOOTPRINTS_DIR)/src/.libs/libfootprints.a $(LIBFOOTPRINTS_DIR)/src/.libs/libfootprints_syscalls.a

# PROBLEM: this archive always contains non-PIC code
# (even if we set CFLAGS to always include -fPIC... libtool interferes).
# ANTLR3C_A := $(ANTLR3C_DIR)/.libs/libantlr3c.a
# Instead, build our own libantlr3c_pic.a from the PIC objects.
ANTLR3C_A := libantlr3c_pic.a 

libantlr3c_pic.a: $(wildcard $(ANTLR3C_DIR)/.libs/*.o)
	$(AR) r "$@" $^

vpath %.h

CFLAGS += -g 
CFLAGS += -Wall -Wno-unused-label -Wno-comment
CFLAGS += -O0 # -O2
CFLAGS += -fPIC
CFLAGS += -ffreestanding -fno-omit-frame-pointer

CFLAGS += -I $(LIBRUNT_DIR)/include
CFLAGS += -I $(LIBFOOTPRINTS_DIR)/include
CFLAGS += -I $(DWARFIDL_DIR)/include
CFLAGS += -I $(DWARFIDL_DIR)/parser
CFLAGS += -I $(ANTLR3C_DIR)
CFLAGS += -I $(ANTLR3C_DIR)/include

# we once used C++, and might do again...
#CXXFLAGS := $(CXXFLAGS) $(CFLAGS) # eagerly latch CFLAGS now; don't want later additions
#CXXFLAGS += -std=c++11

# can now add C-specific options to CFLAGS
CFLAGS += -std=c99

syscall-macros.h: $(SYS)-syscall-macros.h
	cp "$<" "$@"

syscall-names.o: $(SYS)-syscall-macros.h

C_SRC := $(wildcard *.c) uniqtype-bfs.c # $(SYSCALL_IFACE_SRC)
S_SRC := $(wildcard *.s)
CC_SRC := $(wildcard *.cc)

C_DEPS := $(patsubst %.c,.%.d,$(C_SRC))
CC_DEPS := $(patsubst %.cc,.%.d,$(CC_SRC))
DEPS := $(C_DEPS) $(CC_DEPS)
OBJS := $(patsubst %.c,%.o,$(C_SRC)) $(patsubst %.cc,%.o,$(CC_SRC)) $(patsubst %.s,%.o,$(S_SRC))

$(CC_DEPS): .%.d: %.cc
	$(CXX) -MG -MM $(CXXFLAGS) $+ > "$@" || rm -f "$@"
$(C_DEPS): .%.d: %.c
	$(CC) -MG -MM $(CFLAGS) $+ > "$@" || rm -f "$@"

ifneq ($(MAKECMDGOALS),clean)
-include $(DEPS)
endif

#dynamic-list: $(SYSCALL_IFACE_O)
#	( echo '{'; nm --format=posix "$<" | sed 's/[[:blank:]].*/;/'; echo '};') > "$@" || rm -f "$@"

# disable sbrk() in dlmalloc, to avoid conflicting with the "other" C library
dlmalloc.o: CFLAGS += -DHAVE_MORECORE=0
#-O3
# We put dlmalloc in a library so that --exclude-libs=dlmalloc.a will hide its symbols
# in our output .so, so that they don't override anything in the rest of the program.
dlmalloc.a: dlmalloc.o
	$(AR) r "$@" $^

null := #
space := $(null) #
comma := ,
# FIXME: make our dynamic symbols hidden! 
# We don't want user code calling into our exit(), hence having us make its syscalls.

trace-sysfoot.so: LDLIBS := -Bstatic \
	$(LIBSYSTRAP_DIR)/lib/libsystrap.a \
	$(LIBRUNT_DIR)/lib/librunt_preload.a \
	$(LIBC_A) \
	$(FOOTPRINTS_A) \
	$(DWARFIDL_DIR)/parser/dwarfidlSimpleCLexer.o \
	$(DWARFIDL_DIR)/parser/dwarfidlSimpleCParser.o \
	$(ANTLR3C_A)
# NOTE: use of --whole-archive is only necessary for debugging, to ensure that
# functions we might want to call from the debugger are actually linked in

# we used to insist -Wl,--hash-style=sysv here, but relf.h now groks GNU-style
trace-sysfoot.so: LDFLAGS += \
-fno-lto -nostdlib -Wl,--no-as-needed \
-Wl,--defsym,__private_strdup=strdup -Wl,--defsym,__private_malloc=malloc \
-Wl,--defsym,__private_free=free

# we borrow code from the libsystrap example tracer
vpath %.c $(LIBSYSTRAP_DIR)/example

trace-sysfoot.so: trap-syscalls.o syscall-names.o handle-syscall.o dlmalloc.a write-footprints.o
trace-sysfoot.so: $(filter-out dlmalloc.o,$(OBJS)) libantlr3c_pic.a
# don't use lazy binding -- it's bad if we've removed exec permission from ld.so
trace-sysfoot.so: LDFLAGS += -Wl,-z,now -fno-lto -Wl,--exclude-libs=ALL
# FIXME: check whether these are really necessary in the librunt world
trace-sysfoot.so: LDFLAGS += -Wl,--defsym,__GI___assert_fail=__assert_fail \
  -Wl,--defsym,stat=raw_stat
trace-sysfoot.so: LDFLAGS += -Wl,-Map,trace-sysfoot.map

trace-sysfoot.so: dynamic-list $(LIBSYSTRAP_DIR)/src/libsystrap.a
	$(CC) -shared -Bsymbolic \
		-fuse-ld=gold \
		-Wl,--dynamic-list,dynamic-list \
		-Wl,-h,trace-sysfoot.so \
		-Wl,--version-script,version-script \
		-o "$@" $(filter-out dynamic-list,$(filter-out %.a,$+)) \
		$(LDFLAGS) -Wl,-z,muldefs \
		-Wl,--defsym,__GI___assert_fail=__assert_fail -Wl,--defsym,stat=raw_stat \
		-Wl,--exclude-libs=dlmalloc.a \
		$(LDLIBS)

.PHONY: clean
clean:
	rm -f trace-sysfoot.so
	rm -f *.o *.a
	rm -f .*.d
