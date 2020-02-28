THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
CONTRIB := $(realpath $(dir $(THIS_MAKEFILE)))

CONFIG_MK += include $$(dir $$(lastword $$(MAKEFILE_LIST)))/syscall-interfaces/contrib/config.mk
CONFIG_MK += include $$(dir $$(lastword $$(MAKEFILE_LIST)))/libsystrap/contrib/config.mk

default: env.sh config.mk build-libsystrap build-dwarfidl \
  build-libfootprints build-syscall-interfaces

# ----------------------------libsystrap

trap-syscalls/contrib/config.mk:
	$(MAKE) -C trap-syscalls/contrib

build-libsystrap: libsystrap/lib/libsystrap.a

libsystrap/lib/libsystrap.a: libsystrap/src/libsystrap.a
	$(MAKE) -C libsystrap/lib

libsystrap/src/libsystrap.a: libsystrap/contrib/config.mk
	$(MAKE) -C libsystrap/src

libsystrap/contrib/config.mk:
	$(MAKE) -C libsystrap/contrib default config.mk

.PHONY: build-libsystrap
build-libsystrap: trap-syscalls/libsystrap/libsystrap.a

CONFIG_MK += \nLIBSYSTRAP_DIR := $(CONTRIB_ROOT)/libsystrap\n

# ----------------------------syscall-interfaces

#FIXME

# ----------------------------

varlist := LIBSYSTRAP_DIR

CONFIG_MK += \n\nenv.sh:\n\tprintf '"'"'$(foreach var,$(varlist),export $(var)="$$($(var))"; )'"'"' >"$$@" || (rm -f "$$@"; false)

config.mk:
	printf '$(CONFIG_MK)' > "$@" || (rm -f "$@"; false)

env.sh: config.mk
	$(MAKE) -f "$<" "$@"

clean::
	rm -f config.mk env.sh
