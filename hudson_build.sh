#!/bin/bash
set -e # Returns error if any command returns error

NAME=pythonskeleton
VERSION=`cat VERSION`
RELEASE="b`git log --pretty=oneline | wc -l`"
echo "Generating pythonskeleton RPM for version $VERSION-$RELEASE"

# run tests and compute coverage
#make cover

# Static checking pylint
#make pylint

# clean testing environment
make distclean

# Update version
sed -i "s/#VERSION/pythonskeleton $VERSION-$RELEASE($BUILD_ID)/g" src/main.py
# generate distribution tarball
make sdist

mv dist/$NAME-$VERSION.tar.gz ~/rpmbuild/SOURCES

# generate RPM package
make rpm VERSION=$VERSION RELEASE=$RELEASE

