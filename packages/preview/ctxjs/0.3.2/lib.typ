#let ctxjs = plugin("ctxjs.wasm")

#import "load.typ" as load
#import "ctx.typ" as ctx

#let new-context(load: ()) = {
  return plugin.transition(ctxjs.new_context, cbor.encode(load))
}


#let image-data-url(data) = {
  if type(data) == str {
    data = read(data, encoding: none)
  }
  return str(ctxjs.image_data_url(data))
}
