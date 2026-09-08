#import "/core/util.typ": handle

#let theme = (
  // Render text outputs as raw blocks
  "text/plain": handle.with(mime: "text-console-block"),
  stream-generic: handle.with(mime: "text-console-block"),
  error: (data, ..args) => handle(data.message, ..args, mime: "text-console-block"),
)
