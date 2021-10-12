## Rich Tong's Fine Python Utilities

# https://packaging.python.org/tutorials/packaging-projects/
ENV ?= pipenv
# note that logging is included by default 
PIP ?= 
PIP_DEV ?= build twine setuptools wheel tqdm


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
