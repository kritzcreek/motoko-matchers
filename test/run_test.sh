#!/usr/bin/env bash

../bin/moc $(shell vessel --package-set ../package-set.json sources) -wasi-system-api Test.mo

if wasmtime Test.wasm ; then
    echo "Tests failed to fail"
    exit 1
else
    echo "Tests successfully failed"
    exit 0
fi