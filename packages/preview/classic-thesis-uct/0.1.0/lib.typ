// Public entry point for the `classic-thesis-uct` package.
//
// Re-exports every symbol from the layout module so downstream documents only
// need a single `#import "@preview/classic-thesis-uct:0.1.0": *` to access the
// configure template, chapter helpers, figure / table / equation blocks, and
// design-token constants. Keeping the public surface in this thin wrapper lets
// us reorganise `classicthesis-uct.typ` internally without affecting users.
#import "classicthesis-uct.typ": *
