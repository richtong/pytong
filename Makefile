## Rich Tong's Fine Python Utilities

# https://packaging.python.org/tutorials/packaging-projects/
ENV ?= pipenv
PIP ?= logging
PIP_DEV ?= build twine


## lib-sync: when in https://github.com/richtong/src submodule sync from sort lib
.PHONY: lib-sync
lib-sync:
	for f in include.python.mk include.mk; do \
		if [[ -e ../../lib/$$f ]]; then \
			rsync -av "../../lib/$$f" "$$f" \
		; fi \
	; done

include include.python.mk
include include.mk