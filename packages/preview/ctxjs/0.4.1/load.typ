#import "internal.typ" as _internal

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.eval at loading.
/// ```examplec
/// ctxjs.load.eval("function fn() {}")
/// ```
/// -> bytes
#let eval(js) = {
  _internal.build-load-argument(_internal.load-eval, bytes(js))
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.eval-format at loading.
/// ```examplec
/// ctxjs.load.eval-format("function() {return value;}", value: 1)
/// ```
/// -> bytes
#let eval-format(js, ..args) = {
  _internal.build-load-argument(_internal.load-eval-format, cbor.encode((js, args.named())))
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.define-vars at loading.
/// ```examplec
/// ctxjs.load.define-vars(var1: 1, var2: 2)
/// ```
/// -> bytes
#let define-vars(..vars) = {
  _internal.build-load-argument(_internal.load-define-vars, cbor.encode(vars.named()))
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.call-function at loading.
/// ```examplec
/// ctxjs.load.call-function("fnname", 1)
/// ```
/// -> bytes
#let call-function(fnname, ..args) = {
  _internal.build-load-argument(_internal.load-call-function, cbor.encode((fnname, args.pos())))
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.eval at loading.
/// ```examplec
/// <<<ctxjs.load.load-module-bytecode(read("bytecode.kbc1"))
/// >>>bytes("some fake data just to show a possible result")
/// ```
/// -> bytes
#let load-module-bytecode(bytecode) = {
  _internal.build-load-argument(_internal.load-load-module-bytecode, bytecode)
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.load-module-js at loading.
/// ```examplec
/// ctxjs.load.load-module-js(
///   "example_module",
///   "export function test() {}",
/// )
/// ```
/// -> bytes
#let load-module-js(modulename, module) = {
  _internal.build-load-argument(_internal.load-load-module-js, cbor.encode((modulename, module)))
}

/// Creates load bytes for @ctxjs.new-context or @ctx.load.
/// Same function as @ctx.call-module-function at loading.
/// ```examplec
/// ctxjs.load.call-module-function("example_module", "text", arg1: 1)
/// ```
/// -> bytes
#let call-module-function(modulename, fnname, ..args) = {
  _internal.build-load-argument(_internal.load-call-module-function, cbor.encode((modulename, fnname, args.pos())))
}
