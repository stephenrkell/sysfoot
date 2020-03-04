THIS_MAKEFILE := $(lastword $(MAKEFILE_LIST))
srcroot := $(realpath $(dir $(THIS_MAKEFILE))/..)

.PHONY: default
default: ifacetypes

include $(srcroot)/config.mk
$(srcroot)/config.mk:
	cd $(srcroot) && ln -s contrib/config.mk .

# FIXME: factor this as *_CXXFLAGS and *_LIBS
# so that pkg-config (plus our usual CFLAGS=>CXXFLAGS hack) will just work

CXXFLAGS += -I$(LIBALLOCSTOOL_DIR)/include \
  -I$(LIBALLOCSTOOL_DIR) \
  -I$(DWARFIDL_DIR)/include \
  -I$(LIBCXXGEN_DIR)/include \
  -I$(LIBANTLR3CXX_DIR)/include \
  -I$(LIBDWARFPP_DIR)/include \
  -I$(LIBSRK31CXX_DIR)/include \
  -I$(LIBCXXFILENO_DIR)/include

# HACK: liballocstool lib is still in src/
LDFLAGS += -L$(LIBALLOCSTOOL_DIR)/src \
  -L$(DWARFIDL_DIR)/lib -Wl,-rpath,$(DWARFIDL_DIR)/lib \
  -L$(LIBCXXGEN_DIR)/lib -Wl,-rpath,$(LIBCXXGEN_DIR)/lib \
  -L$(LIBANTLR3CXX_DIR)/lib \
  -L$(LIBDWARFPP_DIR)/lib -Wl,-rpath,$(LIBDWARFPP_DIR)/lib \
  -L$(LIBSRK31CXX_DIR)/lib -Wl,-rpath,$(LIBSRK31CXX_DIR)/lib \
  -L$(LIBCXXFILENO_DIR)/lib -Wl,-rpath,$(LIBCXXFILENO_DIR)/lib

LDLIBS += -lallocstool -ldwarfidl -lcxxgen -ldwarfpp -lsrk31c++ -lc++fileno \
  -lboost_regex -lboost_filesystem

.PHONY: clean
clean:
	rm -f ifacetypes
