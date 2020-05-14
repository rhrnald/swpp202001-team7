#!/bin/bash

rm -f sf-interpreter
mkdir -p build
cd build
cmake ../
make -j
cp sf-interpreter ../
cd ..
