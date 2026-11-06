#import "internal.typ" as _internal

/// Loads the load bytes and always creates a new context.
/// ```examplec
/// ctxjs.ctx.load(
///   current-context,
///   ctxjs.load.eval("function fn() {}"),
/// )
/// ```
/// -> (<module>, none)
#let load(
  /// the context in which this function should run.
  /// -> <module>
  ctx,
  /// load bytes `created by ctxjs.load.*`
  /// -> bytes
  ..load,
) = {
  (
    plugin.transition(ctx.load, _internal.build-load-data(load.pos())),
    none,
  )
}

/// Evaluates the js code. It will returns a new context if transition is enabled, the current context if not and the value which returns from the js code.
/// ```examplec
/// ctxjs.ctx.eval(
///   current-context,
///   "1+1"
/// )
/// ```
/// -> (<module>, any)
#let eval(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the js code which should be evaluate
  /// -> str | bytes
  js,
  /// if a new context should be created (with changed data)
  /// -> bool
  transition: false,
) = {
  _internal.transition-call(
    ctx,
    ctx.eval,
    transition,
    bytes(js),
  )
}

/// Evaluates the js code. It will returns a new context if transition is enabled, the current context if not and the value which returns from the js code. Additional to @eval it supports formatting of the eval code with typst values.
///
/// ```examplec
/// ctxjs.ctx.eval(
///   current-context,
///   "1+1"
/// )
/// ```
/// -> (<module>, any)
#let eval-format(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the js code which should be evaluate
  /// -> str | bytes
  js,
  /// named args which replaces the name in the js code with the typst value as js value, only characters a-zA-Z0-9\_- as name are allowed
  /// -> any
  ..args,
  /// if a new context should be created (with changed data)
  /// -> bool
  transition: false,
) = {
  _internal.transition-call(
    ctx,
    ctx.eval_format,
    transition,
    bytes(js),
    cbor.encode(args.named()),
  )
}

/// Defines vars in a new context with given values.
/// ```examplec
/// ctxjs.ctx.define-vars(
///   current-context,
///   varname: "value"
/// )
/// ```
/// -> (<module>, none)
#let define-vars(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the context in which this function should run
  /// -> any
  ..vars,
) = {
  (
    plugin.transition(ctx.define_vars, cbor.encode(vars.named())),
    none,
  )
}

/// Calls a js function by function name with an args.
/// ```examplec
/// let (current-context,_) = ctxjs.ctx.eval(
///   current-context,
///   "function fnname() { return 1; }",
///   transition: true
/// )
/// ctxjs.ctx.call-function(
///   current-context,
///   "fnname",
///   varname: "value"
/// )
/// ```
/// -> (<module>, any)
#let call-function(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the function name
  /// -> str
  fnname,
  /// the args for the function
  /// -> any
  ..args,
  /// if a new context should be created (with changed data)
  /// -> bool
  transition: false,
) = {
  _internal.transition-call(
    ctx,
    ctx.call_function,
    transition,
    bytes(fnname),
    cbor.encode(args.pos()),
  )
}

/// Loads bytecode into a new context.
/// ```examplec
/// <<<ctxjs.ctx.load-module-bytecode(
/// <<<  current-context,
/// <<<  read("bytecode.kbc1", encoding: none),
/// <<<)
/// >>> (current-context,none)
/// ```
/// -> (<module>, none)
#let load-module-bytecode(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the bytecode mostly created by the @ctxjs_module_bytecode_builder
  /// -> bytes
  bytecode,
) = {
  (
    plugin.transition(ctx.load_module_bytecode, bytecode),
    none,
  )
}

/// Loads js module code into a new context.
/// ```examplec
/// ctxjs.ctx.load-module-js(
///   current-context,
///   "test_module",
///   "export function test() {}",
/// )
/// ```
/// -> (<module>, none)
#let load-module-js(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the module name
  /// -> str
  modulename,
  /// the js module code
  /// -> str | bytes
  module,
) = {
  (
    plugin.transition(
      ctx.load_module_js,
      bytes(modulename),
      bytes(module),
    ),
    none,
  )
}

/// Calls a js function in a module by function name with an args.
/// ```examplec
/// let (current-context,_) =  ctxjs.ctx.load-module-js(
///   current-context,
///   "test_module",
///   "export function test() {return \"foo\";}",
/// )
/// ctxjs.ctx.call-module-function(
///   current-context,
///   "test_module",
///   "test",
///   varname: "value"
/// )
/// ```
/// -> (<module>, any)
#let call-module-function(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the module name
  /// -> str
  modulename,
  /// the function name
  /// -> str
  fnname,
  /// the args for the function
  /// -> any
  ..args,
  /// if a new context should be created (with changed data)
  /// -> bool
  transition: false,
) = {
  _internal.transition-call(
    ctx,
    ctx.call_module_function,
    transition,
    bytes(modulename),
    bytes(fnname),
    cbor.encode(args.pos()),
  )
}

/// Get all properties from a module.
/// ```examplec
/// let (current-context,_) =  ctxjs.ctx.load-module-js(
///   current-context,
///   "test_module",
///   "export const key1 = 1;export const key2 = 1;",
/// )
/// ctxjs.ctx.get-module-properties(
///   current-context,
///   "test_module",
/// )
/// ```
/// -> (<module>, array)
#let get-module-properties(
  /// the context in which this function should run
  /// -> <module>
  ctx,
  /// the module name
  /// -> str
  modulename,
) = {
  (
    ctx,
    cbor(ctx.get_module_properties(bytes(modulename))),
  )
}
