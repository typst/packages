#import "utils.typ": convert-string-to-length, convert-string-to-color

#import "layouts/header.typ": layout-header
#import "layouts/bullet-list.typ": layout-bullet-list
#import "layouts/numbered-list.typ": layout-numbered-list
#import "layouts/prose.typ": layout-prose
#import "layouts/timeline.typ": layout-timeline

// set rules
#let setrules(settings, doc) = {
    set text(
        font: settings.font-body,
        size: settings.fontsize,
        hyphenate: false,
    )

    set list(
        spacing: settings.spacing-line
    )

    set par(
        leading: settings.spacing-line,
        justify: true,
    )

    show link: it => {
        text(
            fill: settings.color-hyperlink,
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
        #v(settings.spacing-section)
        #set align(left)
        #set text(font: settings.font-heading, size: 1em, weight: "semibold")
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
        #set text(font: settings.font-heading, size: 1.1em, weight: "semibold")
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
    let section-key = section
    
    // Set default title based on layout type if not provided
    let section-title = title

    // Only render the section if it exists in the info data (skip title check for header)
    if ((section-key in info) and (info.at(section-key) != none)) or layout == "header" {
        // For header layout, don't add a section title
        if layout == "header" {
            layout-header(info.personal, isbreakable: isbreakable)
        } else {
            block[
                == #section-title
                
                // Use the appropriate layout function based on layout
                #if layout == "prose" {
                    layout-prose(info.at(section-key), isbreakable: isbreakable)
                } else if layout == "timeline" {
                    // Get the primary, secondary, tertiary elements from the section if they exist
                    let primary = if "primary-element" in info { info.primary-element } else { "none" }
                    let secondary = if "secondary-element" in info { info.secondary-element } else { "none" }
                    let tertiary = if "tertiary-element" in info { info.tertiary-element } else { "none" }
                    
                    layout-timeline(info.at(section-key), 
                                   primary-element: primary, 
                                   secondary-element: secondary, 
                                   tertiary-element: tertiary, 
                                   settings: settings,
                                   isbreakable: isbreakable)
                } else if layout == "bullet-list" {
                    layout-bullet-list(info.at(section-key), isbreakable: isbreakable)
                } else if layout == "numbered-list" {
                    layout-numbered-list(info.at(section-key), isbreakable: isbreakable)
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
#let get-section-data(section, cv-data) = {
  // Create a dictionary that will hold all relevant section data
  let result = (:)
  
  // First check if this section has entries in it
  if "entries" in section {
    // Add entries to result
    result.insert("entries", section.entries)
  } else {
    // If the section doesn't have entries, use the existing top-level data
    if section.key in cv-data {
      result.insert("entries", cv-data.at(section.key))
    } else {
      // Set empty array if data is not found
      result.insert("entries", [])
    }
  }
  
  // Add layout configuration if present
  if "primary-element" in section {
    result.insert("primary-element", section.primary-element)
  }
  if "secondary-element" in section {
    result.insert("secondary-element", section.secondary-element)
  }
  if "tertiary-element" in section {
    result.insert("tertiary-element", section.tertiary-element)
  }
  
  return result
}