#import "cube.typ": cube

/// 3x3x3 cube with only the first 2 layers colored.
/// The upper layer is in gray color.
/// -> cube
#let f2l-cube = cube(
  stickers: (
    f: 3 * (gray,) + 6 * (red,),
    r: 3 * (gray,) + 6 * (green,),
    u: 9 * (gray,),
    b: 3 * (gray,) + 6 * (orange,),
    l: 3 * (gray,) + 6 * (blue,),
    d: 9 * (white,),
  ),
)

/// 3x3x3 cube with only the upper face colored.
/// The rest of the cube is in gray color.
/// -> cube
#let oll-cube = cube(
  stickers: (
    f: 9 * (gray,),
    r: 9 * (gray,),
    u: 9 * (yellow,),
    b: 9 * (gray,),
    l: 9 * (gray,),
    d: 9 * (gray,),
  ),
)

/// 3x3x3 solved cube.
/// -> cube
#let solved-cube = cube(
  colors: (
    f: red,
    r: green,
    u: yellow,
    b: orange,
    l: blue,
    d: white,
  ),
)
