// The box the layout RESERVES must be the box the drawing EMITS.
//
// These were once two hand-mirrored functions in two files, and every time one
// of them changed an inset or a font weight, the edge stopped touching the node
// in the other. Both now go through `node-body`, and this file is what keeps
// them honest: what `measure-node` reserves has to match, to the point, the
// fully painted body that `draw.typ` puts on the canvas — at every depth, in
// every style.
#import "../src/style.typ": default-emphasis-colors, default-ink, node-body, node-paint, node-spec
#import "../src/tree.typ": normalize
#import "../src/layout.typ": measure-node, measure-tree
#set page(width: auto, height: auto)

#context {
  let label = [Sample label]

  for style in ("boxed", "outline") {
    for depth in (0, 1, 2) {
      // An emphasized node is the case that used to break: it was measured in
      // regular and drawn in semibold, so the label outgrew its own box and
      // hyphenated. Both plain and emphasized have to agree.
      for emphasized in (false, true) {
        // What the layout pass reserves for this node...
        let reserved = measure-node(
          label, 6cm, "Inter", 9pt, style, depth, emphasized: emphasized,
        )
        // ...against the fully painted body the drawing pass actually emits.
        let spec = node-spec(style, depth, emphasized: emphasized)
        let role = if emphasized { default-emphasis-colors.warning } else { none }
        let painted = node-paint(spec, depth, red, default-ink, role)
        let drawn = measure(node-body(label, spec, painted, "Inter", 9pt))

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
  let plain = measure-node(label, 6cm, "Inter", 9pt, "outline", 2)
  let heavy = measure-node(label, 6cm, "Inter", 9pt, "outline", 2, emphasized: true)
  assert(heavy.w > plain.w, message: "an emphasized label should measure wider")

  // The two styles are genuinely different shapes, not the same one renamed.
  assert(node-spec("boxed", 0).frame == "box")
  assert(node-spec("boxed", 3).frame == "box")
  assert(node-spec("outline", 0).frame == "underline")
  assert(node-spec("outline", 1).frame == "side-rule")
  assert(node-spec("outline", 3).frame == "none")

  // In "outline" the root is typographically larger, so it must also measure
  // larger — if it did not, the layout would reserve the wrong band for it.
  let t = normalize((content: [Root], children: ((content: [Child],),)))
  let boxed = measure-tree(t, 6cm, "Inter", 9pt, "boxed")
  let outline = measure-tree(t, 6cm, "Inter", 9pt, "outline")
  assert(
    outline.h > outline.children.at(0).h,
    message: "an outline root should be taller than its leaf",
  )
  assert(boxed.h == boxed.children.at(0).h, message: "boxed nodes share one height")
}
#[OK]
