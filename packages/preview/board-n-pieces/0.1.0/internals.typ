#import "abi.typ"

#let functions = plugin("plugin.wasm")

#let parse-fen = abi.function(
  (..args) => functions.parse_fen(..args),
  bytes,
  abi.position-from-bytes,
)

/// Returns the index of a file.
#let file-index(file) = file.to-unicode() - "a".to-unicode()

/// Returns the index of a rank.
#let rank-index(r) = int(r) - 1

/// Returns the coordinate of a square given a square name.
#let square-coordinates(s) = {
  let (f, r) = s.clusters()
  (file-index(f), rank-index(r))
}
