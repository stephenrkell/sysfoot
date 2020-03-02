THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
CONTRIB := $(realpath $(dir $(THIS_MAKEFILE)))

CONFIG_MK += include $(CONTRIB)/syscall-interfaces/contrib/config.mk\n
CONFIG_MK += include $(CONTRIB)/libsystrap/contrib/config.mk\n

default: env.sh config.mk build-libsystrap build-libfootprints build-syscall-interfaces

# ----------------------------libsystrap

trap-syscalls/contrib/config.mk:
	$(MAKE) -C trap-syscalls/contrib

.PHONY: build-libsystrap
# HACK: should be lib
build-libsystrap: libsystrap/src/libsystrap.a

libsystrap/src/libsystrap.a: libsystrap/contrib/config.mk
	$(MAKE) -C libsystrap/src

libsystrap/contrib/config.mk:
	$(MAKE) -C libsystrap/contrib default config.mk

CONFIG_MK += \nLIBSYSTRAP_DIR := $(CONTRIB)/libsystrap\n

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
                ./configure --prefix=/usr/local

.PHONY: build-libfootprints
build-libfootprints: libfootprints/config.status
	$(MAKE) -C libfootprints

clean::
	if test -f libfootprints/Makefile; then $(MAKE) -C libfootprints clean; fi

CONFIG_MK += \nLIBFOOTPRINTS_DIR := $(CONTRIB)/libfootprints\n

# ----------------------------

varlist := LIBSYSTRAP_DIR SYSCALL_INTERFACES_DIR LIBFOOTPRINTS_DIR

CONFIG_MK += \n\nenv.sh:\n\tprintf '"'"'$(foreach var,$(varlist),export $(var)="$$($(var))"; )'"'"' >"$$@" || (rm -f "$$@"; false)

config.mk:
	printf '$(CONFIG_MK)' > "$@" || (rm -f "$@"; false)

env.sh: config.mk build-syscall-interfaces build-libsystrap # because our config.mk includes those ones
	$(MAKE) -f "$<" "$@"

clean::
	rm -f config.mk env.sh
