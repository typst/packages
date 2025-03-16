#import "@preview/academicv:1.0.0": *

// Import your CV data
#let cv_data = yaml("template.yml")

// Validate that required fields exist in each section
#for section in cv_data.sections {
  if "key" not in section {
    panic("Missing 'key' in section: " + str(section))
  }
  if "layout" not in section {
    panic("Missing 'layout' in section with key: " + section.key)
  }
  if "title" not in section and section.key != "personal" {
    warn("Missing 'title' in section with key: " + section.key)
  }
}

// Get settings from YAML file
#let settings = cv_data.settings

// Define default settings if not present in YAML
#let default_settings = (
  font_heading: "Libertinus Serif",
  font_body: "Libertinus Serif",
  fontsize: 10pt,         // Must be a string with unit
  spacing_section: 12pt,  // Space between sections. Must be a string with unit
  spacing_entry: 0.1em,   // Space between entries within a section. Must be a string with unit
  spacing_element: 3pt,   // Space between elements within an entry. Must be a string with unit
  spacing_line: 5pt,      // Space between lines within an element. Must be a string with unit
  color_hyperlink: rgb(0, 0, 255),   // Can be either a colour string or a rgb() value
)

// Merge with defaults for any missing settings
#let settings = if settings != none {
  // First add any missing settings from defaults
  for (k, v) in default_settings {
    if k not in settings {
      settings.insert(k, v)
    }
  }
  
  // Convert length strings to actual length values
  let settings_length = ("fontsize", "spacing_line", "spacing_section", "spacing_entry", "spacing_element")

  // Page settings separately
  for setting in settings_length {
    settings.at(setting) = convert_string_to_length(settings.at(setting))
  }
  if "page" in settings and "margin" in settings.page {
    settings.page.margin = convert_string_to_length(settings.page.margin)
  }

  // Convert color strings to actual colors
  let settings_color = ("color_hyperlink",)
  for setting in settings_color {
    settings.at(setting) = convert_string_to_color(settings.at(setting))
  }
  
  settings
} else {
  default_settings
}

#let customrules(doc) = {
    // Get page settings from YAML if available
    set page(                 // https://typst.app/docs/reference/layout/page
        paper: if "page" in settings and "paper" in settings.page { 
          settings.page.paper 
        } else { 
          "a4" 
        },
        numbering: if "page" in settings and "numbering" in settings.page { 
          settings.page.numbering 
        } else { 
          "1 / 1" 
        },
        number-align: if "page" in settings and "number-align" in settings.page { 
          // Convert string align values to actual Typst align values
          let align = settings.page.number-align
          if align == "center" { center } 
          else if align == "left" { left } 
          else if align == "right" { right }
          else { center }  // Default
        } else { 
          center 
        },
        margin: if "page" in settings and "margin" in settings.page { 
          settings.page.margin 
        } else { 
          3.5cm 
        },
    )
    
    // Set hyperlink styling
    show link: it => {
        text(
            fill: if "color_hyperlink" in settings { 
              settings.color_hyperlink 
            } else { 
              rgb(0, 0, 255) // Default blue
            },
        )[#it]
    }
    
    // set list(indent: 1em)
    doc
}

#let cvinit(doc) = {
    doc = setrules(settings, doc)
    doc = showrules(settings, doc)
    doc = customrules(doc)
    doc
}

#show: doc => cvinit(doc)

// Process CV sections dynamically based on the YAML configuration
#if "sections" in cv_data {
  for section in cv_data.sections {
    if section.at("show", default: true) == true {
      if section.key == "personal" {
        // Special case for personal/heading section
        layout_header(cv_data, settings)
      } else {
        // Standard sections
        let layout = section.layout
        let key = section.key
        let title = section.title
        
        // Get the data for this section
        let section_data = get_section_data(section, cv_data)
        
        // Create a temporary dictionary with just this section's data
        let temp_data = (
          personal: cv_data.personal,  // Keep personal for reference
          (key): section_data.entries,  // Add this section's entries
        )
        
        // Add layout configuration if present
        if "primary_element" in section_data {
          temp_data.insert("primary_element", section_data.primary_element)
        }
        if "secondary_element" in section_data {
          temp_data.insert("secondary_element", section_data.secondary_element)
        }
        if "tertiary_element" in section_data {
          temp_data.insert("tertiary_element", section_data.tertiary_element)
        }
        
        // Call cvsection with the appropriate data
        cvsection(temp_data, layout: layout, section: key, settings: settings, title: title)
      }
    }
  }
}