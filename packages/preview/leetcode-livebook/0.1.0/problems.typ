// problems.typ - Problem metadata access and available problems list

// Helper to format problem ID (e.g., 1 -> "0001")
#let format-id(id) = {
  let id-str = str(id)
  while id-str.len() < 4 {
    id-str = "0" + id-str
  }
  id-str
}

// Get problem metadata from problem.toml
#let get-problem-info(id) = {
  let id-str = format-id(id)
  let path = "problems/" + id-str + "/problem.toml"
  toml(path)
}

// Get test cases for a problem
#let get-test-cases(id) = {
  let id-str = format-id(id)
  let path = "problems/" + id-str + "/testcases.typ"
  import path: cases
  cases
}

// Return problem directory path (for advanced users)
#let get-problem-path(id) = {
  let id-str = format-id(id)
  "problems/" + id-str + "/"
}

// All available problem IDs in the repository
#let available-problems = (
  ..range(1, 27), // 1-26
  33,
  35,
  39,
  42,
  46,
  ..range(48, 52), // 48-51
  ..range(53, 57), // 53-56
  62,
  69,
  70,
  72,
  76,
  78,
  94,
  101,
  104,
  110,
  ..range(112, 114), // 112-113
  116,
  121,
  144,
  145,
  155,
  200,
  ..range(206, 208), // 206-207
  218,
  ..range(209, 211), // 209-210
  289,
  347,
  407,
  547,
  785,
  814,
  997,
)
