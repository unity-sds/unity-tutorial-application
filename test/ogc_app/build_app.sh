#!/bin/bash

set -e 

BASE_DIR=$(realpath $(dirname $0)/../..)

cd $BASE_DIR

build_ogc_app init .

build_ogc_app build_docker
build_ogc_app build_cwl
