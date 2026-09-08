// #import "/moustaches.typ": *

/// Writes the quotient `a / b`, where `a` and `b` are floating-point numbers
/// (or simply `a` if `b = 1`), together with its reduced fractional form
/// (up to 6 decimal places).
/// ```example
/// #simpli(3.6,6.9)
/// ```
/// -> content
#let simpli(
  /// int | float
  a,
  /// int | float
  b,
) = {}

/// Computes the greatest common divisor (GCD) of a list of numbers.
/// ```example
/// #pgcd(1000, 1200, 1400, 1600, 1800, 2000)
/// ```
/// -> int
#let pgcd(
  /// List of numbers -> array
  ..a
) = {}

/// `bandes(values:(), frequencies:(), width:1fr, rotate:(), colors:auto, print:false, explanation:(), height:40pt)`

/// Draws a band chart.
/// ```example
/// >>> #set text(.7em)
/// #bandes(
///   valeurs:("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"),
///   effectifs:(25, 18, 17, 10, 5, 20),
///   width:9cm,
///   tourne:(4,),
///   explication:(0,),
/// )
/// ```
/// -> content
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

/// Draws a (semi-)pie chart.
/// ```example
/// #camembert(
///   valeurs:("foot","basket","tennis","ping-pong","hand","natation","danse"),
///   effectifs:(1, 3, 5, 4, 7, 2, 5),
///   radius:1.5,
///   legende:"d",
///   espace:0,
///   semi:true,
/// )
/// ```
/// -> content
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
  ..args
) = {}

/// Draws a true histogram: class widths do not have to be equal,
/// and rectangle areas are proportional to the counts/frequencies.
///
/// #example(`#histogramme(
///   classes: (1000, 1200, 1400, 1600, 1800, 2000),
///   effectifs: (120, 150, 220, 360, 200),
///   px: 50,
///   uaire: 10,
///   s: .5,
///   // textsize: .5em,
///   nom-donnee: [Salaire (en €)],
///   nom-effectifs: [Salariés],
///   mediane: true,
///   quartiles: true,
///   pos-rect: (0,5),
/// )`,dir:ttb)
///
/// -> content
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
/// `lqboxplot`, and `cetzboxplot`.
/// ```example
/// #caracteristiques(sondage:(1, 5, 7, 9, 4, 5, 9, 8, 7, 3, 8))
/// ```
/// -> dictionary
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
/// colors with tiling patterns.
/// ```example
/// #stat(
///   classes:(150, 160, 170, 200),
///   effectifs:(3, 4, 5),
///   frequences:"f",
/// )
/// ```
/// ```example
/// #stat(
///   sondage:("Handball","Basket","Football","Handball",
///            "Ping-pong","Basket","Ping-pong","Ping-pong"),
///   diagramme:"bar",
///   cbar:(size:(8.2,4))
/// )
/// ```
/// ```example
/// #stat(
///   valeurs:("Grippe","Angine","Allergies"),
///   multi:((25,12,10),(10,10,17),(2,8,28)),
///   diagramme:"bar",
///   labels:("Mars","Avril","Mai"),
///   tableau:false
/// )
/// ```
/// -> content
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
