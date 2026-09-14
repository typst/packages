#import "utils.typ": split-jyutping
#import "data.typ": *

/// Combine 2 parts: combine mode
/// - "-" for stacking part 1 on top of part 2;
/// - "|" for combining them side-by-side
#let combine-parts = (part1, part2, combine-mode) => {
  let combined
  if combine-mode == "-" {
    combined = scale(
      stack(part1, part2, spacing: 10%),
      origin: bottom+left, y: 50%, reflow: true
    )
  } else {
    combined = scale([#part1#part2], origin: bottom+left, x: 50%, reflow: true)
  }
  box(combined)
}

/// Transform jyutping (without digit) to jyutcitzi
#let simple-jyutcitzi-display = jyutping => {
  let (beginning, ending) = split-jyutping(jyutping)
  if beginning != "" or ending != "" {
    let part1
    let part2
    let combine-mode
    if beginning == "" {
      part1 = beginnings-dict.a.at(0)
      part2 = endings-dict.at(ending)
      combine-mode = "-"
    } else if ending == "" {
      part1 = beginnings-dict.a.at(0)
      part2 = beginnings-dict.at(beginning).at(0)
      combine-mode = "-"
    } else {
      part1 = beginnings-dict.at(beginning).at(0)
      part2 = endings-dict.at(ending).at(0)
      combine-mode = beginnings-dict.at(beginning).at(1)
    }
    combine-parts(part1, part2, combine-mode)
  }
}
