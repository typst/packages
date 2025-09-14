#import "../tblr.typ": *

#set page(height: auto, width: auto, margin: 2pt)
#show figure.where(kind: table): set figure.caption(position: top)

#tblr(columns: 7, header-rows: 2,
  stroke: none,
  // combine header cells
  cells((0, (1,4)), colspan: 3, stroke: (bottom: 0.03em)),
  column-gutter: 0.6em,
  // booktabs style rules
  rows(within: "header", auto, inset: (y: 0.5em)),
  rows(within: "header", auto, align: center),
  hline(within: "header", y: 0, stroke: 0.08em),
  hline(within: "header", y: end, position: bottom, stroke: 0.05em),
  rows(within: "body", 0, inset: (top: 0.5em)),
  hline(y: end, position: bottom, stroke: 0.08em),
  rows(end, inset: (bottom: 0.5em)),
  // table notes, remarks, and caption
  note((1, (1,4)), [$m v$ is in kg·m².]),
  note((1, (3,6)), [Time is in secs.]),
  note(sym.dagger, (2, 0), [Another note.]),
  remarks: [_Note:_ ] + lorem(18),
  caption: [This is a caption],
  note-fun: x => super(text(fill: blue, x)),
  note-numbering: "a",
  // content
  [], [tol $= mu_"single"$], [], [], [tol $= mu_"double"$], [], [],
  [], [$m v$], [Rel.~err], [Time], [$m v$], [Rel.~err], [Time], 
  [trigmv],  [11034], [1.3e-7], [3.9], [15846], [2.7e-11], [5.6], 
  [trigexpmv], [21952], [1.3e-7], [6.2], [31516], [2.7e-11], [8.8], 
  [trigblock], [15883], [5.2e-8], [7.1], [32023], [1.1e-11], [1.4e1], 
  [expleja], [11180], [8.0e-9], [4.3], [17348], [1.5e-11], [6.6])
  
