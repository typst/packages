# CtxJS

## Description

A typst plugin to evaluate javascript code.

- multiple javascript contexts
- load javascript modules as source or bytecode
- simple evaluations
- formated evaluations (execute your code with your typst data)
- call functions
- call functions in modules
- create quickjs bytecode with an extra tool, to improve loading performance (ctxjs_module_bytecode_builder)
- allow later evaluation of javascript code
- allow loading json directly
- convert images to data urls

## Documentation

### New context

Creates a new context to work with and preloaded with a simple evaluated js file and a function.
It is recommend to build your own js file to an esm file and create bytecode from it via ctxjs_module_bytecode_builder.

```typ
#import "@preview/ctxjs:0.4.1"
#import ctxjs.load
#import ctxjs.ctx
#import ctxjs.value

#let current-context = ctxjs.new-context(
  load.eval(read("main.js", encoding: none)),
  // load.load-module-bytecode(read("main.kbc1", encoding: none)),
)
```

### Working with context

On calling any ctx function a new or the current context gets returned with a value as an array.
Its recommend always use the destructuring syntax to be safe that we are always use the correct context.
```example
#let (current-context, value) = ctx.eval(current-context, "123")
#value
```
If you do not need the value, its safe to ignore it:
```example
#let (current-context, _) = ctx.eval(current-context, "123")
value gets ignored
```

### Full documentation with guide

A full documentation can be found here: [docs.pdf](https://raw.githubusercontent.com/lublak/typst-ctxjs-package/refs/tags/v0.4.1/docs.pdf)

## An actively used package

To get a picture what is possible with ctxjs there is a package based on echarts embedded into typst.
It uses a custom js module code to wrap the echarts code in a single function.
The package uses ctxjs_module_bytecode_builder to build the js module code into bytecode.
And it get loaded by typst into a context and the js function gets called.
Which than returns an svg which can be used on the typst side.

[Echarm](https://github.com/lublak/typst-echarm-package)