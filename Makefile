## Rich Tong's Fine Python Utilities

# https://packaging.python.org/tutorials/packaging-projects/
ENV ?= pipenv
# note that logging is included by default library so no need to pip install it
PIP ?=


include include.python.mk
include include.mk
