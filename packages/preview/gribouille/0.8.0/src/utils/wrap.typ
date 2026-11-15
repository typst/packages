// Greedy word wrap shared by `format-wrap` and `label-wrap`.
//
// Lengths count grapheme clusters, so an accented letter takes one place. A
// word longer than `width` splits at the limit, so no line is wider than
// `width`.

#let soft-wrap(text, width) = {
  if text.clusters().len() <= width { return text }
  let lines = ()
  let line = ""
  let used = 0
  for word in text.split(" ").filter(w => w != "") {
    let letters = word.clusters()
    let pieces = range(0, letters.len(), step: width).map(i => {
      letters.slice(i, calc.min(i + width, letters.len())).join()
    })
    for piece in pieces {
      let size = piece.clusters().len()
      if line == "" {
        line = piece
        used = size
      } else if used + 1 + size <= width {
        line = line + " " + piece
        used = used + 1 + size
      } else {
        lines.push(line)
        line = piece
        used = size
      }
    }
  }
  if line != "" { lines.push(line) }
  lines.join("\n")
}
