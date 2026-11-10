#let mandoc = plugin("typst-mandoc.wasm")

#let render-manpage(text, paper: "A4", os: "Typst", lineheight: 1.4, parspacing: 1) = {
  let options = float(lineheight).to-bytes() + float(parspacing).to-bytes()
  let result = mandoc.renderManpage(bytes(text), bytes(paper), bytes(os), options)
  let pdf = result.slice(0, result.len() - 4)
  let pages = int.from-bytes(result.slice(result.len() - 4))
  (pdf, pages)
}
