// simple boxes that can be useful to separate ideas from the main text 
// that are too big to be footnotes, or just do not work as a footnote.

// usage:
// #<variation>box(header:[I am the header])[This is the body paragraph]

#let box_prototype(header, icon, iconlabel, color, body) = {
  block(inset: (left: 4pt), breakable: false)[
  #block(
  fill: luma(15),
  inset: (left: -3pt, top: -3pt),
  outset: (right: 3pt, bottom: 3pt),
  )[
    #table(
      fill: white,
      columns: 2,
      inset: 8pt,
      stroke: luma(15) + 1.2pt,
      table.cell(inset:5pt, fill:color)[#grid(
        columns: 2,
        gutter:1mm,
        image(icon, height: 12pt),
        grid.cell(align: horizon)[*#iconlabel*]
      )
      ],[*#header*], 
      table.cell(colspan: 2)[#body], 
  )
  ]]
}

#let notebox(header:none, body) = { 
  box_prototype(header,
  "../assets/boxes_symbols/note_stack_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg","Note", 
  rgb(232,201, 78), body)
}

#let calcbox(header:none, body) = { 
  box_prototype(header,
  "../assets/boxes_symbols/calculate_24dp_1F1F1F_FILL0_wght400_GRAD0_opsz24.svg", "Calculation",
  rgb(131, 138, 198), body)
}