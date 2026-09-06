#!/bin/bash

export MORMOT_PATH="/home/ubuntu/development/mORMot2"
DIR_PATH=$(dirname "$1")

fpc -v -Fu$MORMOT_PATH/src \
-Fu$MORMOT_PATH/src/core \
-Fu$MORMOT_PATH/src/app \
-Fu$MORMOT_PATH/src/core \
-Fu$MORMOT_PATH/src/crypt \
-Fu$MORMOT_PATH/src/db \
-Fu$MORMOT_PATH/src/lib \
-Fu$MORMOT_PATH/src/net \
-Fu$MORMOT_PATH/src/orm \
-Fu$MORMOT_PATH/src/rest \
-Fu$MORMOT_PATH/src/soa \
-Fu$MORMOT_PATH/src/script \
-Fu$MORMOT_PATH/src/tools/mget \
-Fi$MORMOT_PATH/src \
-Fl$MORMOT_PATH/static/aarch64-linux \
 $1