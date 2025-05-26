# Typst Python Runner Plugin
[![CI](https://github.com/peng1999/typst-pyrunner/actions/workflows/ci.yml/badge.svg)](https://github.com/peng1999/typst-pyrunner/actions/workflows/ci.yml)

Run python code in [typst](https://typst.app) using [RustPython](https://github.com/RustPython/RustPython).

````typst
#import "@preview/pyrunner:0.3.0" as py

#let compiled = py.compile(
```python
def find_emails(string):
    import re
    return re.findall(r"\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}\b", string)

def sum_all(*array):
    return sum(array)
```)

#let txt = "My email address is john.doe@example.com and my friend's email address is jane.doe@example.net."

#py.call(compiled, "find_emails", txt)
#py.call(compiled, "sum_all", 1, 2, 3)
````

Block mode is also available.

````typst
#let code = ```
f'{a+b=}'
```

#py.block(code, globals: (a: 1, b: 2))

#py.block(code, globals: (a: "1", b: "2"))
````

The result will be `a+b=3` and `a+b='12'`.

## Current limitations

Due to restrictions of typst and its plugin system, some Python function will not work as expected:
- File and network IO will always raise an exception.
- `datatime.now` will always return 1970-01-01.

Also, there is no way to import third-party modules. Only bundled stdlib modules are available. We might find a way to lift this restriction, so feel free to submit an issue if you want this functionality.

## API
### `block`
Run Python code block and get its result.

#### Arguments
- `code` : string | raw content - The Python code to run.
- `globals` : dict (named optional) - The global variables to bring into scope.

#### Returns
The last expression of the code block.

### `compile`
Compile Python code to bytecode.

#### Arguments
- `code` : string | raw content - The Python code to compile.

#### Returns
The bytecode representation in `bytes`.

### `call`
Call a python function with arguments.

#### Arguments
- `compiled` : bytes - The bytecode representation of Python code.
- `fn_name` : string - The name of the function to be called.
- `..args` : any - The arguments to pass to the function.

#### Returns
The result of the function call.

## Build from source

Install [`wasi-stub`][]. You should use a slightly modified one. See [the related issue](https://github.com/astrale-sharp/wasm-minimal-protocol/issues/22#issuecomment-1827379467).

[`wasi-stub`]: https://github.com/astrale-sharp/wasm-minimal-protocol

<!-- ```
cargo install --git https://github.com/astrale-sharp/wasm-minimal-protocol.git wasi-stub
```-->

Build pyrunner.

```
rustup target add wasm32-wasip1
cargo build --release --target wasm32-wasip1
make pkg/typst-pyrunner.wasm
```

Add to local package.

```
make install BUILD_TYPE=release
```
