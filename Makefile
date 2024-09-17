.DEFAULT_GOAL := help

PYTHON ?= python3.10

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

ifneq ($(wildcard $(ROOT_DIR)/env/.),)
	CONDA_PYTHON = $(ROOT_DIR)/env/bin/python
else
	CONDA_PYTHON = $(PYTHON)
endif

define HELP_BODY
Usage:
  make <command>

Commands:
  reformat                   Reformat all .py files being tracked by git.
  stylecheck                 Check which tracked .py files need reformatting.
  stylediff                  Show the post-reformat diff of the tracked .py files
                             without modifying them.
  gettext                    Generate pot files.
  upload_translations        Upload pot files to Crowdin.
  download_translations      Download translations from Crowdin.
  bumpdeps                   Run script bumping dependencies.
  newenv                     Create or replace this project's virtual environment.
  syncenv                    Sync this project's virtual environment to Red's latest
                             dependencies.
endef
export HELP_BODY

# Python Code Style
reformat:
	$(CONDA_PYTHON) -m black $(ROOT_DIR)
stylecheck:
	$(CONDA_PYTHON) -m black --check $(ROOT_DIR)
stylediff:
	$(CONDA_PYTHON) -m black --check --diff $(ROOT_DIR)

# Translations
gettext:
	$(PYTHON) -m redgettext --command-docstrings --verbose --recursive redbot --exclude-files "redbot/pytest/**/*"
upload_translations:
	crowdin upload sources
download_translations:
	crowdin download

# Dependencies
bumpdeps:
	$(PYTHON) tools/bumpdeps.py

# Development environment
newenv:
	conda create --prefix ./env python=$(PYTHON) -y
	$(MAKE) syncenv
syncenv:
	conda install --prefix ./env --file ./tools/dev-requirements.txt -y

# Help
help:
	@echo "$$HELP_BODY"
