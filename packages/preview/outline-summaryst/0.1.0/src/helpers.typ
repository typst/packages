#let calc-elem-size(elem, sizes: (12pt, 10pt, 8pt, 6pt,4pt)) = {
  let size = 3pt
  if elem.level - 2 < sizes.len() {
    size = sizes.at(elem.level - 2)
  }
  return size
}




