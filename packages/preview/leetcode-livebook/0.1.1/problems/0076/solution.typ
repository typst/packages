#import "../../helpers.typ": *

#let solution(s, t) = {
  if s.len() == 0 or t.len() == 0 or s.len() < t.len() {
    return ""
  }

  // Build frequency map for t
  let need = (:)
  for c in t {
    let key = str(c)
    need.insert(key, need.at(key, default: 0) + 1)
  }

  let window = (:)
  let have = 0 // Number of characters with satisfied count
  let required = need.len() // Number of unique characters needed

  let result = (-1, -1) // (start, end) of minimum window
  let min-len = s.len() + 1

  let left = 0
  for right in range(s.len()) {
    // Add character from the right
    let c = str(s.at(right))
    window.insert(c, window.at(c, default: 0) + 1)

    // Check if this character's count is now satisfied
    if c in need and window.at(c) == need.at(c) {
      have += 1
    }

    // Contract window from left while valid
    while have == required {
      // Update result if this window is smaller
      if right - left + 1 < min-len {
        min-len = right - left + 1
        result = (left, right)
      }

      // Remove character from the left
      let lc = str(s.at(left))
      window.insert(lc, window.at(lc) - 1)

      // Check if we lost a satisfied character
      if lc in need and window.at(lc) < need.at(lc) {
        have -= 1
      }

      left += 1
    }
  }

  if result.at(0) == -1 {
    ""
  } else {
    s.slice(result.at(0), result.at(1) + 1)
  }
}
