// The box the layout RESERVES must be the box the drawing EMITS.
//
// These were once two hand-mirrored functions in two files, and every time one
// of them changed an inset or a font weight, the edge stopped touching the node
// in the other. Both now go through `node-body`, and this file is what keeps
// them honest: what `measure-node` reserves has to match, to the point, the
// fully painted body that `draw.typ` puts on the canvas — at every depth, in
// every style.
#import "../src/options.typ": make-opts
#import "../src/style.typ": node-body, node-paint, node-spec
#import "../src/tree.typ": normalize
#import "../src/layout.typ": dressing, measure-node, measure-tree
#set page(width: auto, height: auto)

#context {
  let label = [Sample label]

  for style in ("boxed", "outline") {
    let opts = make-opts(style: style)
    for depth in (0, 1, 2) {
      // An emphasized node is the case that used to break: it was measured in
      // regular and drawn in semibold, so the label outgrew its own box and
      // hyphenated. Both plain and emphasized have to agree.
      for emphasized in (false, true) {
        // What the layout pass reserves for this node...
        let n = normalize((content: label, emphasis: if emphasized { "warning" } else { none }))
        let dress = dressing(n, depth, 0, opts)
        let reserved = measure-node(label, depth, opts, dress)
        // ...against the fully painted body the drawing pass actually emits.
        let spec = node-spec(style, depth, emphasized: dress.emphasized, surfaced: dress.surfaced)
        let role = if emphasized { opts.emphasis-colors.warning } else { none }
        let painted = node-paint(spec, depth, red, opts.ink, role)
        let drawn = measure(node-body(label, spec, painted, "Inter", 9pt, number: dress.number))

        assert(
          calc.abs(reserved.w - drawn.width.pt()) < 0.001
            and calc.abs(reserved.h - drawn.height.pt()) < 0.001,
          message: "the layout reserves a different box than the one drawn ("
            + style + ", depth " + str(depth) + ", emphasized "
            + (if emphasized { "yes" } else { "no" }) + "): reserved " + str(reserved.w) + "×"
            + str(reserved.h) + ", drawn " + str(drawn.width.pt()) + "×"
            + str(drawn.height.pt()),
        )
      }
    }
  }

  // An emphasized leaf really is wider than a plain one — if this ever stops
  // holding, the assert above would pass for the wrong reason.
  let outline = make-opts(style: "outline")
  let plain = measure-node(label, 2, outline, dressing(normalize((content: label)), 2, 0, outline))
  let heavy = measure-node(label, 2, outline, dressing(normalize((content: label, emphasis: "warning")), 2, 0, outline))
  assert(heavy.w > plain.w, message: "an emphasized label should measure wider")

  // The two styles are genuinely different shapes, not the same one renamed.
  assert(node-spec("boxed", 0).frame == "box")
  assert(node-spec("boxed", 3).frame == "box")
  assert(node-spec("outline", 0).rule != none, message: "an outline root sits over a rule")
  assert(node-spec("outline", 1).capsule, message: "an outline branch has a capsule")
  assert(node-spec("outline", 3).frame == "none")

  // In "outline" the root is typographically larger, so it must also measure
  // larger — if it did not, the layout would reserve the wrong band for it.
  let t = normalize((content: [Root], children: ((content: [Child],),)))
  let boxed = measure-tree(t, make-opts(style: "boxed"))
  let outlined = measure-tree(t, outline)
  assert(
    outlined.h > outlined.children.at(0).h,
    message: "an outline root should be taller than its leaf",
  )
  assert(boxed.h == boxed.children.at(0).h, message: "boxed nodes share one height")
}
#[OK]
