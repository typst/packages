# CtxJS

A typst plugin to evaluate javascript code.

- multiple javascript contexts
- load javascript modules as source or bytecode
- simple evaluations
- formated evaluations (execute your code with your typst data)
- call functions
- call functions in modules
- create bytecode with an extra tool (ctxjs_module_bytecode_builder)
- allow later evaluation of javascript code

## Example

```typst
#import "@preview/ctxjs:0.2.0"

#{
  _ = ctxjs.create-context("context_name")
  let test = ctxjs.eval("context_name", "function test(data) {return data + 2;}")
  let returns-4 = ctxjs.call-function("context_name", "test", (2,))
  let returns-6 = ctxjs.eval-format("context_name", "test({test})", (test: 4))
  let code = ```
    export function another_test_function() { return {data: 'test'}; }
  ```;
  _ = ctxjs.load-module-js("context_name", "module_name", code.text)
  let returns-array-with-another-test = ctxjs.get-module-properties("context_name", "module_name")
  let returns-data-with-test-string = ctxjs.call-module-function("context_name", "module_name", "another_test_function", ())
  let returns-8 = ctxjs.eval-format("context_name", "test({test})", (test: ctxjs.eval-later("4 + 4")))
}
```
