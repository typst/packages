#import "/core/util.typ": handle

// Preprocess error item
#let preprocess(item, ctx: none) = (
  name: item.ename,
  message: item.evalue,
  traceback: item.traceback,
)
