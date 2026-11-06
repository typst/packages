/// Built-in material hatch pattern: Grass
#let grass-fill(s: 1.0) = tiling(size: (5pt * s, 8pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #std.rotate(270deg)[
    #text(fill: green)[#sym.prec]]
  ]
]

// ==========================================
// ARCHITECTURAL WALL FILLS & HATCHING (Typst 0.14+ Ready & Scalable)
// ==========================================

// 1. BRICK WALL (Classic staggered brick pattern)
#let pat-brick(s: 1.0) = tiling(size: (10pt * s, 10pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 5pt), end: (10pt, 5pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (0pt, 10pt), end: (10pt, 10pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (5pt, 0pt), end: (5pt, 5pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (0pt, 5pt), end: (0pt, 10pt), stroke: 0.25pt + luma(80)))
  ]
]

// 2. POURED CONCRETE (Random stippling dots and aggregate triangles)
#let pat-concrete(s: 1.0) = tiling(size: (12pt * s, 12pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(dx: 2pt, dy: 2pt, circle(radius: 0.4pt, fill: luma(80)))
    #place(dx: 8pt, dy: 9pt, circle(radius: 0.6pt, fill: luma(80)))
    #place(dx: 4pt, dy: 11pt, circle(radius: 0.3pt, fill: luma(80)))
    #place(dx: 5pt, dy: 4pt)[#polygon((0pt,0pt), (2pt,2pt), (0pt,3pt), stroke: 0.2pt + luma(80))]
    #place(dx: 9pt, dy: 2pt)[#polygon((0pt,0pt), (3pt,1pt), (1pt,3pt), stroke: 0.2pt + luma(80))]
  ]
]

// 3. CONCRETE BLOCK / CMU (Standard 45-degree crosshatch)
#let pat-cmu(s: 1.0) = tiling(size: (8pt * s, 8pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 0pt), end: (8pt, 8pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (8pt, 0pt), end: (0pt, 8pt), stroke: 0.25pt + luma(80)))
  ]
]

// 4. CERAMIC TILE (Clean square grid)
#let pat-ceramic(s: 1.0) = tiling(size: (8pt * s, 8pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 0pt), end: (8pt, 0pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (0pt, 0pt), end: (0pt, 8pt), stroke: 0.25pt + luma(80)))
  ]
]

// 5. METAL / STEEL WALL (ANSI Standard double-diagonal lines)
#let pat-metal(s: 1.0) = tiling(size: (12pt * s, 12pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 0pt), end: (12pt, 12pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (0pt, 3pt), end: (9pt, 12pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (3pt, 0pt), end: (12pt, 9pt), stroke: 0.25pt + luma(80)))
  ]
]

// 6. WOOD WALL / GRAIN (Vertical, organic waves matching your sketch)
#let pat-wood(s: 1.0) = tiling(size: (20pt * s, 20pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    // Far left wave
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((3pt, 0pt)), curve.quad((7pt, 10pt), (2pt, 20pt))
    ))
    
    // Mid left wave
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((8pt, 0pt)), curve.quad((12pt, 10pt), (7pt, 20pt))
    ))
    
    // The center "Knot / Split" (The inverted 'Y' shape from your image)
    // Top stem coming down
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((13pt, 0pt)), curve.quad((12pt, 6pt), (13pt, 12pt))
    )) 
    // Bottom left leg of the split
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((13pt, 12pt)), curve.quad((10pt, 16pt), (10pt, 20pt))
    )) 
    // Bottom right leg of the split
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((13pt, 12pt)), curve.quad((16pt, 16pt), (15pt, 20pt))
    )) 
    
    // Far right wave
    #place(curve(stroke: 0.4pt + luma(80), 
      curve.move((18pt, 0pt)), curve.quad((16pt, 10pt), (19pt, 20pt))
    ))
  ]
]

// 7. LUMBER WALL (Standard parallel diagonal siding)
#let pat-lumber(s: 1.0) = tiling(size: (8pt * s, 8pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 0pt), end: (8pt, 8pt), stroke: 0.25pt + luma(80)))
  ]
]

// 8. PLYWOOD WALL (Alternating diagonal hash marks)
#let pat-plywood(s: 1.0) = tiling(size: (10pt * s, 10pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(line(start: (0pt, 5pt), end: (5pt, 0pt), stroke: 0.25pt + luma(80)))
    #place(line(start: (5pt, 10pt), end: (10pt, 5pt), stroke: 0.25pt + luma(80)))
  ]
]

// 9. STONE WALL (Irregular geometric polygons)
#let pat-stone(s: 1.0) = tiling(size: (16pt * s, 16pt * s))[
  #scale(x: s * 100%, y: s * 100%, origin: top + left)[
    #place(dx: 2pt, dy: 2pt)[#polygon((0pt,0pt), (4pt,-1pt), (6pt,3pt), (1pt,5pt), stroke: 0.25pt + luma(80))]
    #place(dx: 9pt, dy: 8pt)[#polygon((0pt,0pt), (4pt,2pt), (1pt,6pt), (-2pt,3pt), stroke: 0.25pt + luma(80))]
  ]
]