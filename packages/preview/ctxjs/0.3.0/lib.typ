#let ctxjs = plugin("ctxjs.wasm")

#import "load.typ" as load
#import "ctx.typ" as ctx

#let new-context(load: ()) = {
  return plugin.transition(ctxjs.new_context, cbor.encode(load))
}