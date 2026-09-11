// #import "/moustaches.typ": *

/// Writes the quotient `a / b`, where `a` and `b` are floating-point numbers
/// (or simply `a` if `b = 1`), together with its reduced fractional form
/// (up to 6 decimal places). -> content
#let simpli(
  /// -> int | float
  a,
  /// -> int | float
  b,
) = {}

/// Computes the greatest common divisor (GCD) of a list of numbers. -> int
#let pgcd(
  /// List of numbers -> array
  ..a
) = {}

/// Draws a band chart. -> content
#let bandes(
  /// Categories (modalities) -> array
  valeurs:(),
  /// Counts of each category -> array
  effectifs:(),
  /// Total width of the chart -> length
  width:1fr,
  /// Indices of labels to rotate by 90° -> array
  tourne:(),
  /// List of rectangle colors -> auto | array
  couleurs:auto,
  /// If `true`, replaces colors with tiling patterns -> boolean
  print:false,
  /// Construction steps to explain, e.g. `(0,)` or `(0,3)` -> array
  explication:(),
  /// Height of the band chart -> length
  hauteur:40pt,
) = {}

/// Draws a (semi-)pie chart. -> content
#let camembert(
  /// Categories (modalities) -> array
  valeurs:(),
  /// Counts of each category -> array
  effectifs:(),
  /// Allows passing a single data array instead -> array
  data:(),
  /// If `true`, draws a semicircular chart -> boolean
  semi:false,
  /// Legend position: `"d"` (right), `"g"` (left), `"h"` (top), `"b"` (bottom), or `""` for none -> str
  legende:"d",
  /// Spacing between legend items when the legend is on the left or right -> int | float
  espace:.1,
  /// If `true`, replaces colors with tiling patterns -> boolean
  print:false,
  /// List of sector colors -> auto | array
  couleurs:auto,
  /// `true`, `none`, `false`, or options passed to `inner-label` -> boolean | none | dictionary
  dedans:true,
  /// `true`, `none`, `false`, or options passed to `outer-label` -> boolean | none | dictionary
  dehors:true,
  /// Other arguments to give to the piechart function of cetz -> arguments
  ..args
) = {}

/// Draws a true histogram: class widths do not have to be equal,
/// and rectangle areas are proportional to the counts/frequencies. -> content
#let histogramme(
  /// Class boundaries: length = `effectifs.len() + 1` -> array
  classes:(),
  /// Counts of each class: length = `classes.len() - 1` -> array
  effectifs:(),
  /// Tick interval on the x-axis -> int
  px:1,
  /// Quantity represented by one grid square -> int
  uaire:1,
  /// Scale passed to cetz -> int | float | dictionary
  s:1,
  /// Whether to display a grid -> boolean
  grille:true,
  /// Grid spacing -> int | float
  pas-grille:1,
  /// Label for the legend or y-axis, if applicable -> content
  nom-donnee:[Values],
  /// Label for the x-axis -> content
  nom-effectifs:[Frequencies],
  /// Extra margin on the left, right, and bottom.
  /// Either a single integer or a triple -> int | array
  add:(-1, 1, 1),
  /// Whether to display a y-axis when all classes have the same width -> boolean
  lecture:true,
  /// Whether to display frequencies above the rectangles -> boolean
  donnees-sup:true,
  /// Rectangle colors, or a single color (e.g. `white` for printing) -> auto | color | array
  liste-couleurs:auto,
  /// Position of the legend rectangle relative to the upper-left corner
  /// of the smallest rectangle -> array
  pos-rect:(0, 2),
  /// If `true`, replaces colors with tiling patterns -> boolean
  print:false,
  /// Rectangle transparency. Use `100%` if `ListeCouleurs: white` -> ratio
  transparence:30%,
  /// Displays cumulative frequencies -> boolean
  ecc:false,
  /// Displays the median -> boolean
  mediane:false,
  /// Displays the quartiles -> boolean
  quartiles:false,
  /// Number of decimal places for rounded values -> int
  decimales:2,
  /// Position of the Q1 label relative to the x-axis -> array
  posq1:(0,-1.5),
  /// Position of the median label relative to the x-axis -> array
  posmediane:(0,-1.5),
  /// Position of the Q3 label relative to the x-axis -> array
  posq3:(1,-1.5),
  /// Stroke used to draw the median -> length | stroke
  stroke-mediane:2pt,
  /// Stroke used to draw the quartiles -> length | stroke
  stroke-quartiles:1.5pt,
  /// Text size -> length
  textsize:1em,
) = {}

/// Computes descriptive statistics and returns them as a dictionary:
/// `effectif-total`, `mediane`, `classe-mediane`, `q1`, `q3`, `d1`, `d9`,
/// `ecart-interquartiles`, `max`, `min`, `etendue`, `modes`,
/// `effectif-modes`, `sommex`, `sommex2`, `moyenne`, `variance`,
/// `ecart-type`, `variance-echantillon`, `ecart-type-echantillon`,
/// `lqboxplot`, and `cetzboxplot`. -> dictionary
#let caracteristiques(
  /// Values of the numeric variable -> array
  valeurs:(),
  /// Counts of each value -> array
  effectifs:(),
  /// Class boundaries, if applicable:
  /// length = `effectifs.len() + 1` -> array
  classes:(),
  /// For raw data in `sondage`, automatically creates `bins`
  /// classes of equal width -> int
  bins:0,
  /// List of all observations -> array
  sondage:(),
  /// For class intervals, use interval notation (`[a; b[`)
  /// instead of inequalities (`a <= ... < b`) -> boolean
  crochets:false,
  /// If `true`, whiskers are based on deciles;
  /// otherwise they extend to ±1.5 × IQR -> boolean
  deciles:true,
) = {}

/// Performs a statistical analysis and displays the results as a table,
/// with optional frequencies (`effectifs`), relative frequencies
/// (`"f"` for fractions, `"d"` for decimals, `"t"` for all, `true` for
/// percentages), sector angles for (semi-)pie charts, cumulative
/// frequencies (`ECC`, `FCC`), class intervals (automatically generated
/// when `bins > 0`) and their centers.
///
/// It can also display charts:
/// `"hbar"`, `"bar"`, `"circ"`, `"semicirc"`, `"box"`, `"bande"`,
/// `"histo"`, or any combination of these.
///
/// If `multi != ()`, grouped bar charts (horizontal or vertical) or
/// multiple box plots can be displayed. Setting `print: true` replaces
/// colors with tiling patterns. -> content
#let stat(
  /// Values or categories of the variable -> array
  valeurs:(),
  /// Counts of each value -> array
  effectifs:(),
  /// Whether the variable is qualitative -> boolean
  qualitatif:true,
  /// Display totals in tables -> boolean
  totaux:false,
  /// Display the table -> boolean
  tableau:true,
  /// Background color of the first row and first column -> color
  couleur-tableau:luma(85%),
  /// Cell inset -> length
  inset:5pt,
  /// Label for the upper-left table cell
  /// (and some charts) -> content
  nom-donnee:[],
  /// Label for the frequency row
  /// (and some charts) -> content
  nom-effectifs:[Frequencies],
  /// Number of decimal places for rounded values -> int
  decimales:0,
  /// Relative frequencies:
  /// `true` for percentages,
  /// `"f"` for fractions,
  /// `"d"` for decimals,
  /// `"t"` for all,
  /// `"v"` for an empty row -> boolean | str
  frequences:true,
  /// List of all observations -> array
  sondage:(),
  /// If `true`, all rows except the first are left blank -> boolean
  vide:false,
  /// Display sector angles (`"v"` for an empty row) -> boolean | str
  angle:false,
  /// Display cumulative frequencies (`"v"` for an empty row) -> boolean | str
  ecc:false,
  /// Class boundaries for continuous data:
  /// length = `effectifs.len() + 1` -> array
  classes:(),
  /// For raw data, automatically creates `bins`
  /// classes of equal width -> int
  bins:0,
  /// Use interval notation (`[a; b[`) instead of
  /// inequalities (`a <= ... < b`) -> boolean
  crochets:false,
  /// Display class centers (`"v"` for an empty row) -> boolean | str
  centre:true,
  /// Columns to leave empty -> array
  colonnes-vide:(),
  /// Individual cells to leave empty,
  /// numbered row by row -> array
  cases-vide:(),
  /// Chart type:
  /// `"hbar"`, `"bar"`, `"circ"`, `"semicirc"`,
  /// `"box"`, `"bande"`, `"histo"`,
  /// or any combination -> str
  diagramme:"",
  /// Parameters passed to the horizontal/vertical bar chart canvas -> array
  bar:(),
  /// Parameters passed to cetz's `barchart` or `columnchart` -> array
  cbar:(),
  /// Parameters passed to the custom box-plot function -> array
  moustaches:(),
  /// Parameters passed to cetz's `boxwhiskers` -> array
  cmoustaches:(),
  /// Parameters passed to `camembert` -> dictionary
  circ:(:),
  /// Parameters passed to `bandes` -> array
  bande:(),
  /// Parameters passed to `histogramme` -> array
  histo:(),
  /// Display cumulative relative frequencies
  /// (`"v"` for an empty row) -> boolean | str
  fcc:false,
  /// Multiple series for grouped bar charts
  /// or multiple box plots -> array
  multi:(),
  /// Labels for the different series -> array
  labels:(),
  /// If `true`, replaces colors with tiling patterns -> boolean
  print:false,
  /// Colors used in the charts -> auto | color | array
  liste-couleurs:auto,
) = {}

/// Draws a *proportionality table* by generating named Fletcher nodes
/// from an equation. By default, all nodes in the same column have the same
/// width, and all nodes in the same row have the same height. In addition,
/// all nodes are placed directly next to each other. Works like `diagram`
/// in math mode. -> content
#let math-grid(
  /// Mathematical equation to be converted into a table -> math.equation
  eq,
  /// equation-mode to get the alternatingly right- and left-aligned columns, no stroke and no empty nodes -> boolean
  equation:false,
  /// Whether cells in a column should have the same width -> boolean
  equal-columns: true,
  /// Whether cells in a row should have the same width -> boolean
  equal-rows: true,
  /// Table line properties -> none | length | color | stroke
  node-stroke: 1pt,
  /// Node shape -> function
  node-shape: rect,
  /// Node inset (h,v) in points -> array
  inset: (0, -2),
  /// Spacing between table cells -> length
  spacing: 0cm,
  /// Scale of arrow marks -> int | float
  mark-scale: 1.2,
  /// Whether to make the table vertical -> boolean
  flip: false,
  /// Proportionality coefficient (from the 1st row to the 2nd) -> none | content
  coef: none,
  /// Reciprocal coefficient (from the 2nd row to the 1st) -> none | content
  coef-recip: none,
  /// Optional arguments passed to the `edge` function for the coefficient -> dictionary
  coef-args: (),
  /// Optional arguments passed to the `edge` function for the reciprocal coefficient -> dictionary
  coef-recip-args: (),
  /// to have the empty nodes drawn -> boolean
  no-empty-node:true,
  /// minimal width (useful for empty columns) -> length
  min-width:0pt,
  /// minimal height (useful for empty rows) -> length
  min-height:0pt,
  /// Optional arguments passed to the Fletcher `diagram` function -> arguments
  ..args,
) = {}

/// Function showing that one column is the sum (default) or difference of two
/// other columns, above the first row. Three modes are available. -> content
#let lin-up(
  /// Index of the first starting column -> int
  a,
  /// Index of the second starting column -> int
  b,
  /// Index of the destination column -> int
  c,
  /// Operation sign -> content | str
  sign:$ + $,
  /// Arrow color -> auto | color
  color:auto,
  /// Text color -> auto | color
  text-color:auto,
  /// Three modes are available -> int
  mode:1,
  /// Additional arguments for the edges -> dictionary
  ..args,
) = {}

/// Function showing that one column is the sum (default) or difference of two
/// other columns, below the second row. Three modes are available -> content
#let lin-down(
  /// Index of the first starting column -> int
  a,
  /// Index of the second starting column -> int
  b,
  /// Index of the destination column -> int
  c,
  /// Operation sign -> content | str
  sign:$ + $,
  /// Arrow color -> auto | color
  color:auto,
  /// Text color -> auto | color
  text-color:auto,
  /// Three modes are available -> int
  mode:1,
  /// number of rows -> int
  n:2,
  /// Additional arguments for the edges -> dictionary
  ..args,
) = {}

/// Function to display the cross-multiplication arrows between two columns. -> content
#let x-product(
  /// Arrow color -> color
  color:luma(40%),
  /// Distance from the centers of the nodes -> float
  sep:.2,
  /// Offset of the left endpoints of the arrows, if needed -> float
  left-shift:0,
  /// Offset of the right endpoints of the arrows, if needed -> float
  right-shift:0,
  /// For use with vertical tables -> boolean
  flip:false,
  /// Arguments necessarily containing the index of the first column
  /// and optionally that of a second column (otherwise +1), as well as
  /// arguments passed to the Fletcher `edge` function -> int | arguments
  ..a,
) = {}

/// Draws a direct operation arrow from one column to another, above or below the table. -> content
#let col-op(
  /// Index of the starting row (or column if flip:true) -> int
  row,
  /// Index of the starting column (or row if flip:true) -> int
  f,
  /// Index of the destination column (or row if flip:true) -> int
  t,
  /// Text/operation (e.g. `$+ 12$` or `$+ "col 2"$`) -> content | str
  label,
  /// Position: `"top"` (above) or `"bottom"` (below), default: auto -> auto | str
  pos: auto,
  /// Arc curvature -> auto | angle
  bend: auto,
  /// For use with vertical tables -> boolean
  flip:false,
  /// Arguments passed to the Fletcher `edge` function -> arguments | dictionary
  ..args,
) = {}

/// Double arrow showing the combination (addition/subtraction) of two columns
/// into a third. -> content
#let col-combine(
  /// Index of the row (or column if flip:true) -> int
  row,
  /// Index of the 1st starting column -> int
  col1,
  /// Index of the 2nd starting column -> int
  col2,
  /// Index of the destination column -> int
  to,
  /// Text/operation (e.g. `$+ 12$` or `$+ "col 2"$`) -> content | str
  label: $+$,
  /// Position: `"top"` (above) or `"bottom"` (below), default: auto -> auto | str
  pos: auto,
  /// Arc curvature -> auto | angle
  bend: auto,
  /// For use with vertical tables -> boolean
  flip:false,
  /// Arguments passed to the Fletcher `edge` function -> arguments | dictionary
  ..args,
) = {}


/// Right-side arrow going downward with a label -> content
#let rdarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Right-side arrow going upward with a label -> content
#let ruarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved up -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Left-side arrow going downward with a label -> content
#let ldarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Left-side arrow going upward with a label -> content
#let luarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved up -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Top-side (up) arrow going to the right with a label -> content
#let urarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Top-side (up) arrow going to the left with a label -> content
#let ularrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Bottom-side (down) arrow going to the right with a label -> content
#let drarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}

/// Bottom-side (down) arrow going to the left with a label -> content
#let dlarrow(
  /// arrow label -> math.content
  label,
  /// number of rows moved down -> int
  n:1,
  /// arguments passed to Fletcher's edge function -> arguments | dictionary
  ..a
) = {}