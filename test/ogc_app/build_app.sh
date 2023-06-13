#!/bin/bash

set -e 

BASE_DIR=$(realpath $(dirname $0)/../..)

cd $BASE_DIR

build_ogc_app.py init .

build_ogc_app.py build_docker
build_ogc_app.py build_cwl
