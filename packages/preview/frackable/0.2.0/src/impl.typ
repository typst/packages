/// Create vulgar fractions using unicode
/// #example(```typ
/// #frackable(1, 2)
/// #frackable(1, 3)
/// #frackable(9, 16)
/// #frackable(31, 32)
/// #frackable(0, "000")
/// #frackable(whole: 9, 3, 4)
/// ```, scale-preview: 200%)
/// 
/// - numerator (integer, string): The top part of the fraction.
/// - denominator (integer, string): The bottom part of the fraction.
/// - whole (integer, string): Optional whole number to precede the vulgar
///     fraction, making mixed fraction.
/// -> content
#let frackable(
  numerator,
  denominator,
  whole: none
) = {
  show: box
  if whole != none {str(whole) + "\u{2064}"}
  set text(fractions: true)
  str(numerator) + "\u{2044}" + str(denominator)
}

/// Returns a function having the same signature as `frackable`, to be used
/// for typesetting vulgar fractions within fonts that do not support the
/// `frac` feature. Default values are chosen for `Linux Libertine` font.
/// Can be used to display arbitrary strings as a vulgar fraction, rather than
/// just integers or interger-like strings.
/// #example(```typ
/// #set text(font: "Calibri")
/// #let my-frackable = generator(
///   shift-numerator-x: -0.1em,
///   shift-denominator-x: -0.1em,
/// )
/// 
/// #my-frackable(1, 2)
/// #my-frackable(1, 3)
/// #my-frackable(3, 4, whole: 9)
/// #my-frackable(0, "000")
/// 
/// ```)
/// 
/// - font-size (length): Font size with which to display numerator and denominator. Best practice is to use `em` units.
/// - shift-numerator-y (length): Amount of vertical shift to apply to numerator. Best practice is to use `em` units.
/// - shift-numerator-x (length): Amount of horiztonal space *between slash and numerator*. Best practice is to use `em` units.
/// - shift-denominator-y (length): Amount of vertical shift to apply to denominator. Best practice is to use `em` units.
/// - shift-denominator-x (length): Amount of horiztonal space *between slash and denominator*. Best practice is to use `em` units.
#let generator(
  font-size: 0.55em,
  shift-numerator-x: -0em,
  shift-numerator-y: -0.6em,
  shift-denominator-x: 0em,
  shift-denominator-y: 0.05em,
) = (numerator, denominator, whole: none) => {
  show: box
  if whole != none {str(whole) + "\u{2064}"}
  text(
    str(numerator),
    size: font-size, baseline: shift-numerator-y,
  )
  h(shift-numerator-x)
  "\u{2044}"
  h(shift-denominator-x)
  text(
    str(denominator),
    size: font-size, baseline: shift-denominator-y
  )
}