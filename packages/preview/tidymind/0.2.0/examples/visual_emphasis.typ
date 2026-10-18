// Roles and branch colors travel by NAME. The document says "this is a warning"
// and "put this branch on color 5"; the package resolves both.
#import "@preview/tidymind:0.2.0": mindmap, node
#set page(width: auto, height: auto, margin: 10pt)
#mindmap(
  node([SQL privileges],
    node([GRANT],
      node([Idempotent], emphasis: "definition"),
      node([Cascades to dependents], emphasis: "warning"),
    ),
    node([REVOKE], branch: 5,
      node([RESTRICT is the default], emphasis: "highlight"),
      node([`REVOKE ALL ON t FROM u`], emphasis: "example"),
    ),
  ),
  style: "outline",
)
