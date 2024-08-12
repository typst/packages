#import "styles.typ": *
#import "note.typ"

// Query is an array of key, value, and inherit
#let recurse-columns(columns, queries) = {
  for column in columns {
    let queries = queries
    for (key, query) in queries {
      let default = query.at("default", default: none)
      let value = query.at("value", default: default)
      queries.at(key).value = column.at(
        key, 
        default: if (query.at("inherit", default: true)) {
          value
        } else {query.default}
      )
    }

    if "children" in column {
      recurse-columns(
        column.children,
        queries
      )
    } else {
      (queries,)
    }
  }
}

#let build-header(columns, max-depth: 1, start: 0) = {
  // For every column
  for entry in columns {

    if (entry.length == 0) {continue}
    // Make a cell that spans its recusive length (and limit rowspan if it has children)
    (table.cell(
      x: start,
      y: entry.depth,
      rowspan: if entry.length == 1 {max-depth - entry.depth} else {1},
      colspan: entry.length,

      // Header cells should be horizon aligned. Ideally it should default to `start`
      // but I've shadowed that variable.
      align: horizon + entry.at("align", default: left),
      entry.header
    ),)

    // If it has nested columns, build those too.
    // NOTE: Return values are collated using automatic array joining!
    if "children" in entry and entry.children.len() > 0 {
      build-header(
        entry.children, 
        max-depth: max-depth,
        start: start // Pass along 
      )
    }

    // If it has a hline, add it under the cell
    if ("hline" in entry){
      (
        table.hline(
          y: entry.depth + 1, 
          start: start, 
          end: start + entry.length, 
          ..entry.hline
        ),
      )
    }

    if ("vline" in entry){ (table.vline(x: start + 1, ..entry.vline),) }

    // Keep track of which column we are in. This could be precalculated.
    start += entry.length
  }
}

#let sanitize-input(columns, depth: 0, max-depth: 1, length: 0) = {

  // For every column
  for (key, entry) in columns.enumerate() {

    // if it has children
    if "children" in entry {

      // Recurse
      let (children, child-depth, child-length) = sanitize-input(
        entry.children, 
        depth: depth + 1, 
        max-depth: max-depth + 1
      )

      // record the recursive length
      columns.at(key).insert("length", child-length)      
      columns.at(key).children = children
      length += child-length

      // Keep track of the deepest yet seen rabit hole
      max-depth = calc.max(max-depth, child-depth)

    // Bottom of the rabit hole, must have a length of 1
    } else {
      length += 1
      columns.at(key).insert("length", 1)
    }

    // In all cases, keep track of depth
    columns.at(key).insert("depth", depth)
  }

  // Pass the results on
  return (columns, max-depth, length)
}

#let data-from-key(dictionary, key, default: none) = {
  if type(key) == str { key = key.split(".").rev()}
  if (key.len() == 1){ return dictionary.at(key.last(), default: default) }
  data-from-key(
    dictionary.at(key.pop(), default: (:)), 
    key, 
    default: default
  )
}

/// Renders a table following a given column specification
/// - columns (array): 
/// - data (array):
/// - hline (content): Content to be rendered after each row of `data`. Typically `table.hline(...)` but there's probably some funky uses
/// - toprule (arguments): 
/// - midrule (arguments): 
/// - bottomrule (arguments): 
/// - notes (content): 
#let make(
  columns: (), 
  data: (), 
  hline: none,
  toprule: toprule,
  midrule: midrule,
  bottomrule: bottomrule,
  notes: note.display-list,
  ..args
) = {

  let (columns, max-depth, length) = sanitize-input(columns, depth: 0)
  let query-result = recurse-columns(columns, (
    fill: (inherit: true, default: none),
    align: (inherit: true, default: start),
    gutter: (inherit: true, default: 0em),
    width: (inherit: true, default: auto),
    display: (inherit: true, default: none),
    key: (inherit: false, default: ""),
  ))
  let row-display = query-result.map(it=>it.key.value).zip(
    query-result.map(it=>it.display.value)
  )

  set text(size: 9pt)
  set math.equation(numbering: none)
  
  note.clear() + table(  // ADDED
    stroke: none,
    fill: query-result.map(it=>it.fill.value),
    align: query-result.map(it=>it.align.value),
    column-gutter: query-result.map(it=>it.gutter.value),
    columns: query-result.map(it=>it.width.value),
    table.header(
      table.hline(stroke: toprule),
      ..build-header(columns, max-depth: max-depth),
      table.hline(stroke: midrule, y: max-depth),
    ),
    ..args,
    ..(
      for entry in data{ 
        row-display.map( ((key, display))=>{
          let data = data-from-key(entry, key, default: none)
          if ((display) == none) {return data}
          display(data)
        })
        if hline != none {(hline,)}
      }
    ),
    table.hline(stroke: bottomrule)
  ) + if (notes != none) {note.display-style(notes)} // ADDED
  
}

