#let layout-prose(data, isbreakable: true) = {
  // Set left margin to match the numbered list for consistency
  let left_margin = 2em
  
  block(width: 100%, breakable: isbreakable)[
    // Check if data is an array (direct list of citations/text items)
    #if type(data) == array {
      for (index, item) in data.enumerate() {
        // Create a grid with a single column but padded to match numbered list
        grid(
          columns: (1fr),
          
          // Item text with markup, padded from the left to align with numbered list
          pad(left: left_margin)[
            #eval(item, mode: "markup")
          ]
        )
        
        // Add space between entries
        if index < data.len() - 1 {
          v(0.05em)
        }
      }
    } else if type(data) == str {
      // If it's a single string, just display it with the same padding
      pad(left: left_margin)[
        #eval(data, mode: "markup")
      ]
    } else {
      [No entries found]
    }
  ]
}