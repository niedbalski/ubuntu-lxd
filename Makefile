#!/usr/bin/make
PYTHON := /usr/bin/env python

virtualenv:
	@echo Setting up python virtual env...
	virtualenv .venv
	.venv/bin/pip install flake8 charm-tools bundletester

lint: virtualenv
	@echo Lint inspections and charm proof...
	.venv/bin/flake8 --exclude hooks/charmhelpers tests
	.venv/bin/charm-proof

test: virtualenv
	@echo No unit tests defined.  This is an example placeholder.

functional_test: virtualenv
	# Consume ./tests/tests.yaml to determine the tests to run,
	# in addition to functional tests in the ./tests dir.
	@echo Starting functional, lint and unit tests...
	.venv/bin/bundletester -v -F -l DEBUG -r dot -o results-all.dot

test_example: virtualenv
	# A bundletester usage example to run only the matching tests.
	@echo Starting a subset of tests...
	.venv/bin/bundletester -v -F -l DEBUG -r json -o results-ex.json \
        --test-pattern 02*

test_example2: virtualenv
	# A bundletester usage example to run only the specified tests,
    # with a different output format.
	@echo Starting a subset of tests...
	.venv/bin/bundletester -v -F -l DEBUG -r spec -o results-ex2.spec \
        010_basic_precise 015_basic_trusty

test_example3: virtualenv
	# A bundletester bundle usage example.
	@echo Starting a subset of tests...
	.venv/bin/bundletester -v -F -l DEBUG -r dot -o results-ex3.dot \
        -b files/bundle-example.yaml

bin/charm_helpers_sync.py:
	@mkdir -p bin
	@bzr cat lp:charm-helpers/tools/charm_helpers_sync/charm_helpers_sync.py \
        > bin/charm_helpers_sync.py

sync: bin/charm_helpers_sync.py
	@echo Syncing charm helpers for functional tests...
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-tests.yaml

sync_actions: bin/charm_helpers_sync.py
	@echo Syncing charm helpers for actions...
	@$(PYTHON) bin/charm_helpers_sync.py -c charm-helpers-actions.yaml

publish: clean lint
	bzr push lp:charms/trusty/ubuntu

clean:
	@ echo Cleaning up venvs and pyc files...
	rm -rf .venv
	find -name *.pyc -delete
