#!/bin/bash

cd interpreter
mkdir -p build
cd build
cmake ../
make -j
cp sf-interpreter ../../bin/interpreter
cd ..
