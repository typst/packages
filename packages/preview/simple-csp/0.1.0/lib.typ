#let bool = math.class("normal", "BOOL")
#let skip = math.op("Skip")
#let stop = math.op("Stop")

#let channel = math.op("channel")

#let cspleft = math.class("normal", "left")
#let forward = math.class("normal", "forward")
#let process = math.class("unary", "P")

#let extchoice = math.class("binary", sym.square.stroked)
#let hide = math.class("binary", sym.backslash)
#let interleave = math.class("binary", sym.bar.v.triple)
#let seq = math.class("relation", ";")
#let then = math.class("relation", sym.arrow.r)
#let tick = math.class("normal", sym.checkmark)

#let tracerefby = math.class("relation", $attach(subset.eq.sq, br: T)$)

#let tracel = math.class("opening", sym.chevron.l)
#let tracer = math.class("closing", sym.chevron.r)
