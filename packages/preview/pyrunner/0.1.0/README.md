# Typst Python Runner Plugin

Run python code in [typst](https://typst.app) using [RustPython](https://github.com/RustPython/RustPython).

````typst
#import "@preview/pyrunner:0.1.0" as py

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

## Current limitations

- No file and network IO due to limitations of typst plugin
- There is no way to import third-party modules. Only bundled stdlib modules are available.

