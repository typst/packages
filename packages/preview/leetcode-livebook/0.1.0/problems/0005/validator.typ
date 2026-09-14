// Validator for Problem 0005 - Longest Palindromic Substring
// Multiple correct answers are possible (e.g., "bab" or "aba" for "babad")

// Check if a string is a palindrome
#let is-palindrome(s) = {
  let chars = s.clusters()
  let n = chars.len()
  for i in range(calc.floor(n / 2)) {
    if chars.at(i) != chars.at(n - 1 - i) {
      return false
    }
  }
  true
}

// Validator: checks if yours is a valid longest palindromic substring
// - yours must be a substring of s
// - yours must be a palindrome
// - yours must have the same length as the expected answer
#let validator(input, expected, yours) = {
  let s = input.s

  // 1. Check if yours is a substring of s
  if not s.contains(yours) {
    return false
  }

  // 2. Check if yours is a palindrome
  if not is-palindrome(yours) {
    return false
  }

  // 3. Check if yours has the same length as expected (i.e., is longest)
  yours.len() == expected.len()
}
