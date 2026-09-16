// ============================================================================
// figchild — a faithful Typst port of the LaTeX package `figchild` v3.1.2
// (Figures for Creating Children's Activities, Fernando de Souza Bastos, UFV)
//
//   #import "@preview/figchild:0.1.0": *
//
//   #canvas(fc-owl-a())                         // exact CeTZ rendering
//   #canvas(fc-dino(scale: 0.5, rotate: 10deg)) // TikZ-like options
//   #scrawl(fc-pumpkin(), seed: 3)              // hand-drawn Scrawl style
//
// Module style also works:
//   #import "@preview/figchild:0.1.0"
//   #figchild.canvas(figchild.fc-owl-a())
//
// Combining figures inside one canvas:
//   #cetz.canvas({
//     figchild.render(fc-bee()) + figchild.render(fc-flower-a(shift: (3, 0)))
//   })
//
// All 561 figures are available as `fc-…` functions (1:1 with the `\fc…`
// macros of the original package: \fcOwlA → fc-owl-a, \fcIceCreamA →
// fc-ice-cream-a, ...). The full index is in `figures.typ` (`all-figures`).
// ============================================================================

#import "figchild.typ" as _impl
#import "figures.typ": *

// -- metadata ---------------------------------------------------------------
/// Version of the original LaTeX package this port reproduces.
#let package-version = "0.1.0"

/// Version of the original LaTeX figchild package.
#let figchild-version = _impl.figchild-version

/// Release date of the original LaTeX figchild package.
#let figchild-date = _impl.figchild-date

// -- engine API -------------------------------------------------------------
/// Builds a figure from data (used by the generated `fc-…` functions).
#let figure = _impl.figure

/// Renders a figure as a list of CeTZ elements (use inside `cetz.canvas`).
#let render = _impl.render

/// Renders a figure inside a full CeTZ canvas.
/// - padding (length): extra space around the drawing (stroke allowance)
#let canvas = _impl.canvas

/// Renders a figure with Scrawl's hand-drawn style.
/// - margin (number): white space around the figure, in centimetres
/// - seed (int): randomness seed for the wobble
/// - roughness (number): how wobbly the strokes are
/// - hand (bool): `false` gives clean strokes
#let scrawl = _impl.scrawl

// -- helpers ----------------------------------------------------------------
/// Returns the list of all figure names (original LaTeX macro names, in the
/// order of the original .sty file), e.g. "fcOwlA", "fcIceCreamA", ...
#let figure-names = all-figures.map(f => f().name)
