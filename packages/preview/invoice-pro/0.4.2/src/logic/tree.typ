#import "../loom-wrapper.typ": loom

/// Recursively traverses the component hierarchy of line items, bundles, and groups
/// to construct a flattened, ordered list of entries with hierarchical position IDs (e.g. 1, 2.1, 1.1.4)
/// and calculate group subtotals.
///
/// -> dictionary
#let resolve-tree-nodes(
  /// The list of child frames.
  /// -> array
  nodes,
  /// Prefix array of position counter parts.
  /// -> array
  prefix: (),
  /// Starting counter for this level.
  /// -> int
  start-counter: 1,
) = {
  let entries = ()
  let counter = start-counter

  for node in nodes {
    if node == none { continue }

    // If node is an array (e.g. from apply or nested structures), unpack recursively
    if type(node) == array {
      let sub-result = resolve-tree-nodes(
        node,
        prefix: prefix,
        start-counter: counter,
      )
      entries += sub-result.entries
      counter = sub-result.next-counter
      continue
    }

    if type(node) != dictionary { continue }
    let kind = node.at("kind", default: none)

    // Skip non-item motifs
    if (
      kind
        in ("tax-applicator", "modifier-applicator", "prepayment", "modifier")
    ) {
      continue
    }

    if kind == "group" {
      let current-pos = (..prefix, str(counter)).join(".")
      let group-data = node.signal

      let child-nodes = group-data.at("children", default: ())
      let child-result = resolve-tree-nodes(
        child-nodes,
        prefix: (..prefix, str(counter)),
        start-counter: 1,
      )

      let show-subtotal = group-data.at("show-subtotal", default: true)

      let group-subtotal = child-result
        .raw-items
        .map(i => i.at("total", default: decimal("0")))
        .sum(default: decimal("0"))

      entries.push((
        kind: "group-header",
        pos: current-pos,
        level: prefix.len() + 1,
        name: group-data.name,
        description: group-data.description,
      ))

      entries += child-result.entries

      if show-subtotal and child-result.raw-items.len() > 0 {
        entries.push((
          kind: "group-footer",
          pos: current-pos,
          level: prefix.len() + 1,
          name: group-data.name,
          subtotal: group-subtotal,
        ))
      }

      counter += 1
    } else if kind == "bundle" {
      let bundle-contents = if type(node.signal) == array {
        node.signal
      } else {
        (node.signal,)
      }
      let bundle-result = resolve-tree-nodes(
        bundle-contents,
        prefix: prefix,
        start-counter: counter,
      )
      entries += bundle-result.entries
      counter = bundle-result.next-counter
    } else if kind == "item" {
      let current-pos = (..prefix, str(counter)).join(".")
      let item-signal = node.signal
      if type(item-signal) == dictionary {
        entries.push((
          kind: "item",
          pos: current-pos,
          level: prefix.len(),
          raw: item-signal,
        ))
        counter += 1
      }
    }
  }

  let raw-items = entries
    .filter(e => e.kind == "item" and type(e.raw) == dictionary)
    .map(e => {
      let r = e.raw
      r.insert("pos", e.pos)
      r
    })

  return (
    entries: entries,
    raw-items: raw-items,
    next-counter: counter,
  )
}

/// Resolves the root line-items children into flattened entries and raw items with positions.
///
/// -> dictionary
#let resolve-tree(children) = {
  resolve-tree-nodes(children, prefix: (), start-counter: 1)
}
