#import "internal.typ" as _internal

#import "load.typ" as load
#import "ctx.typ" as ctx
#import "value.typ" as value

/// Creates a new empty context and loads load bytes into it
/// ```examplec
/// let current-context = ctxjs.new-context(
///     ctxjs.load.eval("function preloaded() { return true; }")
/// )
/// ctxjs.ctx.eval(current-context, "preloaded()")
/// ```
/// -> bytes
#let new-context(
  /// load bytes `created by ctxjs.load.*`
  /// -> bytes
  ..load,
) = {
  return plugin.transition(_internal.wasm.new_context, _internal.build-load-data(load.pos()))
}
