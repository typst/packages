#set text(lang: "en")
#import "/Operations.typ"

/// conversion to decimal from another base (defaut : 2). -> str | int | float
#let from-base(
  /// number to convert -> int | float | str
  val, 
  /// origin base -> int
  base: 2,
  /// mode fr to get "," instead of "." as a decimal separator -> boolean
  fr:false,
  /// show the base of the result -> boolean
  show-base: false,
) = {}

/// conversion from decimal to another base (defaut : 2). -> str | int | float
#let to-base(
  /// number to convert -> int | float | str
  val, 
  /// base to convert to -> int
  base: 2,
  /// mode fr to get "," instead of "." as a decimal separator -> boolean
  fr:false,
  /// show the base of the result -> boolean
  show-base: false,
  /// to limit the number of digits if the fractional part is infinite -> int
  precision: 6,
) = {}

/// conversion from a base (defaut : 2) to another (defaut : 10). -> str | int | float
#let base-to-base(
  /// number to convert -> int | float | str
  val,
  /// original base -> int
  base-from: 2,
  /// end base -> int
  base-to: 10,
  /// to get explanation of the conversion -> boolean
  explain: false,
  /// to get the conversion equality -> boolean
  equal: false,
  /// to limit the number of digits if the fractional part is infinite -> int
  precision: 6,
  /// mode fr to get "," instead of "." -> boolean
  fr: false,
  /// a few modes to show the bases "paren", "line", "simple" -> str
  mode:"paren",
) = {}
  
/// Lay out the column addition of 2 or more numbers with the possibility of hiding the result with `hide-result`, or a `list` of some of the digits and then to show the `solution`, a few colors can be set. -> content
#let addition(
  /// Base (from 2 to 36) -> int
  base: 10,
  /// to show the base of the numbers -> boolean
  show-base:false,
  /// show or hide the carries -> boolean
  show-carry: true, 
  /// color of the carries -> color
  carries-color:red,
  /// Size of the columns  -> length | relative length
  size:1em,
  /// french decimal separaro "," or not -> boolean
  fr: true,
  /// Hide the carry row and the result -> boolean
  hide-result:false,
  /// Color of the mask of hidden digits -> color
  border-color:blue.mix(gray),
  /// Color of the hidden digits if solution = true -> color
  solution-color:red,
  /// How the digits are hidden : "rect" for a round rectangle or "" for dots -> str
  type-mask:"rect",
  /// list of the digits to hide -> array
  list:(),
  /// show the carries and the hidden digits -> boolean
  solution:false,
  /// Sign of equality, false or a symbol \$ = \$ -> boolean | content
  sign:false,
  /// Space if more than one calculation on a line, default : 1fr -> length | fraction | relative length
  space:1fr,
  /// size of the text : 1em -> length | relative length
  text-size:1em,
  /// Numbers to add -> array | arguments
  ..args
) = {}

/// Lay out the subtraction of 2 or more numbers with the possibility of hiding the result row with `hide-result`, hiding a `list` of selected digits, then displaying the `solution`, with various configurable colors. -> content
#let soustraction(
  /// Base (from 2 to 36) -> int
  base: 10,
  /// to show the base of the numbers -> boolean
  show-base:false,
  /// Show or hide the borrows -> boolean
  show-borrow: true,
  /// If fr:false, show or hide the crossed-out original digit -> boolean
  canceled:false,
  /// French notation or English borrowing method -> boolean
  fr:true,
  /// Color of the borrows -> color
  carries-color:red,
  /// Column width  -> length | relative length
  size:1em,
  /// Add trailing zeros when needed -> boolean
  zeros:true,
  /// Hide the borrows and the result -> boolean
  hide-result:false,
  /// Color of the border around hidden digits -> color
  border-color:blue.mix(gray),
  /// Color of hidden digits when solution = true -> color
  solution-color:red,
  /// How hidden digits are displayed: "rect" for a rounded rectangle or ... -> str
  type-mask:"rect",
  /// List of digits to hide in a fill-in-the-blank subtraction -> array
  list:(),
  /// Show the borrows and the result in hide-result mode (for answer keys) -> boolean
  solution:false,
  /// Equality sign, false or a symbol \$ = \$ -> boolean | content
  sign:false,
  /// Text size: 1em  -> length | relative length
  text-size:1em,
  /// Spacing when several calculations are on the same line  -> length | relative length | fraction
  space:1fr,
  /// Numbers -> array | arguments
  ..args
) = {}

/// Lay out the multiplication of 2 integer or decimal numbers with the possibility of hiding intermediate rows using `hide-result`, hiding a `list` of selected digits, then displaying the `solution`, with various configurable colors. -> content
#let multiplication(
  /// first factor -> int | float | str
  a, 
  /// second factor -> int | float | str
  b,
  /// Base (2 à 36) -> int
  base: 10,
  /// to show in which base the numbers and operation are -> boolean
  show-base:false,
  /// to show the carries : false, true ("all"), "mult", "add" -> boolean | str
  carries: false,
  /// Color of the carries -> color | array
  carries-color: red,
  /// Display mode for shifted rows: "g" (default) for gray zeros, "0" for normal zeros, "p" for small dots, "gp" for larger dots, "" or anything else for nothing -> str
  mode: "g",
  /// Show the addition "+" signs and the final "=" if true; only "+" if "+", only "=" if "=", otherwise nothing -> boolean | str
  sym: true,
  /// If fr:true, the decimal separator is "," otherwise "." -> boolean | str
  fr: true,
  /// Column width  -> length | relative length
  size: 1em,
  /// Hide intermediate rows and the final result for exercises -> boolean
  hide-result: false,
  /// List of cell indices to hide (fill-in-the-blank multiplication) -> array
  list: (),
  /// Show or hide the solution inside the masks -> boolean
  solution: false,
  /// Mask type ("rect" or "line") -> str
  type-mask: "rect",
  /// Color of the mask border -> color
  border-color: blue.mix(gray),
  /// Color of the solution text -> color
  solution-color: red,
  /// Spacing when several calculations are on the same line  -> length | relative length | fraction
  space: 1fr,
) = {}

/// Write the equality corresponding to a Euclidean division. -> content
#let egalite-euclidienne(
  /// dividend -> int | float
  a,
  /// divisor -> int | float
  b
) = {}

/// Write the equality corresponding to a decimal division. -> content
#let egalite-decimale(
  /// dividend -> int | float
  a,
  /// divisor -> int | float
  b,
  /// sign:"e" for =, else approx -> str
  s:"e"
) = {}

/// Divide decimal number `a` by `b`.
///
/// With `extradigits`, computes additional digits after the decimal point beyond those already present in `a` (when `cycle:false`). These extra digits are displayed in gray (`mode:"g"` by default), white (`mode:"0"`), as dots (`mode:"p"` or `"gp"`), or omitted (`mode:""`). Use `s:true/false` to show or hide the subtraction steps.
/// You can highlight the repeating cycle in the quotient using `cycle:true` (underlined with `cycle-color`), display it in parentheses with `cycle:""`, or display it in color with `cycle:red`.
/// Fill-in-the-blank divisions are also supported with `hide-result`, `list`, and `solution` (using the `type-mask`, `border-color`, and `solution-color` parameters). -> content
#let division(
  /// dividend -> int | float
  a,
  /// divisor -> int | float
  b,
  /// Base (2 to 36) -> int
  base: 10,
  /// to show in which base the numbers and operation are -> boolean
  show-base:false,
  /// Display mode for zeros added to the dividend: "g" (gray), "0" (black), "p" (small dot), "gp" (large dot), "" (empty) -> str
  mode: "g",
  /// Number of additional quotient digits to compute -> int
  extradigits: 0,
  /// Show or hide the subtraction steps -> boolean
  s: true,
  /// Detect and display the repeating cycle automatically -> boolean | str | color
  cycle: false,
  /// Color of the cycle or underline -> color
  cycle-color: luma(50%),
  /// If fr:true, the decimal separator is "," otherwise "." -> boolean
  fr:true,
  /// Column width -> length
  size: .7em,
  /// dx for the ) in mode fr:false -> length | relative length
  dx:.6em,
  /// dy for the ) in mode fr:false -> length | relative length
  dy:-.82em,
  /// Hide the working steps and quotient (exercise mode) -> boolean
  hide-result: false,
  /// List of cell indices to hide (dividend, divisor, steps, quotient) -> array
  list: (),
  /// Show or hide the solution inside the masks -> boolean
  solution: false,
  /// Mask type ("rect" or "line") -> str
  type-mask: "rect",
  /// Color of the mask border -> color
  border-color: blue.mix(gray),
  /// Color of the solution text -> color
  solution-color: red,
  /// Spacing when several calculations are on the same line  -> length | relative length | fraction
  space:1fr,
) = {}

/// Compute the square root of `a`, with `extradigits` additional decimal places, optionally showing digit pairs using `groups` in `groups-color`, displaying the construction step by step with `step`, hiding subtraction steps with `s`, and hiding the result or a `list` of digits. -> content
#let racine(
  /// number -> int | float
  a,
  /// Number of additional "00" digit pairs to compute after the decimal point -> int
  extradigits: 0,
  /// Show brackets above each pair of digits -> boolean
  groups: false,
  /// Color of the brackets -> color
  groups-color: blue.darken(20%),
  /// Step to display in the step-by-step construction -> none | int
  step: none,
  /// Color of the step indicator -> color
  step-color: blue.darken(20%),
  /// Show or hide the subtraction steps below the dividend -> boolean
  s: true,
  /// If fr:true, the decimal separator is "," otherwise "." -> boolean
  fr:true,
  /// Column width  -> length | relative length
  size: 0.65em,
  /// Hide the construction steps, operations, and result (exercise mode) -> boolean
  hide-result: false,
  /// List of cell indices to hide (fill-in-the-blank exercise) -> array
  list: (),
  /// Show or hide the solution inside the masks -> boolean
  solution: false,
  /// Mask type ("rect" or "line") -> str
  type: "rect",
  /// Color of the mask border -> color
  border-color: blue.mix(gray),
  /// Color of the solution text -> color
  solution-color: red,
  /// Right spacing  -> length | relative length | fraction
  space: 1fr,
  /// Other arguments to the square root, ex:[...] -> arguments
  ..args
) = {}

/// Compute the sum of all the supplied numbers inline. -> content
#let add-en-ligne(
  /// list of numbers -> arguments
  ..ops
) = {}

/// Compute the difference of all the supplied numbers inline. -> content
#let sous-en-ligne(
  /// list of numbers -> arguments
  ..ops,
  /// -> auto | int
  digits:auto
) = {}

/// Show the step-by-step evaluation of `expr-str` (unless `todo:true`), with the option to perform independent operations of the same precedence simultaneously using `concomitant`, display the work vertically or horizontally, highlight the current step (`highlight`), and use fraction mode to keep computations exact by forcing calculations to continue with fractions. -> content
#let etapes-calcul(
  /// expression to calculate -> str
  expr-str,
  /// "fr" or "en" mode for the decimal separator -> str
  mode: "fr",
  /// Set to true to perform independent operations of the same precedence simultaneously -> boolean
  concomitant: false,
  /// Display the calculation vertically -> boolean
  vertical: false,
  /// Number of decimal places for calculations involving π, etc. -> int
  digits: 2,
  /// Number of steps (counted from the end) at which "=" is replaced by "≈" when appropriate -> int
  n: 0,
  /// Label to prepend to the expression -> str | content
  name: "",
  /// Exercise mode: only the initial expression followed by "=" is displayed -> boolean
  todo: false,
  /// Horizontal spacing between two `etapes-calcul` outputs  -> length | relative length | fraction
  space: 1fr,
  /// In fraction mode, computations remain exact, either as fractions or simplified forms such as 5π -> boolean
  fraction: false,
  /// Either a color used to highlight the current operation, `false` for bold, or `none` for no highlighting -> color | boolean | none
  highlight: rgb("#1e88e5"),
  /// List of steps to skip if needed -> array
  skip: ()
) = {}

/// Function for writing calculation steps manually. -> content
#let detail(
  /// The detailed calculation expression -> str
  expr-str,
  /// Vertical layout -> boolean
  vertical:false,
  /// Append a rounded value at the end -> boolean
  add-rounded:false,
  /// Number of decimal places for the rounded value -> int
  digits:2,
  /// Step from which "=" is replaced by "≈" when appropriate -> int
  appro:0,
  /// If `todo:true`, only the initial expression is displayed -> boolean
  todo:false,
  /// Spacing before the next calculation  -> length | relative length | fraction
  space:1fr,
  /// `a`: aqua; can be changed from Typst's default color if needed -> color
  a: aqua,
  /// `b`: blue; can be changed from Typst's default color if needed -> color
  b: blue,
  /// `f`: fuchsia; can be changed from Typst's default color if needed -> color
  f: fuchsia,
  /// `g`: green; can be changed from Typst's default color if needed -> color
  g: green,
  /// `r`: red; can be changed from Typst's default color if needed -> color
  r: red,
  /// `l`: gray; can be changed from Typst's default color if needed -> color
  l: gray,
  /// `m`: maroon; can be changed from Typst's default color if needed -> color
  m: maroon,
  /// `n`: rgb(8,111,189) (navy); can be changed if needed -> color
  n: rgb("#086fbd"),
  /// `o`: orange; can be changed from Typst's default color if needed -> color
  o: orange,
  /// `t`: rgb(0,128,128) (teal); can be changed if needed -> color
  t: rgb(0,128,128),
  /// `p`: purple; can be changed from Typst's default color if needed -> color
  p: purple,
  /// `y`: yellow; can be changed from Typst's default color if needed -> color
  y: yellow,
  /// Display mode: "cancel", "circle", or "color" -> str
  c: "color",
) = {}

/// Converts decimal or fractional durations into integer durations -> array
#let prepa-duree(
  /// List of 2 to 4 numbers (d, h, min, s) to (min, s) -> array | arguments
  ..args
) = {}

/// Sets up the addition of two or more durations.
///
/// You need to change units: ([j], [h], [min], [s]) with units: ([d], [h], [min], [s]).
///
/// Each duration is an array in one of the following forms:
/// - `(days, hours, minutes, seconds)`.
/// - `(hours, minutes, seconds)`.
/// - `(minutes, seconds)`. -> content
#let addition-durees(
  /// Show carries. -> boolean
  show-carry: true,
  /// Color of the carries. -> color
  carries-color: red,
  /// Size of the carries and the + and = symbols, max. 1em.  -> length | relative length
  carry-size:.8em,
  /// Width of the columns corresponding to the units.  -> length | relative length
  size: 2.5em,
  /// Convert the result instead of displaying carries. -> boolean
  convertion: false,
  /// Hide columns containing only zeros. -> boolean
  hide-empty:true,
  /// Hide the result. -> boolean
  hide-result: false,
  /// Border color of hidden values. -> color
  border-color: blue.mix(gray),
  /// Color of values in the solution. -> color
  solution-color: red,
  /// Mask type: "rect" or "line". -> str
  type-mask: "rect",
  /// Indices of the cells to hide. -> array
  list: (),
  /// Show the solution for hidden cells. -> boolean
  solution: false,
  /// Sign placed before the result. -> boolean | content
  sign: false,
  /// Text size.  -> length | relative length
  text-size: 1em,
  /// Show unit names. -> boolean
  show-units: true,
  /// Names of the four units. -> array
  units: ([d], [h], [min], [s]),
  /// Unit size, max. 1em.  -> length | relative length
  units-size:.75em,
  /// Color of the units. -> color
  units-color:gray,
  /// Display hours, minutes, and seconds using two digits. -> boolean
  zero-pad: true,
  /// Align the digits of the units. -> boolean
  align: true,
  /// Vertical dotted lines to separate the columns. -> boolean
  verticals: false,
  /// List of durations -> array | arguments
  ..args
) = {}

/// Sets up the subtraction of two durations. 
/// 
/// You need to change units: ([j], [h], [min], [s]) with units: ([d], [h], [min], [s]).
///
/// Each duration is an array in one of the following forms:
/// - `(days, hours, minutes, seconds)`;
/// - `(hours, minutes, seconds)`;
/// - `(minutes, seconds)`.
///
/// The first duration must be greater than or equal to the second. -> content
#let soustraction-durees(
  /// Show borrows and carries. -> boolean
  show-borrow: true,
  /// Color of the borrows and carries. -> color
  carries-color: red,
  /// Size of the carries and the + and = symbols, max. 1em.  -> length | relative length
  carry-size:.7em,
  /// Width of the columns. -> length | relative length
  size: 2.5em,
  /// Convert the minuend instead of displaying carries. -> boolean
  convertion: false,
  /// Hide columns containing only zeros. -> boolean
  hide-empty:true,
  /// Hide the result. -> boolean
  hide-result: false,
  /// Border color of hidden values. -> color
  border-color: blue.mix(gray),
  /// Color of values in the solution. -> color
  solution-color: red,
  /// Mask type: "rect" or "line". -> str
  type-mask: "rect",
  /// Indices of the cells to hide. -> array
  list: (),
  /// Show the solution. -> boolean
  solution: false,
  /// Sign placed before the result. -> boolean | content
  sign: false,
  /// Text size.  -> length | relative length
  text-size: 1em,
  /// Show unit names. -> boolean
  show-units: true,
  /// Names of the four units. -> array
  units: ([d], [h], [min], [s]),
  /// Unit size, max. 1em.  -> length | relative length
  units-size:.75em,
  /// Color of the units. -> color
  units-color:gray,
  /// Display hours, minutes, and seconds using two digits. -> boolean
  zero-pad: true,
  /// Align the digits of the units. -> boolean
  align:true,
  /// Vertical dotted lines to separate the columns. -> boolean
  verticals: false,
  /// List of durations -> array | arguments
  ..args
) = {}