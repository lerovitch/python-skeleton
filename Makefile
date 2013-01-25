NAME=pythonskeleton
PACKAGE_NAME=pythonskeleton
VERSION=`cat VERSION`

VIRTUALENV_URL=https://raw.github.com/pypa/virtualenv/master/virtualenv.py
VIRTUALENV_PATH=./.venv/$(NAME)
VIRTUALENV_PATH_RPM=./.venv/$(NAME)_rpm
CACHE_PATH=~/.venv/cache
PYTHON=$(VIRTUALENV_PATH)/bin/python
PYTHON_INSTALLABLE=python2.6

#pip configuration
PIP=$(VIRTUALENV_PATH)/bin/pip
PYPI_INDEX=http://10.95.99.40:9001 
PIP_EXTRA_OPTS=-M --timeout=180 -i $(PYPI_INDEX) --extra-index-url=http://pypi.python.org/simple/ --download-cache=$(CACHE_PATH) 
RPM_BUILD_ROOT=~/rpmbuild/RPMS/x86_64/

export PYTHONPATH=PYTHONPATH:src
COVERAGE=$(VIRTUALENV_PATH)/bin/coverage
TEST_BIN=$(VIRTUALENV_PATH)/bin/trial
PYLINT=$(VIRTUALENV_PATH)/bin/pylint --output-format=parseable
test=test

.PHONY: clean dist-clean rpm cover tests devel sdist

all: default 

default:
	@echo
	@echo "Welcome to python skeleton software package"
	@echo
	@echo "   Version ${VERSION}"
	@echo
	@echo "clean					- Remove temp files"
	@echo "devclean				- Remove temp files and dev virtualenv"
	@echo "distclean				- Remove temp files and rpm virtualenv"
	@echo
	@echo "sdist					- Build a tar.gz software distribution of the package"
	@echo "install					- Installs setup.py install"
	@echo "rpm					- Create RPM package"
	@echo 
	@echo "venv	     				- Creates the dev virtual env"
	@echo "devlibs 	     			- Installs the dev libs for the dev venv"
	@echo "testlibs	     			- Installs the test libs for the dev venv"
	@echo "tests         				- Run unittesting"
	@echo "tests test=test.module.class.method 	- Run the specific method"
	@echo "cover	     				- Run unittesting and coverage report"
	@echo "runserver     				- Run a server for local purposes"
	@echo

virtualenv: virtualenv.py
virtualenv.py: 
	@echo ">>> downloading bootstrap virtualenv.py"
	@wget -q $(VIRTUALENV_URL)


venv: $(VIRTUALENV_PATH)/bin/activate virtualenv 
$(VIRTUALENV_PATH)/bin/activate:
	@echo ">>> checking virtualpath"
	@test -d $(VIRTUALENV_PATH) || \
		PYTHONPATH= python2.6 virtualenv.py $(VIRTUALENV_PATH)
	@if [ $$? -ne 0 ]; then echo ">>> deleting virtualenv"; fi


devlibs: venv $(VIRTUALENV_PATH)/lib/python2.6/site-packages/devlibs 
$(VIRTUALENV_PATH)/lib/python2.6/site-packages/devlibs: requirements.txt
	@echo ">>> installing deps"
	@$(PIP) install -r requirements.txt $(PIP_EXTRA_OPTS) 
	@if [ $$? -eq 0 ]; then \
		touch $(VIRTUALENV_PATH)/lib/python2.6/site-packages/devlibs; fi


testlibs: venv $(VIRTUALENV_PATH)/lib/python2.6/site-packages/testlibs 
$(VIRTUALENV_PATH)/lib/python2.6/site-packages/testlibs: requirements-test.txt
	@echo ">>> installing test deps"
	@$(PIP) install -r requirements-test.txt $(PIP_EXTRA_OPTS) 
	@if [ $$? -eq 0 ]; then \
		touch $(VIRTUALENV_PATH)/lib/python2.6/site-packages/testlibs; fi

syncdb: $(VIRTUALENV_PATH)/syncdbtest
$(VIRTUALENV_PATH)/syncdbtest: 
	@echo ">>> creating database for tests"
	@mysql -uroot -p < test/resources/createdb.sql
	@if [ $$? -eq 0 ]; then touch $(VIRTUALENV_PATH)/syncdbtest ; fi
	

tests: testlibs devlibs
	@echo ">>> Running trial tests..."
	$(TEST_BIN) $(test)
	@rm -rf _trial*

cover: venv testlibs devlibs
	@echo ">>> Running tests and computing coverage..."
	$(PYTHON) setup.py develop --uninstall
	$(COVERAGE) run --branch $(TEST_BIN) test
	$(COVERAGE) xml src/*.py src/$(PACKAGE_NAME)/*.py src/$(PACKAGE_NAME)/**/*.py
	@PWD=`pwd`; \
		sed -i -e "s#<packages>#<sources><source>$$PWD</source></sources>\n\t<packages>#g" coverage.xml
	@echo

pylint: venv testlibs 
	@echo ">>> Pylint report"
	@$(PYLINT) src/$(PACKAGE_NAME) > pylint.txt 

build-libs: 
	# this will copy the site-packages of virtualenv 
	# process the pth to include abs path for each egg
	# copy processed pth to dest site-packages 
	@echo ">>> installing libs to lib deploy"
	@test -d $(VIRTUALENV_PATH_RPM) || python2.6 virtualenv.py $(VIRTUALENV_PATH_RPM)
	@$(VIRTUALENV_PATH_RPM)/bin/pip install -r requirements.txt \
		--egg $(PIP_EXTRA_OPTS)
	@cp -r $(VIRTUALENV_PATH_RPM)/lib/python2.6/site-packages \
		$(RPM_BUILD_ROOT)$(LIB_DIR)/libs
	@sed -i 's:^\.:$(LIB_DIR)/libs:'  \
		$(RPM_BUILD_ROOT)$(LIB_DIR)/libs/easy-install.pth
	@mkdir -p $(RPM_BUILD_ROOT)$(SITEPACKAGES_PATH)
	@cp $(RPM_BUILD_ROOT)$(LIB_DIR)/libs/easy-install.pth  \
		$(RPM_BUILD_ROOT)$(SITEPACKAGES_PATH)/$(NAME)libs.pth

install: 
	# this will install source code to dest folder and create running script
	# it generates a pth file with the source code of the app to be deployed
	# into site-packages
	@echo ">>> Installing source distribution..."
	$(PYTHON_INSTALLABLE) setup.py install  --install-purelib=$(LIB_DIR)/python  --root=$(RPM_BUILD_ROOT)  --record=$(INSTALLED_FILES)  --install-scripts=$(HOME_DIR)/bin --install-data=$(HOME_DIR)
	mkdir -p $(RPM_BUILD_ROOT)$(SITEPACKAGES_PATH)
	echo "$(LIB_DIR)/python" > \
		$(RPM_BUILD_ROOT)$(SITEPACKAGES_PATH)/$(NAME).pth
	@echo

sdist: setup.py 
	@echo ">>> Generating source distribution..."
	@test -d $(VIRTUALENV_PATH_RPM) || \
		PYTHONPATH= python2.6 virtualenv.py $(VIRTUALENV_PATH_RPM)
	$(VIRTUALENV_PATH_RPM)/bin/python setup.py sdist
	@echo

rpm:
	@echo ">>> Generating RPM for version $(VERSION)-$(RELEASE)"
	rpmbuild -bb $(NAME).spec --define "version $(VERSION)" \
		--define "release $(RELEASE)"
	mv ~/rpmbuild/RPMS/x86_64/$(NAME)-$(VERSION)-$(RELEASE).x86_64.rpm .
	@echo

runserver: venv
	@echo ">>> Running application for development"
	@mkdir -p ~/log/$(NAME)
	$(PYTHON) src/main.py 

clean:
	@echo ">>> Cleaning all..."
	@rm -rf dist
	@find . -name "*.egg-info" -print0 | xargs -0 rm -rf
	@find . -name "*.pyc" -print0 | xargs -0 rm -rf
	@find . -name "_trial_temp*" -print0 | xargs -0 rm -rf
	@rm -rf bin lib libs dist develop-eggs eggs include 

devclean: clean
	@echo ">>> Removing dev virtualenv..."
	rm -rf $(VIRTUALENV_PATH)

distclean: clean
	@echo ">>> Cleaning all..."
	rm -rf $(VIRTUALENV_PATH_RPM)

