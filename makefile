SHELL:=/bin/bash
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
APP_NAME:=app


all: dependencies

fresh: clean dependencies

testenv: dependencies clean_testenv
	docker-compose up --build

clean_testenv:
	docker-compose down

fresh_testenv: clean_testenv testenv

dependencies:
	if [ ! -d $(ROOT_DIR)/env ]; then python3.6 -m venv $(ROOT_DIR)/env; fi
	source $(ROOT_DIR)/env/bin/activate; yes w | python -m pip install -r $(ROOT_DIR)/requirements.txt

upgrade_dependencies:
	source $(ROOT_DIR)/env/bin/activate; yes w | python -m pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1  | xargs -n1 python -m pip install -U
	source $(ROOT_DIR)/env/bin/activate; python -m pip freeze | sed "/^$(APP_NAME)/ d" > requirements.txt

save_dependencies:
	source $(ROOT_DIR)/env/bin/activate; python -m pip freeze | sed "/^$(APP_NAME)/ d" > requirements.txt

clean: clean_testenv
	# Remove existing environment
	rm -rf $(ROOT_DIR)/env;
	rm -rf $(ROOT_DIR)/$(APP_NAME)/*.pyc;
