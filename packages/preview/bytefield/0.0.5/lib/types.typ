// bf-field
#let bf-field(type, index, data: none) = (
  bf-type: "bf-field",
  field-type: type, 
  field-index: index,
  data: data, 
)

// data-field holds information about an field inside the main grid.
#let data-field(index, size, start, end, label, format: none) = {
  bf-field("data-field", index,
    data: (
      size: size,
      range: (start: start, end: end),
      label: label,
      format: format,
    )
  )
}

// note-field holds information about an field outside (left or right) the main grid.
#let note-field(index, anchor, side, level:0, label, format: none, rowspan: 1) = {
  bf-field("note-field", index,
    data: (
      anchor: anchor,
      side: side,
      level: level,
      label: label,
      format: format,  // TODO
      rowspan: rowspan,
    )
  )
}

// header-field hold information about a complete header row. Usually this is the top level header.
#let header-field(start: auto, end: auto, autofill: auto, numbers: (), labels: (:), ..args) = {
  // header-field must have index 0.
  bf-field("header-field", none,
    data: (
      // This is at the moment always 0 - (bpr), but in the future there might be header fields between data rows. 
      range: (start: start, end: end),
      // Defines which numbers should be shown. Possible none or array if numbers.
      numbers: numbers,
      // Defines which labels should be shown. Dict of number and content.
      labels: labels,
      // Defines which numbers should be calculated automatically 
      autofill: autofill,
      // Defines the format of the bitheader.
      format: (
        // Defines the angle of the labels 
        angle: args.named().at("angle", default: -60deg),
        // Defines the text-size for both numbers and labels.
        text-size: args.named().at("text-size",default: auto), 
        // Defines if a marker should be shown
        marker: args.named().at("marker", default: true),
        // Defines the background color.
        fill: args.named().at("fill", default: none),
        // Defines the border stroke.
        stroke: args.named().at("stroke", default: none),
      )
    )
  )
}

// bf-cell holds all information which are necessary for cell positioning inside the table. 
#let bf-cell(type, grid: center, x: auto, y: auto, colspan:1, rowspan:1, label: none, cell-index: (auto, auto) ,format: auto) = (
  bf-type: "bf-cell",
  cell-type: type,
  // cell index is a tuple (field-index, slice-index)
  cell-index: cell-index,  
  // position specifies the grid and and the position inside the grid. 
  position: (
    grid: grid,
    x: x,
    y: y,
  ),
  span: (
    rows: rowspan,
    cols: colspan,
  ),
  // The text which will be shown.
  label: label,
  // specified format for the label like fill, stroke, align, inset, ...
  format: format,
)