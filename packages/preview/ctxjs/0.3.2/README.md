# CtxJS

A typst plugin to evaluate javascript code.

- multiple javascript contexts
- load javascript modules as source or bytecode
- simple evaluations
- formated evaluations (execute your code with your typst data)
- call functions
- call functions in modules
- create quickjs bytecode with an extra tool, to improve loading performance (ctxjs_module_bytecode_builder)
- allow later evaluation of javascript code
- convert images to data urls

## Example

```typst
#import "@preview/ctxjs:0.3.0"
#import ctxjs.load
#import ctxjs.ctx

#{
  let dataurl = ctxjs.image-data-url("path_or_bytes.png")
  let newcontext = ctxjs.new-context(
    (
      load.eval("function test(data) {return data + 2;}"),
    )
  )
  let returns-4 = ctx.call-function(newcontext, "test", (2,))
  let returns-6 = ctx.eval-format(newcontext, "test({test})", (test: 4))
  let code = ```
    export function another_test_function() { return {data: 'test'}; }
  ```;
  let anothernewcontext = ctx.load-module-js(newcontext, "module_name", code.text)
  let returns-array-with-another-test = ctx.get-module-properties(anothernewcontext, "module_name")
  let returns-data-with-test-string = ctx.call-module-function(anothernewcontext, "module_name", "another_test_function", ())
  let returns-8 = ctx.eval-format(anothernewcontext, "test({test})", (test: ctx.eval-later("4 + 4")))
}
```