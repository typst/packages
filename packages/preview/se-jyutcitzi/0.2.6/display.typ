#import "utils.typ": split-jyutping
#import "data.typ": *

/// Combine 2 parts: combine mode
/// - "-" for stacking part 1 on top of part 2;
/// - "|" for combining them side-by-side
#let combine-parts(part1, part2, combine-mode, tone: none) = {
  let combined
  let tone-mapped = if tone != none { tone-map.at(tone) } else { none }
  if combine-mode == "-" {
    combined = rotate(
      90deg,
      scale(
        [#box(rotate(-90deg, part1))#box(rotate(-90deg, part2))],
        origin: bottom+left,
        x: 50%,
        reflow: true
      )
    )
  } else {
    combined = scale([#part1#part2], origin: bottom+left, x: 50%, reflow: true)
  }
  box(baseline: 0.12em, stack(combined, tone-mapped, dir: ltr))
}

/// Transform jyutping (without digit) to jyutcitzi
#let simple-jyutcitzi-display(jp-initial, jp-final, tone: none) = {
  if jp-initial != none or jp-final != none {
    set text(bottom-edge: "descender", top-edge: "ascender")
    let part1
    let part2
    let combine-mode
    if jp-initial == none and (jp-final == "m" or jp-final == "ng") {
      let tone-mapped = if tone != none { tone-map.at(tone) } else { none }
      box(baseline: 0.12em, stack(finals-dict.at(jp-final), tone-mapped, dir: ltr))
    } else {
      if jp-initial == none {
        part1 = initials-dict.a.at(0)
        part2 = finals-dict.at(jp-final)
        combine-mode = "-"
      } else if jp-final == none {
        part1 = initials-dict.a.at(0)
        part2 = initials-dict.at(jp-initial).at(0)
        combine-mode = "-"
      } else {
        part1 = initials-dict.at(jp-initial).at(0)
        part2 = finals-dict.at(jp-final)
        combine-mode = initials-dict.at(jp-initial).at(1)
      }
      combine-parts(part1, part2, combine-mode, tone: tone)
    }
  }
}

#let combine-3parts(part1, part2, part3, combine-mode, tone: none) = {
  set text(bottom-edge: "descender", top-edge: "ascender")
  let combined
  let tone-mapped = if tone != none { tone-map.at(tone) } else { none }
  let part12
  let combined
  // ┫ = Top, Bottom, Right
  if combine-mode == "tbr" {
    part12 = box(
      rotate(
        90deg,
        scale(
          [#box(rotate(-90deg, part1))#box(rotate(-90deg, part2))],
          origin: bottom+left,
          x: 50%,
          reflow: true
        )
      ),
      baseline: 0.12em
    )
    combined = scale(box[#part12#part3], x: 50%, reflow: true, origin: bottom + left)
  } else { // ┻ = Left, Right, Bottom
    part12 = scale([#part1#part2], origin: bottom+left, x: 50%, reflow: true)
    combined = rotate(
      90deg,
      scale(
        [#box(rotate(-90deg, part12))#box(rotate(-90deg, part3))],
        origin: bottom+left,
        x: 50%,
        reflow: true
      )
    )
  }
  box(baseline: 0.12em, stack(combined, tone-mapped, dir: ltr))
}
