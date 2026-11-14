// Tests the public Typst API, including scalar conversions, direct math results, and matrix helpers.

#import "../lib.typ": all, any, comp, map, reduce
#import "utils.typ": assert-typst-eq, assert-eq

#assert-typst-eq("comp real scalar returns float", type(comp($2 + 3$)), float)
#assert-typst-eq("comp 1x1 real matrix returns float", type(comp($mat(7)$)), float)
#assert-typst-eq("comp 1x1 real matrix unwraps to scalar", comp($mat(7)$), 7.0)
#assert-typst-eq("comp 1x1 complex matrix returns content", type(comp($mat(7i)$)), content)

#assert-typst-eq("comp direct integer returns float", comp(7), 7.0)
#assert-typst-eq("comp direct float returns float", comp(2.5), 2.5)
#assert-typst-eq("comp direct string parses radix integer", comp("0xFF"), 255.0)
#assert-typst-eq("comp direct decimal returns float", comp(decimal("2.5")), 2.5)
#assert-typst-eq("comp direct 1x1 matrix returns float", comp(math.mat(..((7,),))), 7.0)
#let matrix-result = comp(math.mat(..((1, 2), (3, 4))))
#assert-typst-eq("comp returns matrix content directly", matrix-result.func(), math.mat)

#let vector-result = comp(math.vec($1$, $2$, $3$))
#assert-typst-eq("comp returns vector content directly", vector-result.func(), math.vec)
#assert-typst-eq(
  "comp evaluates a transposed column-vector dot product",
  comp($vec(1, 2, 3)^T dot vec(4, 5, 6)$),
  32.0,
)

#assert-eq(
  "map passes numeric cells to callback as floats",
  map(
    (value, x, y) => if type(value) == float { $1$ } else { $2$ },
    $mat(1, 2)$,
  ),
  $mat(1, 1)$,
)

#assert-eq(
  "map callback receives x and y coordinates",
  map((value, x, y) => $ #value + #x + #y $, $mat(1, 2; 3, 4)$),
  $mat(1, 3; 4, 6)$,
)

#let highlighted = map(
  (value, x, y) => highlight(str(value), fill: yellow),
  $mat(1, 2)$,
)
#assert-typst-eq("map preserves highlighted content", "highlight" in repr(highlighted), true)

#assert-typst-eq("any finds matching cell", any(value => comp(value) > 3, $mat(1, 2; 3, 4)$), true)
#assert-typst-eq("any rejects no matches", any(value => comp(value) > 9, $mat(1, 2; 3, 4)$), false)
#assert-typst-eq("all accepts every matching cell", all(value => comp(value) > 0, $mat(1, 2; 3, 4)$), true)
#assert-typst-eq("all rejects a failing cell", all(value => comp(value) > 1, $mat(1, 2; 3, 4)$), false)

#let stencil-field = $mat(
  10, 12, 15, 14, 11;
  13, 20, 25, 22, 15;
  14, 24, 35, 28, 16;
  12, 19, 27, 23, 14;
  9, 11, 16, 15, 10
)$
#let stencil-north = comp($#stencil-field [0:3, 1:4]$)
#let stencil-south = comp($#stencil-field [2:5, 1:4]$)
#let stencil-west = comp($#stencil-field [1:4, 0:3]$)
#let stencil-east = comp($#stencil-field [1:4, 2:5]$)
#let stencil-center = comp($#stencil-field [1:4, 1:4]$)
#let stencil-laplacian = comp($4 * (
  #stencil-north + #stencil-south + #stencil-west + #stencil-east
  - 4 * #stencil-center
)$)
#assert-eq(
  "comp combines separately evaluated matrix slices element-wise",
  stencil-laplacian,
  $mat(-24, -32, -24; -32, -144, -64; -8, -60, -32)$,
)


// Full worked examples shown in the repository README.
#let transform-matrix = $mat(0, -1, 5; 1, 0, -2; 0, 0, 1)$
#let transform-point = $vec(3, 2, 1)$
#let transformed-point = comp($#transform-matrix dot #transform-point$)
#assert-eq(
  "homogeneous matrix transform rotates and translates a point",
  transformed-point,
  $mat(3; 1; 1)$,
)
#assert-eq("homogeneous transform x slice", comp($#transformed-point [0, 0]$), 3.0)
#assert-eq("homogeneous transform y slice", comp($#transformed-point [1, 0]$), 1.0)

#let sensor-raw = $mat(1.02, 1.05, 0.98; 0.99, 1.01, 1.04; 1.03, 0.97, 1.00)$
#let sensor-calibrated = map(
  (reading, x, y) => calc.round((reading - 1) * 100 - (x - y) * 0.5, digits: 1),
  sensor-raw,
)
#assert-eq(
  "coordinate-aware sensor calibration",
  sensor-calibrated,
  $mat(2, 4.5, -3; -0.5, 1, 3.5; 4, -2.5, 0)$,
)
#let sensor-total = reduce((sum, value) => sum + comp(value), 0, sensor-calibrated)
#assert-eq("reduce computes calibrated sensor mean", sensor-total / 9, 1.0)
#assert-typst-eq(
  "any detects a calibrated outlier",
  any(value => comp(value) > 4 or comp(value) < -4, sensor-calibrated),
  true,
)
#assert-typst-eq(
  "all validates calibrated sensor range",
  all(value => comp(value) >= -5 and comp(value) <= 5, sensor-calibrated),
  true,
)

#let ac-voltage = $120 + 0i$
#let ac-impedance = $30 + 40i$
#let ac-current = comp($#ac-voltage / #ac-impedance$)
#assert-eq("complex impedance determines AC current", ac-current, $1.44 - 1.92i$)
#let ac-power = comp($#ac-voltage * #ac-current^*$)
#assert-eq("conjugate current produces complex power", ac-power, $172.8 + 230.4i$)
#assert-eq("real part is active power", comp($Re(#ac-power)$), 172.8)
#assert-eq("imaginary part is reactive power", comp($Im(#ac-power)$), 230.4)
#assert-eq("complex magnitude is apparent power", comp($abs(#ac-power)$), 288.0)
