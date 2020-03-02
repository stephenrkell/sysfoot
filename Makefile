.PHONY: default
default: subdirs

.PHONY: subdirs
subdirs: src

.PHONY: src
src:
	$(MAKE) -C src
