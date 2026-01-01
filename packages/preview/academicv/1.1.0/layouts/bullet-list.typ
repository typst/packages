#let layout-bullet-list(data, isbreakable: true) = {
  // Set width for the bullet column
  let bullet-width = 2em
  
  block(width: 100%, breakable: isbreakable)[
    // Check if data is an array
    #if type(data) == array {
      for (index, item) in data.enumerate() {
        // Create a grid with two columns
        grid(
          columns: (bullet-width, 1fr),
          gutter: 1em,

          // Bullet point in the first column
          align(right)[•],
          
          // List item text with markup in the second column
          [#eval(item, mode: "markup")]
        )
        
        // Add spacing between entries
        if index < data.len() - 1 {
          v(0.05em)
        }
      }
    } else {
      [No items found]
    }
  ]
}