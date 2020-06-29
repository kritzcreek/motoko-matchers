all:
	moc $(shell vessel --package-set ../package-set.json sources) -wasi-system-api Test.mo && wasmtime Test.wasm

.PHONY: all