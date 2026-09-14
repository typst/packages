#import "../../helpers.typ": *

#let solution(strs) = {
  let groups = (:)

  for s in strs {
    // Sort characters to get canonical key
    let chars = s.codepoints().sorted()
    let key = if chars.len() == 0 { "" } else { chars.join() }

    if key in groups {
      groups.at(key).push(s)
    } else {
      groups.insert(key, (s,))
    }
  }

  groups.values()
}
