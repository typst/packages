/// Provides typographically correct TeX-family logos for Typst. Based on the
/// LaTeX metalogo package by Andrew Gilbert Moschou.
///
/// # Example
/// ```typ
/// #import "@preview/swank-tex:<version>": *
/// The #TeX typesetting system, along with #LaTeX and #XeTeX.
/// ```

#let (TeX, LaTeX, LaTeX2E, XeTeX, XeLaTeX, LuaTeX, LuaLaTeX, pdfTeX) = {
  // kerning values between pairs
  let kern = (
    "Te":   h(-0.165em), // Knuth says: -0.1667em
    "eX":   h(-0.122em), // Knuth says: -0.125em
    "La":   h(-0.361em),
    "aT":   h(-0.147em),
    "X2":   h( 0.150em),
    "twoE": h( 0.133em),
    "Xe":   h(-0.122em), // mirrors "eX"
    "eT":   h(-0.165em), // mirrors "Te"
    "eL":   h(-0.124em),
    "LuaT": h( 0.005em), // questionable, but matches metalogo output
    "LuaL": h( 0.005em), // questionable, but matches metalogo output
  )

  // vertical translation for certain characters
  let drop = (
    "E":  0.220em,
    "A": -0.178em,
    "e": -0.104em,
  )

  // resize certain characters
  let sized = (
    "A": text(size: 0.7em, "A"),
    "e": text(size: 1.66em, sym.epsilon),
  )

  // helper functions
  let ncm(content) =  text(font: "New Computer Modern", content)

  // components (used in logos below)
  let E    = box(move(dy: drop.E, "E"))
  let A    = box(move(dy: drop.A, sized.A))
  let e    = box(move(dy: drop.e, rotate(12deg, sized.e)))
  let Erev = box(scale(x: -100%, E))
  let Xe   = box[X#kern.Xe#Erev]

  // logos which are also components
  let TeX = ncm(box[T#kern.Te#E#kern.eX#[X]])
  let LaTeX = ncm(box[L#kern.La#A#kern.aT#TeX])

  // return logos
  (
    TeX,
    LaTeX,
    ncm(box[#LaTeX#kern.X2#[2]#sub[#kern.twoE#e]]), // LaTeX2E
    ncm(box[#Xe#kern.eT#TeX]),                      // XeTeX
    ncm(box[#Xe#kern.eL#LaTeX]),                    // XeLaTeX
    ncm(box[Lua#kern.LuaT#TeX]),                    // LuaTeX
    ncm(box[Lua#kern.LuaL#LaTeX]),                  // LuaLaTeX
    ncm(box[pdf#TeX]),                              // pdfTeX
  )
}
