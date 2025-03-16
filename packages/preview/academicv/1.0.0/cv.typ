#import "utils.typ": convert_string_to_length, convert_string_to_color

#import "layouts/header.typ": layout_header
#import "layouts/numbered_list.typ": layout_numbered_list
#import "layouts/prose.typ": layout_prose
#import "layouts/timeline.typ": layout_timeline

// set rules
#let setrules(settings, doc) = {
    set text(
        font: settings.font_body,
        size: settings.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: settings.spacing_line
    )

    set par(
        leading: settings.spacing_line,
        justify: true,
    )

    show link: it => {
        text(
            fill: settings.color_hyperlink,
        )[#it]
    }

    doc
}

// show rules
#let showrules(settings, doc) = {
    // Uppercase section headings
    show heading.where(
        level: 2,
    ): it => block(width: 100%)[
        #v(settings.spacing_section)
        #set align(left)
        #set text(font: settings.font_heading, size: 1em, weight: "semibold")
        #if (settings.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            it.body
        }
        #v(-0.75em) #line(length: 100%, stroke: 1pt + black) // draw a line
    ]

    // Name title/heading
    show heading.where(
        level: 1,
    ): it => block(width: 100%)[
        #set text(font: settings.font_heading, size: 1.1em, weight: "semibold")
        #if (settings.at("headingsmallcaps", default:false)) {
            smallcaps(it.body)
        } else {
            it.body
        }
        #v(2pt)
    ]

    doc
}

// Set page layout
#let cvinit(doc) = {
    doc = setrules(doc)
    doc = showrules(doc)

    doc
}

// Main section rendering function
#let cvsection(info, layout: none, section: none, title: none, settings: none, isbreakable: true) = {
    // Use the provided section, or default to the layout name if no section is specified
    let section_key = section
    
    // Set default title based on layout type if not provided
    let section_title = title

    // Only render the section if it exists in the info data (skip title check for header)
    if ((section_key in info) and (info.at(section_key) != none)) or layout == "header" {
        // For header layout, don't add a section title
        if layout == "header" {
            layout_header(info.personal, isbreakable: isbreakable)
        } else {
            block[
                == #section_title
                
                // Use the appropriate layout function based on layout
                #if layout == "prose" {
                    layout_prose(info.at(section_key), isbreakable: isbreakable)
                } else if layout == "timeline" {
                    // Get the primary, secondary, tertiary elements from the section if they exist
                    let primary = if "primary_element" in info { info.primary_element } else { "none" }
                    let secondary = if "secondary_element" in info { info.secondary_element } else { "none" }
                    let tertiary = if "tertiary_element" in info { info.tertiary_element } else { "none" }
                    
                    layout_timeline(info.at(section_key), 
                                   primary_element: primary, 
                                   secondary_element: secondary, 
                                   tertiary_element: tertiary, 
                                   settings: settings,
                                   isbreakable: isbreakable)
                } else if layout == "numbered_list" {
                    layout_numbered_list(info.at(section_key), isbreakable: isbreakable)
                } else {
                    [No layout function defined for "#layout"]
                }
            ]
        }
    } else {
        none
    }
}

// Function to create data for a section that uses the new structure
#let get_section_data(section, cv_data) = {
  // Create a dictionary that will hold all relevant section data
  let result = (:)
  
  // First check if this section has entries in it
  if "entries" in section {
    // Add entries to result
    result.insert("entries", section.entries)
  } else {
    // If the section doesn't have entries, use the existing top-level data
    if section.key in cv_data {
      result.insert("entries", cv_data.at(section.key))
    } else {
      // Set empty array if data is not found
      result.insert("entries", [])
    }
  }
  
  // Add layout configuration if present
  if "primary_element" in section {
    result.insert("primary_element", section.primary_element)
  }
  if "secondary_element" in section {
    result.insert("secondary_element", section.secondary_element)
  }
  if "tertiary_element" in section {
    result.insert("tertiary_element", section.tertiary_element)
  }
  
  return result
}