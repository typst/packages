// Custom validator for Group Anagrams
// Both outer and inner arrays are unordered

#let validator(input, expected, yours) = {
  if type(expected) != array or type(yours) != array {
    return expected == yours
  }
  if expected.len() != yours.len() {
    return false
  }

  // Sort each inner group, then sort the outer array
  let normalize(arr) = {
    arr
      .map(group => {
        if type(group) == array {
          group.sorted()
        } else {
          group
        }
      })
      .sorted()
  }

  normalize(expected) == normalize(yours)
}
