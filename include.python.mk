##
## Python Commands (cloned from https://github.com/richtong/libi/include.python.mk)
## -------------------
# Configure by setting PIP for pip packages and optionally name
# requires include.mk
#
# Remember makefile *must* use tabs instead of spaces so use this vim line
#
# The makefiles are self documenting, you use two leading
# for make help to produce output
#
# These should be overridden in the makefile that includes this, but this sets
# defaults use to add comments when running make help
#
FLAGS ?=
SHELL := /usr/bin/env bash
# does not work the EXCLUDEd directories are still listed
# https://www.theunixschool.com/2012/07/find-command-15-examples-to-EXCLUDE.html
# EXCLUDE := -type d \( -name extern -o -name .git \) -prune -o
# https://stackoverflow.com/questions/4210042/how-to-EXCLUDE-a-directory-in-find-command
EXCLUDE := -not \( -path "./extern/*" -o -path "./.git/*" \)
ALL_PY := $$(find restart -name "*.py" $(EXCLUDE) )
ALL_YAML := $$(find restart -name "*.yaml" $(EXCLUDE))
# gitpod needs three digits
PYTHON ?= 3.9
PYTHON_MINOR ?= $(PYTHON).7
DOC ?= doc
LIB ?= lib
NAME ?= $$(basename $(PWD))
# put a python file here or the module name
MAIN ?= $(name).py
#MAIN ?= ScrapeAllAndSend.py
MAIN_PATH ?= .

TEST_PYPI_USERNAME ?= richtong

# this is not yet a module so no name
IS_MODULE ?= False
ifeq ($(IS_MODULE),True)
	MODULE ?= -m $(MAIN)
else
	MODULE ?= $(MAIN)
endif

STREAMLIT ?= $(MAIN)

# As of September 2020, run jupyter 0.2 and this generates a pipenv error
# so ignore it
PIPENV_CHECK_FLAGS ?= --ignore 38212
PIP ?=
# These cannot be installed in the environment must use pip install
# build, twine and setuptools for PIP packaging only but install since
# most of what we do will end up packaged
PIP_ONLY ?=
PIP_DEV += \
		pre-commit \
		isort \
		seed-isort-config \
		yamllint \
		flake8 \
		mypy \
		bandit \
		black \
		pydocstyle \
		pdoc3 \
		build twine setuptools wheel

# https://stackoverflow.com/questions/589276/how-can-i-use-bash-syntax-in-makefile-targets
# The virtual environment [ pipenv | conda | none ]
ENV ?= pipenv
RUN ?=
INIT ?=
ACTIVATE ?=
UPDATE ?=
INSTALL ?=
INSTALL_DEV ?= $(INSTALL)
MACOS_VERSION ?= $(shell sw_vers -productVersion)
# due to https://github.com/pypa/pipenv/issues/4564
# pipenv does not correctly deal with MacOS 11 and above so run in
# compatibility mode as of Sept 2021
# hopefully we can turn this off eventually
ifeq ($(ENV),pipenv)
	RUN := SYSTEM_VERSION_COMPAT=1 pipenv run
	UPDATE := SYSTEM_VERSION_COMPAT=1 pipenv update
	INSTALL := SYSTEM_VERSION_COMPAT=1 pipenv install
	INSTALL_DEV := $(INSTALL) --dev --pre
	# conditional dependency https://stackoverflow.com/questions/59867140/conditional-dependencies-in-gnu-make
	INSTALL_REQ = pipenv-python
else ifeq ($(ENV),conda)
	RUN := conda run -n $(name)
	INIT := eval "$$(conda shell.bash hook)"
	ACTIVATE := $(INIT) && conda activate $(name)
	UPDATE := conda update --all -y
	INSTALL := conda install -y -n $(name)
	INSTALL_DEV := $(INSTALL)
	INSTALL_REQ = conda-clean
else ifeq ($(ENV),none)
	RUN :=
	ACTIVATE :=
	# need a noop as this is not a modifier
	# https://stackoverflow.com/questions/12404661/what-is-the-use-case-of-noop-in-bash
	UPDATE := :
	INSTALL := pip install
	INSTALL_DEV := pip install
	INSTALL_REQ :=
endif

## main: run the main program
.PHONY: main
main:
	$(RUN) python $(MODULE) $(FLAGS)

## pdb: run locally with python to test components from main
.PHONY: pdb
pdb:
	$(RUN) python -m pdb $(MODULE) $(FLAGS)

## debug: run with debug model on for main
.PHONY: debug
debug:
	$(RUN) python -d $(MODULE) $(FLAGS)


# https://docs.github.com/en/actions/guides/building-and-testing-python
# https://pytest-cov.readthedocs.io/en/latest/config.html
# https://docs.pytest.org/en/stable/usage.html
## test: unit test for Python non-PIP packages
.PHONY: test
test:
	pytest --doctest-modules "--cov=$(MAIN_PATH)"

## test-pip: test pip installed packages
# assumes the direcotry layout of ./src/$(NAME) for package
# and ./tests for the pytest files
# -e or --editable means create the package in place
#  however the -e does work for pytest
# https://stackoverflow.com/questions/49028611/pytest-cannot-find-module
# you need a __init__.py so that pytest finds the modules
# or do this with python -m pytest which adds this
# https://stackoverflow.com/questions/42724305/pytest-cannot-find-package-when-i-put-tests-in-a-separate-directory
# this is because pytest looks up from the parent to the first directory
# that does nt have an __init__.py to find modules
.PHONY: test-pip
test-pip:
	@echo pip install -e for adhoc testing
	pip install -e .
	@echo fix to PYTHONPATH for pytest
	PYTHONPATH="src" pytest ./tests

## test-ci: product junit for consumption by ci server
# --doctest-modules --cove measure for a particular path
# --junitxml is readable by Jenkins and CI servers
.PHONY: test-ci
test-ci:
	pytest "--cov=$(MAIN_PATH)" --doctest-modules --junitxml=junit/test-results.xml --cov-report=xml --cov-report=html


# https://www.gnu.org/software/make/manual/html_node/Splitting-Lines.html#Splitting-Lines
# https://stackoverflow.com/questions/54503964/type-hint-for-numpy-ndarray-dtype/54541916
#

# test-env: Test environment (Makefile testing only)
.PHONY: test-env
test-env:
	@echo 'ENV="$(ENV)" RUN="$(RUN)"'
	@echo 'SRC="$(SRC)" NB="$(NB)" STREAMLIT="$(STREAMLIT)"'

## update: installs all  packages
.PHONY: update
update:
	$(UPDATE)

## vi: run the editor in the right environment
.PHONY: vi
vi:
	cd $(ED_DIR) && $(RUN) "$$VISUAL" $(ED)

# https://www.technologyscout.net/2017/11/how-to-install-dependencies-from-a-requirements-txt-file-with-conda/
## pip-install: install into python environment set by $(ENV)
# https://stackoverflow.com/questions/9008649/gnu-make-conditional-function-if-inside-a-user-defined-function-always-ev
.PHONY: pip-install
pip-install: $(INSTALL_REQ)
	@echo PIP=$(PIP)
	@echo PIP_ONLY=$(PIP_ONLY)
	@echo PIP_DEV=$(PIP_DEV)
	@echo RUN=$(RUN)
	@echo INSTALL=$(INSTALL)
	@echo INSTALL_DEV=$(INSTALL_DEV)
	@echo INSTALL_REQ=$(INSTALL_REQ)

ifeq ($(ENV),conda)
		conda env list | grep ^$(name) || conda create -y --name $(name)
		conda config --env --add channels conda-forge
		conda config --env --set channel_priority strict
		conda install --name $(name) -y python=$(PYTHON)

		# using conditional in function form if first is not null, then insert
		# second, else the third if it is there
		$(if $(strip $(PIP_ONLY)),$(RUN) pip install $(PIP_ONLY) || true)

		conda install --name $(name) -y $(PIP_DEV)
		conda install --name $(name) -y $(PIP)
		[[ -r environment.yml ]] && conda env update --name $(name) -f environment.yml || true
		# echo $$SHELL
		[[ -r requirements.txt ]] && \
			grep -v "^#" requirements.txt | \
				(while read requirement; do \
					echo "processing $$requirement"; \
					if ! conda install --name $(name) -y "$$requirement"; then \
						$(ACTIVATE) && \
						pip install "$$requirement"; \
						echo "installed $$requirement";\
					fi; \
				done) \
			|| true
		# https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html#setting-environment-variables
		conda env config vars set PYTHONNOUSERSITE=true --name $(name)
		@echo WARNING -- we do not parse the PYthon User site in ~/.
else
		# now handle pip and pipenv together
		# https://stackoverflow.com/questions/38801796/makefile-set-if-variable-is-empty
		$(if $(strip $(PIP)), $(INSTALL) $(PIP))

		$(if $(strip $(PIP_DEV)), $(INSTALL_DEV) $(PIP_DEV))

		# if PIP_ONLY run use regular pip if not pipenv
		$(if $(strip $(PIP_ONLY))$(findstring pipenv, $(ENV)), $(INSTALL) $(PIP_ONLY), $(RUN) pip install $(PIP_ONLY))

		$(if $(findstring pipenv, $(ENV)), pipenv lock && pipenv update)

endif

## export: export configuration to requirements.txt or environment.yml
.PHONY: export
export:
ifeq ($(ENV), conda)
	$(ACTIVATE) && conda env export > environment.yml
else ifeq ($(ENV), pipenv)
	$(RUN) pip freeze > requirements.txt
endif

# https://medium.com/@Tankado95/how-to-generate-a-documentation-for-python-code-using-pdoc-60f681d14d6e
# https://medium.com/@peterkong/comparison-of-python-documentation-generators-660203ca3804
## doc: make the documentation for the Python project (uses pipenv)
.PHONY: doc
doc:
	for file in $(ALL_PY); \
		do $(RUN) pdoc --force --html --output $(DOC) $$file; \
	done

## doc-debug: run web server to look at docs (uses pipenv)
.PHONY: doc-debug
doc-debug:
	@echo browse to http://localhost:8080 and CTRL-C when done
	for file in $(ALL_PY); \
		do pipenv run pdoc --http : $(DOC) $$file; \
	done

## format: reformat python code to standards
.PHONY: format
format:
	# the default is 88 but pyflakes wants 79
	$(RUN) isort --profile=black -w 79 .
	$(RUN) black -l 79 *.py

## shell: Run interactive commands in Pipenv environment
.PHONY: shell
shell:
ifeq ($(strip $(ENV)),pipenv)
	pipenv shell
else ifeq ($(strip $(ENV)),conda)
	@echo "run conda activate $(name) in your shell make cannot run"
else
	@echo "bare pip so no need to shell"
fi

## pipenv-lock: Install from the lock file (for deployment and test)
.PHONY: pipenv-lock
pipenv-lock:
	pipenv install --ignore-pipfile

# https://stackoverflow.com/questions/53382383/makefile-cant-use-conda-activate
# https://github.com/conda/conda/issues/7980
## conda-clean: Remove conda and start all over
.PHONY: conda-clean
conda-clean:
	$(INIT) && conda activate base
	$(UPDATE)
	conda env remove -n $(name) || true
	conda clean -afy

# Note we are using setup.cfg for all the mypy and flake EXCLUDEs and config
## lint : code check (conda)
.PHONY: lint
lint:
	$(RUN) flake8 || true
ifdef ALL_PY
	$(RUN) seed-isort-config ||true
	$(RUN) mypy || true
	$(RUN) bandit $(ALL_PY) || true
	$(RUN) pydocstyle --convention=google $(ALL_PY) || true
endif
ifdef ALL_YAML
	echo $$PWD
	$(RUN) yamllint $(ALL_YAML) || true
endif

# Flake8 does not handle streamlit correctly so EXCLUDE it
# Nor does pydocstyle
# If the web can pass then you can use these lines
# pipenv run flake8 --EXCLUDE $(STREAMLIT)
#	pipenv run mypy $(NO_STREAMLIT)
#	pipenv run pydocstyle --convention=google --match='(?!$(STREAMLIT))'
#
## pipenv-lint: cleans code for you
.PHONY: pipenv-lint
pipenv-lint: lint
	pipenv check $(PIPENV_CHECK_FLAGS)

## pipenv-python: Install python version in
# also add to the python path
# This fail if we don't have brew
# Note when you delete the Pipfile, it will search recursively upward
# looking for one, so on clean recreate one
# we do not explicitly clean anymore so subdirectories of a pipenv can add
# their dependencies
.PHONY: pipenv-python
pipenv-python: pipenv-clean
	@echo currently using python $(PYTHON) override changing PYTHON make flag
	brew upgrade python@$(PYTHON) pipenv
	@echo pipenv sometimes corrupts after python $(PYTHON) install so reinstall if needed
	pipenv --version || brew reinstall pipenv

	PIPENV_IGNORE_VIRTUALENVS=1 pipenv install --python $(PYTHON)
	pipenv clean
	@echo use .env to ensure we can see all packages
	grep ^PYTHONPATH .env ||  echo "PYTHONPATH=." >> .env

## pipenv-clean: cleans the pipenv completely
# note pipenv --rm will fail if there is nothing there so ignore that
# do not do a pipenv clean until later otherwise it creats an environment
# Same with the remove if the files are not there
# Then add a dummy pipenv so that you do not move up recursively
# And create an environment in the current directory
# we normally do not remove the Pipfile just the environment
.PHONY: pipenv-clean
pipenv-clean:
	pipenv --rm || true

## pipenv-rm-pipfile: Remove the Pipfile and reinstall all packages
.PHONY: pipenv-rm-pipfile
pipenv-rm-pipfile:
	rm Pipfile* || true
	touch Pipfile

## python-asdf: Install local python vrsion with asdf
# note asdf needs fully qualified including minor release
.PHONY: python-asdf
python-asdf:
	asdf local python "$(PYTHON_MINOR)"


## test-pypi: build and upload PyPi PIP package distribution to test
# https://twine.readthedocs.io/en/latest/
.PHONY: test-pypi
test-pypi: dist
	$(RUN) twine upload -u __token__ \
		-p "pypi-$$TEST_PYPI_API_TOKEN" \
		--repository testpypi dist/*

	#$(RUN) python -m pip install --upgrade --index-url https://test.pypi.org/simple --no-deps $(NAME)

## dist: build PyPi PIP packages
dist: setup.py
	@echo "Put token into TEST_PYPI_API_TOKEN"
	@echo "from https://test.pypi.org/manage/account/#api-token"
	$(RUN) python -m build

## pypi: build package and push to the python package index
.PHONY: pypi
pypi: dist
	$(RUN) twine upload \
		-u __token__ \
		-p "pypi-$$PYPI_API_TOKEN" \
		dist/*

## pip-dev: pip install in place for local package development
.PHONY: pip-dev
pip-dev:
	$(RUN) pip install -e .
