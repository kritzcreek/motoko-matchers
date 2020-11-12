#!/usr/bin/env bash

set -eo pipefail


echo "Checking Canister.mo compiles"
moc --package base ../../motoko-base/src ../src/Canister.mo

moc --package base ../../motoko-base/src -wasi-system-api Test.mo
# if wasmtime Test.wasm ; then
#     echo "Tests failed to fail"
#     exit 1
# else
#     echo "Tests successfully failed"
#     exit 0
# fi
