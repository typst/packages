# Jogs

Quickjs javascript runtime for typst. This package provides a typst plugin for evaluating javascript code.

## Example

````typst
#import "@preview/jogs:0.2.0": *

#set page(height: auto, width: auto, fill: black, margin: 1em)
#set text(fill: white)

#let code = ```
function sum() {
  const total = Array.prototype.slice.call(arguments).reduce(function(a, b) {
      return a + b;
  }, 0);
  return total;
}

function string_join(arr) {
  return arr.join(" | ");
}

function return_complex_obj() {
  return {
    a: 1,
    b: "2",
    c: [1, 2, 3],
    d: {
      e: 1,
    },
  };
}

```
#let bytecode = compile-js(code)

#list-global-property(bytecode)

#call-js-function(bytecode, "sum", 6, 7, 8, 9, 10)

#call-js-function(bytecode, "string_join", ("a", "b", "c", "d", "e"),)

#call-js-function(bytecode, "return_complex_obj",)


````

result: 

![](typst-package/examples/fib.svg)

## Documentation

This package provide following function(s):

### `eval-js`

Run a Javascript code snippet.

#### Arguments
* `code` - The Javascript code to run. It can be a string or a raw block.

#### Returns
The result of the Javascript code. The type is the typst type which most closely resembles the Javascript type.

#### Example

```typ
#let result = eval-js("1 + 1")
```

### `compile-js`

Compile a Javascript code snippet into bytecode.

#### Arguments

* `code` - The Javascript code to compile. It can be a string or a raw block.

#### Returns

The bytecode of the Javascript code. The type is `bytes`.

#### Example

```typ
#let bytecode = compile-js("function sum(a, b) { return a + b; }")
```

### `call-js-function`

Call a Javascript function with arguments.

#### Arguments

* `bytecode` - The bytecode of the Javascript function. It can be obtained by calling `compile-js`.
* `name` - The name of the Javascript function.
* `..args` - The arguments to pass to the Javascript function. All other positional arguments are passed to the Javascript function as is.

#### Returns

The result of the Javascript function. The type is the typst type which most closely resembles the Javascript type.

#### Example

```typ
#let bytecode = compile-js("function sum(a, b) { return a + b; }")
#let result = call-js-function(bytecode, "sum", 1, 2)
```

### `list-global-property`

List all global properties of a compiled Javascript bytecode. This is useful for inspecting the compiled Javascript bytecode.

#### Arguments

* `bytecode` - The bytecode of the Javascript function. It can be obtained by calling `compile-js`.

#### Returns

A list of all global properties of the Javascript bytecode. The type is `array`.

#### Example

```typ
#let bytecode = compile-js("function sum(a, b) { return a + b; }")
#let result = list-global-property(bytecode)
```
