#!/bin/bash

set -e -x

# Fetch the source code for the latest release of Sqlite.
if ! [ -e sqlite3.c ] || ! [ -e sqlite3.h ]; then
  wget https://github.com/utelle/SQLite3MultipleCiphers/releases/download/v2.0.2/sqlite3mc-2.0.2-sqlite-3.48.0-amalgamation.zip -O sqlite3mc.zip
  unzip -p sqlite3mc.zip sqlite3mc_amalgamation.c > sqlite3.c
  unzip -p sqlite3mc.zip sqlite3mc_amalgamation.h > sqlite3.h
fi

# Grab the pysqlite3 source code.
if [[ ! -d "./pysqlite3mc" ]]; then
  git clone git@github.com:player1537/pysqlite3mc
fi

# Copy the sqlite3 source amalgamation into the pysqlite3 directory so we can
# create a self-contained extension module.
cp "sqlite3.c" pysqlite3mc/
cp "sqlite3.h" pysqlite3mc/

# Create the wheels and strip symbols to produce manylinux wheels.
docker run -it -v $(pwd):/io quay.io/pypa/manylinux2014_x86_64 /io/_build_wheels.sh

# Remove un-stripped wheels.
sudo rm ./wheelhouse/*-linux_*
