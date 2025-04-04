#let layout-timeline(data, primary-element: none, secondary-element: none, tertiary-element: none, settings: none, isbreakable: true) = {
  // Get the global settings
  let year-column-width = 7em
  
  // Get spacing settings with defaults
  let spacing-entry = settings.at("spacing-entry", default: 0.5em)
  let spacing-element = -1em + settings.at("spacing-element", default: 2pt) // Space between primary/secondary/tertiary
  
  // Convert single elements to arrays for consistent handling
  let primary = if type(primary-element) == array { primary-element } else { (primary-element,) }
  let secondary = if type(secondary-element) == array { secondary-element } else { (secondary-element,) }
  let tertiary = if type(tertiary-element) == array { tertiary-element } else { (tertiary-element,) }
  
  // List of mentor types for special handling
  let mentor-types = (
    (key: "advisors", singular: "Advisor", plural: "Advisors"),
    (key: "professors", singular: "Professor", plural: "Professors"),
    (key: "supervisors", singular: "Supervisor", plural: "Supervisors")
  )
  
 // Helper function to check if a field is a mentor type
  let is-mentor-type(field) = {
    for type in mentor-types {
      if field == type.key {
        return true
      }
    }
    return false
  }
  
  // Helper function to format mentor lists
  let format-mentors(entry, key) = {
    let mentor-type = mentor-types.find(t => t.key == key)
    if mentor-type == none { return none }
    
    let mentors = entry.at(key, default: none)
    if mentors == none or mentors.len() == 0 { return none }
    
    // Create the label part in italic
    let label = if mentors.len() == 1 { mentor-type.singular + ":" } else { mentor-type.plural + ":" }
    
    // Format the mentor names
    let names = if mentors.len() == 1 {
      mentors.at(0)
    } else if mentors.len() == 2 {
      [#mentors.at(0) and #mentors.at(1)]
    } else {
      let result = []
      for (i, mentor) in mentors.enumerate() {
        if i == mentors.len() - 1 {
          result = result + [and #mentor]
        } else if i == mentors.len() - 2 {
          result = result + [#mentor ]
        } else {
          result = result + [#mentor, ]
        }
      }
      result
    }
    
    // Combine the label and names
    [#text(style: "italic")[#label] #names]
  }
  
  // Create the container block
  block(width: 100%, breakable: isbreakable, inset: 0pt, outset: 0pt)[
    // Process each entry
    #for (i, entry) in data.enumerate() {
      // Format year text
      let year-text = if "end-date" in entry and entry.end-date != none {
        if "start-date" in entry and entry.start-date != none {
          if entry.end-date == "present" or entry.end-date == "Present" {
            [#entry.start-date - Present]
          } else if entry.start-date == entry.end-date {
            [#entry.start-date]
          } else {
            [#entry.start-date - #entry.end-date]
          }
        } else {
          [#entry.end-date]
        }
      } else if "start-date" in entry and entry.start-date != none {
        [#entry.start-date]
      } else {
        []
      }
      
      // Create grid for this entry
      grid(
        columns: (year-column-width, 1fr),
        gutter: 1em,
        
        // Year column
        align(right)[#year-text],
        
        grid.vline(),
        
        // Entry details with configurable spacing
        pad(left: 0.5em)[
          // PRIMARY ELEMENTS SECTION
          
          // First primary element (bold)
          #let first-primary-found = false
          #let first-primary-field = none
          #let first-primary-content = none
          
          // Find the first available primary element
          #for field in primary {
            if field in entry and entry.at(field) != none and not first-primary-found {
              first-primary-field = field
              first-primary-content = entry.at(field)
              first-primary-found = true
              break
            }
          }
          
          // Display first primary element in bold if found
          #if first-primary-found {
            text(weight: "bold")[#first-primary-content]
            
            // Handle location specially for institution
            if first-primary-field == "institution" and "location" in entry and entry.location != none {
              [, #entry.location]
            }
            
            // Check for other primary elements to display in normal weight
            let additional-primary = ()
            for field in primary {
              if field != first-primary-field and field in entry and entry.at(field) != none {
                additional-primary.push(entry.at(field))
              }
            }
            
            // Add additional primary elements if any
            if additional-primary.len() > 0 {
              [, #additional-primary.join(", ")]
            }
          }
          
          // SECONDARY ELEMENTS SECTION
          
          // Collect all secondary elements
          #let secondary-content = ()
          
          // Regular secondary elements
          #for field in secondary {
            if not is-mentor-type(field) and field in entry and entry.at(field) != none {
              secondary-content.push(entry.at(field))
            }
          }
          
          // Add mentor fields from secondary
          #for field in secondary {
            if is-mentor-type(field) {
              let mentor-text = format-mentors(entry, field)
              if mentor-text != none {
                secondary-content.push(mentor-text)
              }
            }
          }
          
          // Add mentor types not explicitly in secondary
          #for type in mentor-types {
            if type.key not in secondary and type.key in entry and entry.at(type.key) != none {
              let mentor-text = format-mentors(entry, type.key)
              if mentor-text != none {
                secondary-content.push(mentor-text)
              }
            }
          }
          
          // Display secondary content if exists
          #if secondary-content.len() > 0 and first-primary-found {
            v(spacing-element) // Add spacing between primary and secondary
            
            // We need to handle secondary content differently
            // For regular secondary elements (not advisor/professor), use italic
            // For advisor/professor elements, they are already formatted correctly
            let regular-secondary = ()
            let special-secondary = ()
            
            for item in secondary-content {
              if type(item) == str {
                regular-secondary.push(item)
              } else {
                special-secondary.push(item)
              }
            }
            
            // Display regular secondary elements in italic if any exist
            if regular-secondary.len() > 0 {
              text(style: "italic")[#regular-secondary.join(", ")]
            }
            
            // Display special secondary elements (already formatted) if any exist
            if special-secondary.len() > 0 {
              if regular-secondary.len() > 0 { [, ] }
              special-secondary.join(", ")
            }
          }
          
          // TERTIARY ELEMENTS SECTION
          
          // Collect tertiary elements
          #let tertiary-content = ()
          #for field in tertiary {
            if field in entry and entry.at(field) != none {
              tertiary-content.push(entry.at(field))
            }
          }
          
          // Display tertiary content if exists
          #if tertiary-content.len() > 0 {
            if first-primary-found or secondary-content.len() > 0 {
              v(spacing-element) // Add spacing before tertiary
            }
            
            text(size: 8pt)[
              #tertiary-content.join(", ")
            ]
          }
        ]
      )
      
      // Add configurable space between entries
      if i < data.len() - 1 {
        v(spacing-entry)
      }
    }
  ]
}