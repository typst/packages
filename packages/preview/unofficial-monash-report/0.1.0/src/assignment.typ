#import "options.typ": validate, require
#import "common.typ": document-style
#import "titleblock.typ": titleblock
#let assignment(body, ..args) = {
  require("arguments", args.pos().len() == 0, "named options after the body")
  require("body", type(body) == content, "content")
  let o = validate("assignment", args.named()) + (mode: "assignment")
  document-style(o, [#titleblock(o)#body])
}
