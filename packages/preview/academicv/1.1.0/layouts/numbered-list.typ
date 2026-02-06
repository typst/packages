#let layout-numbered-list(data, isbreakable: true) = {
  // Set width for the number column
  let number_width = 2em
  
  block(width: 100%, breakable: isbreakable)[
    // Check if data is an array (direct list of citations)
    #if type(data) == array {
      for (index, citation) in data.enumerate() {
        // Create a grid with two columns
        grid(
          columns: (number_width, 1fr),
          gutter: 1em,
          
          // Right-aligned number in the first column
          align(right)[#(index + 1).],
          
          // Citation text with markup in the second column
          [#eval(citation, mode: "markup")]
        )
        
        // Add space between entries
        if index < data.len() - 1 {
          v(0.05em)
        }
      }
    } else {
      [No entries found]
    }
  ]
}