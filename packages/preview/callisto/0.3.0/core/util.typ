#import "ctx/handling.typ": all-handlers

// Wrap the argument in an array if it is not itself an array
#let ensure-array(x) = if type(x) == array { x } else { (x,) }

// Return the first positional argument that is different from `on`,
// or return `on` if none is different.
#let coalesce(on: none, ..args) = {
  for x in args.pos() {
    if x != on { return x }
  }
  return on
}

// Handle the given data using the handler registered for the given mime
// type, forwarding the 'args' arguments to the handler.
// Before calling the handler, the context is updated to include
// 'mime' as an extra field.
#let handle(data, mime: none, ctx: none, ..args) = {
  if ctx == none {
    panic("ctx not set")
  }
  if mime not in ctx.handlers {
    panic("no handle registered for MIME " + repr(mime))
  }
  let handler = ctx.handlers.at(mime)
  if handler == none {
    return none
  }
  ctx.mime = mime
  handler(data, ctx: ctx, ..args)
}
