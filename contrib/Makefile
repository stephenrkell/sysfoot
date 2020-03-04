THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
CONTRIB := $(realpath $(dir $(THIS_MAKEFILE)))

CONFIG_MK += include $(CONTRIB)/syscall-interfaces/contrib/config.mk\n
CONFIG_MK += include $(CONTRIB)/libsystrap/contrib/config.mk\n

LIBALLOCSTOOL_DIR := $(CONTRIB)/liballocstool

default: env.sh config.mk build-libsystrap build-libfootprints build-syscall-interfaces \
  build-liballocstool

# ----------------------------libsystrap

.PHONY: build-libsystrap
# HACK: should be lib
build-libsystrap: libsystrap/src/libsystrap.a

libsystrap/src/libsystrap.a: libsystrap/contrib/config.mk
	$(MAKE) -C libsystrap/src

libsystrap/contrib/config.mk:
	$(MAKE) -C libsystrap/contrib default config.mk

LIBSYSTRAP_DIR := $(CONTRIB)/libsystrap
CONFIG_MK += \nLIBSYSTRAP_DIR := $(LIBSYSTRAP_DIR)\n
varlist += LIBSYSTRAP_DIR

# ----------------------------syscall-interfaces
# will get us the DWARF/dwarfidl of the running kernel
# (which we want for its ifacetypes -- WHY?)
# and its spec.idl with footprints in
# (which we will

.PHONY: build-syscall-interfaces
build-syscall-interfaces:
	$(MAKE) -C syscall-interfaces

SYSCALL_INTERFACES_DIR := $(CONTRIB)/syscall-interfaces
CONFIG_MK += \nSYSCALL_INTERFACES_DIR := $(SYSCALL_INTERFACES_DIR)\n
varlist += SYSCALL_INTERFACES_DIR

DWARFIDL_DIR := $(SYSCALL_INTERFACES_DIR)/contrib/dwarfidl
CONFIG_MK += \nDWARFIDL_DIR := $(DWARFIDL_DIR)\n
varlist += DWARFIDL_DIR

LIBCXXGEN_DIR := $(DWARFIDL_DIR)/contrib/libcxxgen
CONFIG_MK += \nLIBCXXGEN_DIR := $(LIBCXXGEN_DIR)\n
varlist += LIBCXXGEN_DIR

LIBANTLR3CXX_DIR := $(DWARFIDL_DIR)/contrib/libantlr3c++
CONFIG_MK += \nLIBANTLR3CXX_DIR := $(LIBANTLR3CXX_DIR)\n
varlist += LIBCXXGEN_DIR

LIBDWARFPP_DIR := $(DWARFIDL_DIR)/contrib/libdwarfpp
CONFIG_MK += \nLIBDWARFPP_DIR := $(LIBDWARFPP_DIR)\n
varlist += LIBDWARFPP_DIR

LIBCXXFILENO_DIR := $(LIBDWARFPP_DIR)/contrib/libc++fileno
CONFIG_MK += \nLIBCXXFILENO_DIR := $(LIBCXXFILENO_DIR)\n
varlist += LIBCXXFILENO_DIR

LIBSRK31CXX_DIR := $(LIBDWARFPP_DIR)/contrib/libsrk31c++
CONFIG_MK += \nLIBSRK31CXX_DIR := $(LIBSRK31CXX_DIR)\n

LIBRUNT_DIR := $(LIBSYSTRAP_DIR)/contrib/librunt
CONFIG_MK += \nLIBRUNT_DIR := $(LIBRUNT_DIR)\n
varlist += LIBRUNT_DIR

# ----------------------------libfootprints
libfootprints/config.status: libfootprints/configure libfootprints/Makefile.in

libfootprints/configure: libfootprints/configure.ac
	cd libfootprints && aclocal && \
                autoconf

libfootprints/Makefile.in: libfootprints/configure
	cd libfootprints && libtoolize && \
                automake --add-missing && \
                automake

libfootprints/config.status: libfootprints/Makefile.in libfootprints/configure build-syscall-interfaces # for dwarfidl
	cd libfootprints && \
                DWARFIDL_CFLAGS="-I$(SYSCALL_INTERFACES_DIR)/contrib/dwarfidl/include" \
                DWARFIDL_LIBS="-L$(SYSCALL_INTERFACES_DIR)/contrib/dwarfidl/lib" \
                CFLAGS="-I$(SYSCALL_INTERFACES_DIR)/lib -I$(LIBALLOCSTOOL_DIR)/include" \
                ./configure --prefix=/usr/local

.PHONY: build-libfootprints
build-libfootprints: libfootprints/config.status
	$(MAKE) -C libfootprints

clean::
	if test -f libfootprints/Makefile; then $(MAKE) -C libfootprints clean; fi

CONFIG_MK += \nLIBFOOTPRINTS_DIR := $(CONTRIB)/libfootprints\n

# ----------------------------liballocstool
liballocstool/config.status: liballocstool/configure liballocstool/Makefile.in

liballocstool/configure: liballocstool/configure.ac
	cd liballocstool && ./autogen.sh

liballocstool/config.status: liballocstool/configure
	cd liballocstool && \
        LIBCXXFILENO_CXXFLAGS=-I$(LIBCXXFILENO_DIR)/include \
        LIBCXXFILENO_LIBS="-L$(LIBCXXFILENO_DIR)/lib \
        -Wl,-rpath,$(LIBCXXFILENO_DIR) -lc++fileno" \
        LIBSRK31CXX_CXXFLAGS=-I$(LIBSRK31CXX_DIR)/include \
        LIBSRK31CXX_LIBS="-L$(LIBSRK31CXX_DIR)/lib \
        -Wl,-rpath,$(LIBSRK31CXX_DIR)/lib -lsrk31c++" \
        LIBDWARFPP_CXXFLAGS=-I$(LIBDWARFPP_DIR)/include \
        LIBDWARFPP_LIBS="-L$(LIBDWARFPP_DIR)/lib \
        -Wl,-rpath,$(LIBDWARFPP_DIR)/lib -ldwarfpp" \
        LIBCXXGEN_CXXFLAGS=-I$(LIBCXXGEN_DIR)/include \
        LIBCXXGEN_LIBS="-L$(LIBCXXGEN_DIR)/lib \
        -Wl,-rpath,$(LIBCXXGEN_DIR)/lib -lcxxgen" \
        LIBANTLR3CXX_CXXFLAGS=-I$(LIBANTLR3CXX_DIR)/include \
        LIBANTLR3CXX_LIBS=-Wl,-g \
        DWARFIDL_CXXFLAGS=-I$(DWARFIDL_DIR)/include \
        DWARFIDL_LIBS="-L$(DWARFIDL_DIR)/lib \
        -Wl,-rpath,$(DWARFIDL_DIR)/lib -ldwarfidl" \
        ./configure --prefix=$(CONTRIB_ROOT)/usr \
        --with-librunt=$(LIBRUNT_DIR)

.PHONY: build-liballocstool
build-liballocstool: liballocstool/config.status
	$(MAKE) -C liballocstool

clean::
	if test -f liballocstool/Makefile; then $(MAKE) -C liballocstool clean; fi

LIBALLOCSTOOL_DIR := $(CONTRIB)/liballocstool
CONFIG_MK += \nLIBALLOCSTOOL_DIR := $(LIBALLOCSTOOL_DIR)\n
varlist += LIBALLOCSTOOL_DIR

# ----------------------------

CONFIG_MK += \n\nenv.sh:\n\tprintf '"'"'$(foreach var,$(varlist),export $(var)="$$($(var))"; )'"'"' >"$$@" || (rm -f "$$@"; false)

config.mk:
	printf '$(CONFIG_MK)' > "$@" || (rm -f "$@"; false)

env.sh: config.mk build-syscall-interfaces build-libsystrap # because our config.mk includes those ones
	$(MAKE) -f "$<" "$@"

clean::
	rm -f config.mk env.sh
