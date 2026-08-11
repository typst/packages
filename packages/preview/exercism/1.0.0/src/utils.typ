#import "@preview/digestify:0.1.0": bytes-to-hex, sha224

#let global-prefix = "__exercism"
#let global-name(..args) = global-prefix + ":" + args.pos().join(":")

#let error(msg) = panic("exercism: " + msg)

#let hash(content) = bytes-to-hex(sha224(bytes(repr(content))))

#let and_then(bool, val) = if bool { val } else { none }
#let map(val, f) = if val != none { f(val) } else { val }
#let map_or(val, f, oth) = if val != none { f(val) } else { oth }
#let map_if(val, bool, f) = if bool { f(val) } else { val }
