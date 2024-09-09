# CtxJS

A typst plugin to evaluate javascript code.

- multiple javascript contexts
- load javascript modules as source or bytecode
- simple evaluations
- formated evaluations (execute your code with your typst data)
- call functions
- call functions in modules
- create bytecode with an extra tool (ctxjs_module_bytecode_builder)

## Example

```typst
#import "@preview/ctxjs:0.1.0"

#{
  _ = ctxjs.create_context("context_name")
  let test = ctxjs.eval("context_name", "function test(data) {return data + 2;}")
  let returns_4 = ctxjs.call_function("context_name", "test", (2,))
  let returns_6 = ctxjs.eval_format("context_name", "test({test})", (test:4))
  let code = ```
    export function another_test_function() { return {data: 'test'}; }
  ```;
  _ = ctxjs.load_module_js("context_name", "module_name", code.text)
  let returns_array_with_another_test = ctxjs.get_module_properties("context_name", "module_name")
  let returns_data_with_test_string = ctxjs.call_module_function("context_name", "module_name", "another_test_function", ())
}
```