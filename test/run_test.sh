#!/usr/bin/env bash

set -eo pipefail

$(vessel bin)/moc $(vessel sources) -wasi-system-api Test.mo

if wasmtime Test.wasm ; then
    echo "Tests failed to fail"
    exit 1
else
    echo "Tests successfully failed"
    exit 0
fi