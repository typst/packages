// import fontawesome & academicons
#import "@preview/fontawesome:0.5.0": *
#import "@preview/use-academicons:0.1.0": *

// Functions from moderner-cv with changes
// link: https://github.com/DeveloperPaul123/modern-cv
// author DeveloperPaul123 (github)

// Function _cv-cols: setting style and table
// Arguments:
// - left: the content to be placed in the first column (Type: Any)
// - right: the content to be placed in the second column (Type: Any)
// - ..args: additional named arguments for customization

#let _cv-cols(left, right, ..args) = {
  
  // Set the block style with no spacing below
  set block(below: 0pt)
  
  // Create a table with specified column widths and no border strokes
  table(
    columns: (1.12fr, 5fr), // Set column widths
    stroke: none, // No border strokes
    
    // Spread any named arguments
    ..args.named(),
    
    // Insert the left and right content into the table
    left,
    right,
  )
}

// Function cv-cols: Putting input into the table
// Arguments:
// - left-side: the content to be aligned to the right (Type: Any)
// - right-side: the content to be formatted as a paragraph with justified alignment (Type: Any)
#let cv-cols(left-side, right-side) = {
  
  // Call the _cv-cols with aligned left-side and justified right-side parameters
  _cv-cols(
    // Align the left-side content to the right
    align(right, left-side),
    // Format the right-side content as a paragraph with justified alignment
    par(right-side, justify: true),
  )
}

// Function cv-cols-table: Putting input into the table
// Arguments:
// - left-side: the content to be aligned to the right (Type: Any)
// - right-side: the content to be formatted as a paragraph with justified alignment (Type: Any)
#let cv-cols-table(left-side, right-side) = {
  
  // Call the _cv-cols with aligned left-side and justified right-side parameters
  _cv-cols(
    // Align the left-side content to the right
    align(right, left-side),
    // Format the right-side content as a paragraph with justified alignment
    align(left, right-side)
  )
}

// Function cv-entry: a single entry in the CV
// Arguments:
// - date: content, 
// - title: content, 
// - location: content, and 
// - description (spread operator)
#let cv-entry(
  date: [],
  title: [],
  location: [],
  ..description,
) = {
  
  // Define elements to format the title and location, and include the spread description
  let elements = (
    // Make the title bold
    strong(title),
    // Make the location italicized
    emph(location),
    // Spread the description's positional arguments
    ..description.pos(),
  )
  
  // Call the cv-cols with the date and the joined elements as arguments
  cv-cols(
    date,
    // Join the elements with a comma and a space
    elements.join(", "),
  )
}

// Function cv-two-items: two items in a row with title (left-1/right-1) and description (left-2/right-2)
// Arguments:
// - left-1: content for the second column, aligned left (Type: Any)
// - right-1: content for the third column, aligned left (Type: Any)
// - left-2: content for the fourth column, aligned left (Type: Any)
// - right-2: content for the fifth column, aligned left (Type: Any)

#let cv-two-items(left-1, right-1, left-2, right-2) = {
  
  // Set the block style with no spacing below and 1em spacing between items
  set block(below: 0pt, spacing: 1em)
  
  // Create a table with specified column widths and no border strokes
  table(
    columns: (8.6em, 9em, 9em, 9em, 8em), // Set column widths
    stroke: none, // No border strokes
    
    // Align the table columns:
    // First column aligned left but left empty
    // Second column aligned left with left-1 content
    // Third column aligned left with right-1 content
    // Fourth column aligned left with left-2 content
    // Fifth column aligned left with right-2 content
    align(left, ""), 
    align(left, left-1), 
    align(left, right-1), 
    align(left, left-2), 
    align(left, right-2),
  )
}

// Function _header macro: Creating the header
// Arguments:
// - metadata: the metadata object containing paths and personal information (Type: Object)
// - multilingual: object with multilingual entries
// - language: a string indicating the language to use for the subtitle (Type: String, default: "de")

#let _header(
  metadata,
  multilingual,
  language: "de",
) = {
  // Load multilingual data from a YAML file
  // let multilingual = yaml(metadata.paths.i18n)
  let main_color = rgb(metadata.colors.main_color)
  let lightgray_color = rgb(metadata.colors.lightgray_color)
  let gray_color = rgb(metadata.colors.gray_color)
  // Initialize index to 0 for iteration
  let index = 0
  

  // Extract fields depending on language
  // Arguments
  // - dict: language dictionary of metadata.lang
  // - field: specific entry from dict
  let getFieldDict = (dict, field) => {
    // Check if the language exists in fields and return the corresponding value
    if field in dict.keys() {
      return dict.at(field)
    } else {
      return ""
    }
  }

  let subset = multilingual.lang.at(language)

  let subtitle = getFieldDict(subset, "subtitle")

  let title = []
  // Get the title from metadata
  if type(metadata.personal.name) == array {
    if metadata.personal.split {
      title = [
        #text(size: 32pt, metadata.personal.name.at(0).split(", ").at(1))
        #linebreak()
        #text(size: 32pt, metadata.personal.name.at(0).split(", ").at(0), baseline: -10pt)
      ]
    } else {
      title = [
        #text(size: 32pt, metadata.personal.name.at(0).split(", ").at(1))
        #text(size: 32pt, metadata.personal.name.at(0).split(", ").at(0))
      ]
    }
  } else if type(metadata.personal.name) == dictionary {
    if metadata.personal.split {
      title = [
        #text(size: 32pt, metadata.personal.name.firstname)
        #linebreak()
        #text(size: 32pt, metadata.personal.name.lastname, baseline: -10pt)
      ]
    } else {
      title = [
        #text(size: 32pt, metadata.personal.name.firstname)
        #text(size: 32pt, metadata.personal.name.lastname)
      ]
    }
  } else {
    if metadata.personal.split {
      title  = [
        #text(size: 32pt, metadata.personal.name.split(" ").at(0))
        #linebreak()
        #text(size: 32pt, metadata.personal.name.split(" ").at(1), baseline: -10pt)
      ]
     } else {
      title = [#text(size: 32pt, metadata.personal.name)]
    }
  }

  // let title = metadata.personal.name

  // if title.len() > 14 {
  //     text(size: 32pt, title.split(" ").at(0))
  //     linebreak()
  //     text(size: 32pt, title.split(" ").at(1))
  //   } else {
  //     text(size: 32pt, title)
  //   },

  // Create a title stack with title and subtitle
  let titleStack = stack(
    dir: ttb,
    spacing: 1em,
    text(size: 32pt, title),
    text(size: 24pt, subtitle, fill: gray_color),
  )

  // Initialize socialist as an empty array
  let socialist = ()

  // Iterate over each entry and field in metadata.personal.socials
  for (entry, field) in metadata.personal.socials {
    // Determine the icon type based on the 'set' attribute
    let iconType = if field.at("set") == "fa" { fa-icon } else if field.at("set") == "ai" { ai-icon } else { continue }

    // Get the icon and username
    let icon = field.at("icon")
    let username = field.at("username")

    // Create a link based on the presence of 'prefix'
    let textlink = if "prefix" in field.keys() {
      field.at("prefix") + username
    } else {
      username
    }

    // Push the formatted icon and link to the socialist array
    socialist.push(
      [
        // The icon as a clickable link
        #iconType(icon, fill: main_color) #link(textlink)[#text(username, fill: gray_color)]
      ]
    )
  }

  // Create a social block with the socialist array
  let socialBlock = stack(
    dir: ttb,
    spacing: 0.5em,
    ..socialist
  )

  // Title and social stack
  stack(
    dir: ltr,
    titleStack,
    align(
      right + top,
      socialBlock,
    )
  )
}

// New functions
// Function _adresser: function to build name and date at the end
// Arguments:
// - metadata: The metadata object containing paths and personal information (Type: Object)
// - multilingual: object with multilingual entries
// - language: A string indicating the language to use for the date format (Type: String, default: "de")

#let _adresser(
  metadata,
  multilingual,
  language: "de"
) = {

  // Load the multilingual YAML file specified in the metadata paths
  // let multilingual = yaml(metadata.paths.i18n)

  // Create a vertical stack with the personal name and date
  v(1fr, weak: false)

  // Display the personal name from metadata
  if type(metadata.personal.name) == array [
    #metadata.personal.name.at(0).split(", ").at(1) #metadata.personal.name.at(0).split(", ").at(0)
  ] else if type(metadata.personal.name) == dictionary [
    #text(metadata.personal.name.firstname) #text(metadata.personal.name.lastname)
  ] else [
    #text(metadata.personal.name)
  ]

  // Insert a line break
  linebreak()
    
  // Initialize the index to 0
  let index = 0

  // Iterate over each entry in the multilingual.lang collection
  for entry in multilingual.lang {
    
    // Check if the current language matches the language key at the current index
    if language == multilingual.lang.keys().at(index) {      
      
      // Display the current date in the format specified for the current language
      datetime.today().display(multilingual.lang.at(language).date-format)

      // Since we found the matching language, break out of the loop
      break
    }
    
    // Increment the index by 1 for the next iteration
    index += 1
  }
}

// Function modern-acad-cv: initiate CV
// Arguments:
// - metadata: the metadata object containing paths and personal information (Type: Object)
// - multilingual: object with multilingual entries
// - lang: a string indicating the language to use for the document (Type: String, default: "en")
// - font: the font to be used for the document (Type: String, default: "Fira Sans")
// - show-date: a boolean indicating whether to display the current date (Type: Boolean, default: true)
// - body: the main content of the CV (Type: Block)

#let modern-acad-cv(
  metadata,
  multilingual,
  lang: "en",
  font: ("Fira Sans", "Andale Mono", "Roboto"),
  show-date: true,
  body
) = {
  // Set the page settings with specified paper size and margins
  set page(
    paper: "a4",
    margin: (
      top: 2.5cm,
      bottom: 2.5cm,
      left: 1.5cm,
      right: 1.5cm,
    ),
    footer: [
      // Align the footer text to the right
      #set align(right)
      // Set the footer text properties
      #set text(
        fill: gray,
        size: 10pt
      )
      [
        // Display the current page number in the format "1/1"
        #context {counter(page).display("1/1", both: true)}
      ]
    ],
    footer-descent: 0pt,
  )

  // Define color variables from metadata
  let main_color = rgb(metadata.colors.main_color)
  let lightgray_color = rgb(metadata.colors.lightgray_color)
  let gray_color = rgb(metadata.colors.gray_color)

  // Set the text properties for the document
  set text(
    font: font,
    lang: lang,
  )

  // Define how to show headings (default level)
  show heading: it => {
    set text(weight: "regular")
    set text(main_color)
    set block(above: 0.65em)
    _cv-cols(
      [],
      [#it.body],
    )
  }
  
  // Define how to show level 1 headings
  show heading.where(level: 1): it => {
    set text(weight: "regular")
    set text(main_color)
    _cv-cols(
      align: horizon,
      [#box(fill: main_color, width: 30mm, height: 0.25em)],
      [#it.body],
    )
  }

  // Call the _header with metadata, and lang
  _header(metadata, multilingual, language: lang)

  // Insert the body content
  body

  // Show the current date if show-date is true
  if show-date {
    _adresser(metadata, multilingual, language: lang)
  }
}

// Function create-headers: Creating headers depending on language across the CV
// Arguments:
// - multilingual: object with multilingual entries
// - language: string, language code
#let create-headers(
  multilingual,
  lang: "de",
) = {
  // Load the multilingual YAML data
  // let multilingual = yaml(file)

  // Initialize an empty dictionary to store header labels
  let headLabs = (:)

  // Extract language-specific data from the multilingual data
  let languageData = multilingual.lang.at(str(lang))

  // Populate the headLabs dictionary with header labels
  for key in languageData.keys() {
    headLabs.insert(
      key,  // Header key
      languageData.at(key)  // Localized header text
    )
  }

  // Return the populated dictionary
  return headLabs
}

// Function cv-auto-cats: This function processes and formats a dictionary of training or course information based on the specified language. The function retrieves and formats various fields such as title, subtitle, date, location, and description, and outputs them in a structured format.
// Arguments:
// - what: object with data
// - multilingual: object with multilingual entries
// - language: A string representing the language code (e.g., "de" for German). This determines which language-specific fields to display. Defaults to "de".

#let cv-auto-cats(
  what,
  multilingual,   
  headers,
  lang: "de"
) = {

  // Initialize variables to store course details.
  let date = ""          // Variable to hold the date for each course
  let title = ""         // Variable to hold the title of each course
  let subtitle = ""     // Variable to hold the subtitle of each course
  let location = ""      // Variable to hold the location of each course
  let description = ""   // Variable to hold the description of each course
  let index = 0          // Index to track the current key in the dictionary

  // Create a headers dictionary based on the specified language, used for translating category names.
  // let headers = create-headers(metadata.paths.i18n, lang: lang)

  // Function to retrieve a language-specific field from a dictionary.
  // Arguments:
  //   - fields: A dictionary containing values for different languages.
  //   - lang: A string representing the desired language code.
  let getLangField = (fields, lang) => {
    // Return the value corresponding to the specified language, or an empty string if not found.
    if lang in fields.keys() {
      return fields.at(lang)
    } else {
      return ""
    }
  }

  // Iterate over each key (category) in the main dictionary.
  for key in what.keys() {
    let subset = what.at(key)  // Sub-dictionary for the current category.
    let header = what.keys().at(index)  // Current category key.

    // Prefix the header with "training-" to match localization keys.
    let header = "training-" + header

    // Retrieve the localized category name using the headers dict.
    let headerValue = if header in headers.keys() { headers.at(header) } else { "Unknown Header" }

    // Output the localized category name as a header.
    [== #headerValue]

    // Iterate over each course in the current category (subset).
    for course in subset.keys() { 
      let subset2 = subset.at(course)  // Sub-dictionary for the current course.

      // Extract the date from the course details.
      if "left" in subset2.keys() {
        if type(subset2.left) == dictionary {
          date = getLangField(subset2.left, lang)
        } else {
          date = subset2.left
        }
      }

      // Extract the title, checking if it is a multilingual field.
      if type(subset2.title) == dictionary { 
        title = getLangField(subset2.title, lang)
      } else {
        title = subset2.title
      }

      // Extract the subtitle if present, using language-specific fields.
      if "subtitle" in subset2.keys() {
        if type(subset2.subtitle) == dictionary {
          subtitle = getLangField(subset2.subtitle, lang)
        } else {
          substitle = subset2.subtitle
        }
      }

      // Extract the location if present in the course details.
      if "location" in subset2.keys() {
        if type(subset2.location) == dictionary {
          location = getLangField(subset2.location, lang)
        } else {
          location = subset2.location
        } 
      }

      // Extract the description if present, using language-specific fields.
      if "description" in subset2.keys() {
        if type(subset2.description) == dictionary {
          description = getLangField(subset2.description, lang)
        } else {
          description = subset2.description
        }
      }

      // Initialize an empty tuple to store elements to be displayed.
      let elements = ()

      // Conditionally build elements based on the availability of keys in the course details.
      if ("location", "subtitle", "description") in subset2.keys() {
        elements = (
          strong(title),
          (subtitle),  // Bold title with subtitle.
          location,                        // Location of the course.
          emph(description)               // Emphasized description.
        )

        // Output the formatted content with date and elements.
        cv-cols(
          date,
          elements.join(", ")
        )
      } 
      else if ("location", "subtitle") in subset2.keys() {
        elements = (
          strong(title),
          (subtitle),  // Bold title with subtitle.
          location                       // Location of the course.
        )

        // Output the formatted content with date and elements.
        cv-cols(
          date,
          elements.join(", ")
        )
      } 
      else if ("location") in subset2.keys() {
        elements = (
          strong(title),  // Bold title only.
          location           // Location of the course.
        )

        // Output the formatted content with date and elements.
        cv-cols(
          date,
          elements.join(", ")
        )
      } 
      else if ("subtitle") in subset2.keys() {
        elements = [#strong(title) (#subtitle)]  // Bold title with subtitle only.

        // Output the formatted content with date and elements.
        cv-cols(
          date,
          elements
        )
      }
    }

    // Increment the index to move to the next key in the dict.
    index += 1
  }
}


// Function make-entry-apa: Creates a formatted reference string for an entry in APA style.  This function uses internationalization (i18n) data and fields from the cv-refs function to generate the reference. The function supports customization based on the author's name and language.
// Arguments:
// - fields: A dictionary containing details of a single reference entry (e.g., authors, title, publication date).
// - multilingual: object with multilingual entries
// - me: An optional string representing the author's name that should be highlighted in the final reference string.
// - lang: A string indicating the language of the CV or document (e.g., "en" for English). Defaults to "en".
#let make-entry-apa(
  fields,
  multilingual,
  me: none, 
  lang: "en"
) = {

  // Extract the list of authors from the fields.
  let authors = fields.author

  // Function to format a list of authors into a string.
  // Arguments:
  //   - auths: A list of authors to be formatted.
  //   - max_count: Maximum number of authors to display before using "et al."
  //   - me: The author's name to be highlighted, if applicable.
  let format_authors(auths, max_count, me) = {

    // Initialize an empty list to hold the formatted authors.
    let formatted_authors = ()

    // Determine the number of authors to display, limited by `max_count`.
    let count = calc.min(auths.len(), max_count) - 1

    // Create a list of indices for authors using a while loop.
    let indices = ()
    let i = 0
    while i <= count {
      indices.push(i)
      i += 1
    }

    // Format each author into "Last, F." format and add to the list.
    for author in indices {
      let index = indices.at(author)
      let parts = auths.at(index).split(", ")
      let author = text(parts.at(0) + ", " + parts.at(1).first() + ".")

      // Highlight the author's name if it matches `me` or one of the names in the array `me`
      if not me == none {
        if author == me or type(me) == array and author in me {
          if "corresponding" in fields and fields.corresponding == true {
            author = strong(author + super("C"))  // Add a superscript "C" for corresponding author.
          } else {
            author = strong(author)
          }
        }
      }
      formatted_authors.push(author)
    }

    // Return the formatted list of authors, appending "et al." if necessary.
    if auths.len() > max_count {
      return [#formatted_authors.join(", ") _et. al._]
    } else {
      return [#formatted_authors.join(", ", last: " & ")]
    }
  }


  // Check if the reference has a parent entry with additional authors (e.g., editors).
  if "parent" in fields and "author" in fields.parent {
    let editors = fields.parent.author
  }

  // Function to format a list of editors into a string.
  // Arguments:
  //   - auths: A list of authors to be formatted.
  //   - max_count: Maximum number of authors to display before using "et al."
  //   - me: The author's name to be highlighted, if applicable.
  let format_editors(eds, max_count, me) = {

    // Initialize an empty list to hold the formatted authors.
    let formatted_editors = ()

    // Determine the number of authors to display, limited by `max_count`.
    let count = calc.min(eds.len(), max_count) - 1

    // Create a list of indices for authors using a while loop.
    let indices = ()
    let i = 0
    while i <= count {
      indices.push(i)
      i += 1
    }

    // Format each author into "Last, F." format and add to the list.
    for editor in indices {
      let index = indices.at(editor)
      let parts = eds.at(index).split(", ")
      let editor = text(parts.at(1).first() + ". " + parts.at(0))

      // Highlight the author's name if it matches `me`.
      if not me == none and editor == me {
        if "corresponding" in fields and fields.corresponding == true {
          editor = strong(me + super("C"))  // Add a superscript "C" for corresponding author.
        } else {
          editor = strong(me)
        }
      }
      formatted_editors.push(editor)
    }

    // Return the formatted list of authors, appending "et al." if necessary.
    if eds.len() > max_count {
      return [#formatted_editors.join(", ") _et. al._]
    } else {
      return [#formatted_editors.join(", ", last: " & ")]
    }
  }
  
  // Function to format the publication date or publication state.
  // Arguments:
  //   - fields: The reference fields dict.
  //   - lang: The language code for localization.
  let format_date(fields, lang) = {
    // Handle cases where no date is available.
    if not "date" in fields {
      if not "pubstate" in fields {
        return [ (n.d.). ]  // Return "n.d." (no date) if neither date nor pubstate is available.
      } else {
        // Handle cases with a publication state.
        let header = fields.at("pubstate")
        let search = "pubstate-" + header

        // Lookup the publication state string in the i18n data.
        let subset = multilingual.lang.at(lang)
        if search in subset {
          return [ (#subset.at(search)).]
        } else {
          return [. ]
        }
      }
    } else {
      return [ (#fields.date). ]  // Return the formatted date.
    }
  }

  // Function to format the title of the work.
  // Arguments:
  //   - title: The title of the work, which could be a string or a dictionary (for multilingual titles).
  //   - lang: The language code for localization.
  let format_title(title, lang) = {
    // Handle multilingual titles stored in a dict.
    if type(title) == dictionary {
      if not lang in title {
        return [ #eval(title.main, mode: "markup")]  // Return the main title if the specified language is not available.
      } else {
        // If the title is available in the document's language, format it accordingly.
        for entry in fields.title.keys() {
          if lang in fields.title.keys() {
            return [ #eval(title.main, mode: "markup") \[#eval(title.at(lang), mode: "markup")\]]
          } else {
            return [ #emph("Missing title for document language")]
          }
        } 
      }
    } else {
     return [ #eval(title, mode: "markup")]  // Return the title as markup formatted string.
    }
  }

  // Initialize an empty string for building the reference.
  let reference = text("")

  // Handle references of type "article".
  if fields.type == "article" {
    reference += format_authors(authors, 6, me)
    reference += format_date(fields, lang)
    reference += format_title(fields.title, lang)

    // Handle special case where the publication state is provided.
    if "pubstate" in fields {
      reference += [.]
    } else {
      // Add parent information such as the title of the journal or volume number.
      if "parent" in fields and "title" in fields.parent {
        reference += [. #emph(fields.parent.title),]
      }
      if "parent" in fields and "volume" in fields.parent {
        reference += [ #emph(str(fields.parent.volume))]
      }
      if "parent" in fields and "issue" in fields.parent {
        reference += [(#emph(str(fields.parent.issue))),]
      } else {
        reference += [,]
      }
      if "page-range" in fields {
        reference += [ #fields.page-range.]
      }
      if "serial-number" in fields and "doi" in fields.serial-number {
        let url = "https://doi.org/" + fields.serial-number.doi
        reference += [ #link(url)[#url]]
      }
    }
  } else if fields.type == "chapter" { // Handle references of type "chapter".
    reference += format_authors(authors, 6, me)
    reference += format_date(fields, lang)
    reference += format_title(fields.title, lang)

    // Include information about the parent work (e.g., book or edited volume).
    if "parent" in fields and "author" in fields.parent {
      reference += [. In #format_editors(fields.parent.author, 6, me) (Eds.),]
    } else {
      reference += " In "
    }
    if "parent" in fields and "title" in fields.parent {
      reference += [ #emph(fields.parent.title)]
    }
    if "page-range" in fields {
      reference += [ (pp. #fields.page-range).]
    }
    if "publisher" in fields.parent {
      reference += [ #fields.parent.publisher.]
    }
    if "serial-number" in fields and "doi" in fields.serial-number {
      let url = "https://doi.org/" + fields.serial-number.doi
      reference += [ #link(url)[#url]]
    }
  } else if fields.type == "book" {  // Handle references of type "book".
    reference += format_authors(authors, 6, me)
    reference += format_date(fields, lang)
    reference += format_title(fields.title, lang)

    // Include edition and publisher information if available.
    if "edition" in fields {
      reference += [ (#fields.edition).]
    }
    if "publisher" in fields {
      reference += [ #fields.publisher.]
    }
    if "serial-number" in fields and "doi" in fields.serial-number {
      let url = "https://doi.org/" + fields.serial-number.doi
      reference += [ #link(url)[#url]]
    }
  } else { // Handle other types of references.
    reference += format_authors(authors, 6, me)
    reference += format_date(fields, lang)
    reference += format_title(fields.title, lang)

    // Include additional fields like edition or archive information if available.
    if "edition" in fields {
      reference += [ (#fields.edition).]
    } else {
      reference += [.]
    }
    if "archive" in fields {
      reference += [ #fields.archive.]
    }
    if "serial-number" in fields and "doi" in fields.serial-number {
      let url = "https://doi.org/" + fields.serial-number.doi
      reference += [ #link(url)[#url]]
    }
  }

  // Return the formatted reference.
  reference
  parbreak()  // Add a paragraph break after the reference.
}

// Function cv-refs: Creating a reference list
// can be filtered by specific entries or tags
// can highlight own name
// can use given translations of title in i18n.yaml, if submitting CV in different language
// Arguments
// - what: object with data
// - multilingual: object with multilingual entries
// - entries: An array of strings, representing the specific entries to include in the output. Defaults to an empty list (), which will include all entries in the file.
// - tag: An optional string. If provided, only entries with this tag will be included. Defaults to none.
// - me: An optional string, likely representing the name of the author. Used for personalized output (name will be bold). Defaults to none.
// - lang: A string specifying the language to be used in the references (e.g., "de" for German). If CV is in different language than title-main, translations will be add to the reference (translations need to be given in i18n.yaml) Defaults to "de".

#let cv-refs(
  what,
  multilingual,  
  entries: (), 
  tag: none,
  me: none,
  lang: "de"
) = {
  // Set paragraph formatting options:
  // - `hanging-indent`: Indentation for the second and subsequent lines of each paragraph.
  // - `justify`: Whether the text should be justified.
  // - `linebreaks`: Automatic line breaks to fit the content within the width of the page.
  set par(
    hanging-indent: 2em,
    justify: true,
    linebreaks: auto
  )
  
  // Set spacing above each block of text.
   set block(above: 0.65em)
  
  // create object
  // If `entries` is empty, populate it with all keys from the YAML file.
  if entries.len() == 0 {
    entries = what.keys()
  }

  // Initialize counters for different types of publications.
  let articles = 0
  let incollections = 0
  let books = 0
  let others = 0
  let planned = 0

  // Loop through each entry in the YAML file to count the types of publications.
  for (entry, field) in what {
    if field.tags == "planned" {
      planned += 1
    } else if field.type == "article" {
      articles += 1 
    } else if field.type == "chapter" {
      incollections += 1
    } else if field.type == "book" {
      books += 1
    } else if field.tags == "other" {
      others += 1
    } 
  }

  // Loop through each entry in the YAML file to generate the reference list.
  for (entry, fields) in what {
    
    // Skip entries not specified in entries if entries are specified.
    if entry not in entries {
      continue
    }
 
    // If a tag is provided, skip entries that don't have the specified tag.
    if not tag == none {
      if "tags" not in fields or tag not in fields.tags {
        continue
      }
    }

    // If entry is in one of the categories, the total number will be subtracted by one to show decreasing numbers aside the publications per section
    if fields.tags == "planned" {
      [\[#planned\] ]
      planned -= 1
    } else if fields.type == "article" {
      [\[#articles\] ]
      articles -= 1
    } else if fields.type == "chapter" {
      [\[#incollections\] ]
      incollections -= 1
    } else if fields.type == "book" {
      [\[#books\] ]
      books -= 1
    } else if fields.tags == "other" {
      [\[#others\] ]
      others -= 1
    } 

    // Generate the reference entry using a custom function `make-entry-apa`.
    // This function formats the reference according to APA style.
    // Parameters passed are the `fields` (details of the entry), `multilingual` (multilingual object), `me` (author name), and `lang` (language).
    make-entry-apa(fields, multilingual, me: me, lang: lang)
  }
}

// Function cv-auto: Creating list of cv-entries based on the given yaml-file (path)
// see example dbs/committee.toml
// no extra formatting
// Arguments:
// - what: object with data
// - multilingual: object with multilingual entries
// - lang: language of cv
#let cv-auto(
  what,
  multilingual,
  lang: "de"
) = {
  // let date = ""
  // let title = ""
  // let subtitle = ""
  // let location = ""
  // let description = ""
  let subset = (:)  // // Initialize the subset dict

  // Iterate over each key in the database
  for key in what.keys() {
    let date = ""
    let title = ""
    let subtitle = ""
    let location = ""
    let description = ""
    subset = what.at(key)

    // Iterate over available languages in the multilingual data
    for language in multilingual.lang.keys() {
      if lang == language {
        // Handle the 'left' field
        if type(subset.at("left")) == dictionary {
          date = subset.left.at(lang)
        } else {
          date = subset.left
        }

        // Handle the 'title' field
        if type(subset.at("title")) == dictionary {
          title = subset.title.at(lang)
        } else {
          title = subset.title
        }

        // Handle the 'subtitle' field
        if "subtitle" in subset.keys() {
          if type(subset.at("subtitle")) == dictionary {
            subtitle = subset.subtitle.at(lang)
          } else {
            subtitle = subset.subtitle
          }
        }

        // Handle the 'location' field
        if "location" in subset.keys() {
          if type(subset.at("location")) == dictionary {
            location = subset.location.at(lang)
          } else {
            location = subset.location
          }
        }

        // Handle the 'description' field, if it exists
        if "description" in subset.keys() {
          if type(subset.at("description")) == dictionary {
            description = subset.description.at(lang)
          } else {
            description = subset.description
          }
        }

        // Since we found the matching language, break out of the loop
        break
      }
    }

    // Construct the elements for cv-cols output based on available keys
    let entry = title

    if "subtitle" in subset.keys() {
      entry += [, #subtitle]
    }

    if "location" in subset.keys() {
      entry += [, #location]
    }

    if "description" in subset.keys() {
      entry += [, #description]
    }

    cv-cols(
      date,
      entry
    )
  }
}

// Function cv-auto-stc: formats and generates a list of events based on data from a YAML file and multilingual labels. Format TItle, Subtitle, Location, Description
// Arguments:
// - what: object containing the information
// - multilingual: object with multilingual entries
// - lang: Language code to fetch language-specific text from the YAML data.
#let cv-auto-stc(
  what,
  multilingual,    
  lang: "de" 
) = {
  let date = ""          // Date of the event.
  let title = ""         // Title of the event.
  let subtitle = ""      // Subtitle of the event (if available).
  let check = ""         // Unused variable, potentially for future checks or operations.
  let location = ""      // Location of the event (if available).
  let description = ""   // Description of the event (if available).

  // Initialize an index for language iteration
  let index = 0

  // Iterate over each key (event) in the dictionary
  for key in what.keys() {
    let subset = what.at(key)
    
    // Iterate over available languages in the multilingual data
    for language in multilingual.lang {
      if lang == language.at(index) {
        // Handle the 'left' field for date
        if type(subset.at("left")) == dictionary {
          date = subset.left.at(lang)
        } else {
          date = subset.left
        }

        // Handle the 'title' field
        if type(subset.at("title")) == dictionary {
          title = subset.title.at(lang)
        } else {
          title = subset.title
        }

        // Handle the 'subtitle' field
        if type(subset.at("subtitle")) == dictionary {
          subtitle = subset.subtitle.at(lang)
        } else {
          subtitle = subset.subtitle
        }

        // Handle the 'location' field
        if type(subset.at("location")) == dictionary {
          location = subset.location.at(lang)
        } else {
          location = subset.location
        }

        // Handle the 'description' field, if it exists
        if "description" in subset.keys() {
          if type(subset.at("description")) == dictionary {
            description = subset.description.at(lang)
          }
        }

        // Since the matching language is found, break out of the loop
        break
      } 
        
    }

    // Construct the elements for cv-cols output based on available keys
    let entry = strong(title)

    if "subtitle" in subset.keys() {
      entry += [, #emph(subtitle)]
    }

    if "location" in subset.keys() {
      entry += [, #location]
    }

    if "description" in subset.keys() {
      entry += [, #description]
    }
    
    // If no subtitle is available, create a column with just the title
    cv-cols(
      date,
      entry
    )
 }
}

// Function cv-auto-stp: generates a formatted table of events based on data from a YAML file, supporting multiple languages: Title (Subtitle), location, description
// Arguments:
// - what: object containing the information
// - multilingual: object with multilingual entries
// - lang: The language code to use for fetching language-specific text from the YAML data (default is "de").
#let cv-auto-stp(
  what, 
  multilingual,    
  lang: ""
) = {
    // Initialize variables
    let date = ""          // Date of the event.
    let title = ""         // Title of the event.
    let subtitle = ""      // Subtitle of the event (if available).
    let location = ""      // Location of the event.
    let description = ""   // Description of the event (if available).
    let index = 0          // Index for iterating through languages.

    // Iterate over the keys (events) in the dictionary
    for key in what.keys() {
      let subset = what.at(key)

      // Iterate over available languages in the multilingual data
      for language in multilingual.lang {
        if lang == language.at(index) {
          // Handle the 'left' field for date
          if type(subset.at("left")) == dictionary {
            date = subset.left.at(lang)
          } else {
            date = subset.left
          }

          // Handle the 'title' field
          if type(subset.at("title")) == dictionary {
            title = subset.title.at(lang)
          } else {
            title = subset.title
          }

          // Handle the 'subtitle' field
          if type(subset.at("subtitle")) == dictionary {
            subtitle = subset.subtitle.at(lang)
          } else {
            subtitle = subset.subtitle
          }

          // Handle the 'location' field
          if type(subset.at("location")) == dictionary {
            location = subset.location.at(lang)
          } else {
            location = subset.location
          }

          // Handle the 'description' field, if it exists
          if "description" in subset.keys() {
            if type(subset.at("description")) == dictionary {
              description = subset.description.at(lang)
            }
          }

          // Since we found the matching language, break out of the loop
          break
        } 
      }

      // Create elements for the event
      let entry = strong(title)

      if "subtitle" in subset.keys() {
        entry += [ (#subtitle)]
      }

      if "location" in subset.keys() {
        entry += [, #location]
      }

      if "description" in subset.keys() {
        entry += [, #emph(description)]
      }
    
      // Generate a column with the event date and elements without description
      cv-cols(
        date,
        entry
      )
    }
  }


// Function cv-table-teaching: generates a table of events based on data from a YAML file and multilingual labels. It processes the events to include details such as the term (summer/winter), name, and study information. The function constructs a table with headers and details for each event, displaying them in the specified language.
// see example dbs/teaching.toml
// Arguments:
// - what: object with data
// - multilingual: object with multilingual entries
// - lang: language code for fetching language-specific text from the YAML data.
#let cv-table-teaching(
  what, 
  multilingual,          
  lang: ""  
) = {
  // Initialize variables
  let overview = ()                  // Container to store event details for the table.
  let term = ()                      // Temporary variable for storing term information (summer/winter).
  let tabhelp = ()                   // Container for storing table headers and labels.
  let year = ""                     // Year extracted from the YAML data.
  let name = ""                     // Event name.
  let study = ""                    // Study details for the event.
  let index1 = 0                    // Index for iterating through dictionary keys.
  let tab-year = ""                 // Header for the year column in the table.
  let tab-course = ""               // Header for the course column in the table.
  let tab-study = ""                // Header for the study column in the table.
  let tab-note = ""                 // Header for the note column in the table.
  let index = 0                     // Index for iterating through dictionary entries.

  // Iterate over the keys (years) in the dictionary
  for key in what.keys() {
    // Extract the year from the dictionary
    year = what.keys().at(index)
 
    // Get the subset of events for the current year
    let subset = what.at(key) 

    // Iterate over each course in the subset
    for course in subset.keys() {
      let subset2 = subset.at(course)

      // Iterate over available languages in the multilingual data
      for language in multilingual.lang.keys() {
        if lang == language {
          // Determine the term (summer/winter) and corresponding header
          if "summer" in subset2.keys() {
            if subset2.summer == "T" {
              term = [#multilingual.lang.at(lang).table-summer #year]
            } else {
              term = [#multilingual.lang.at(lang).table-winter #year]
            }
          } else {
            [#year]
          }
          
          // Get the name and study details based on the selected language
          name = subset2.name.at(lang)
          study = subset2.study.at(lang)   

          // Get headers for table columns
          tab-year = multilingual.lang.at(lang).tab-year
          tab-course = multilingual.lang.at(lang).tab-course
          tab-study = multilingual.lang.at(lang).tab-study
          tab-note = multilingual.lang.at(lang).tab-note

          // Exit the language loop as we found the matching language
          break
        } 
      }

      // Create a tuple with term, name, and study details for the event
      let help = (term, name, study)

      // Create a tuple with table headers and note
      tabhelp = (tab-year, tab-course, tab-study, tab-note)

      // Add the event details to the overview
      overview.push(help)
    } 

    // Increment the index to process the next year
    index += 1
  }
  
  // Create a table using the collected event details
  cv-cols-table(
    "",
    table(
      columns: 3,                       // Define the number of columns
      stroke: none,                    // No border strokes
      table.header(
        [#tabhelp.at(0)],              // Year column header
        [#tabhelp.at(1)],              // Course column header
        [#tabhelp.at(2)],              // Study column header
      ),
      table.hline(),                   // Horizontal line under the header
        ..for (k, x, v) in overview { // Populate table rows with event details
          (k, x, v)
        },
      table.hline(),                   // Horizontal line at the end of the table
      table.cell(
        colspan: 3,                  // Cell spanning all columns for the note
        tabhelp.at(3)                // Note text
      )
    )
  )
}


// Function cv-auto-list: generates a list of events for each year based on data from a YAML file. It formats the events into a concatenated string that includes the name and action of each event, and displays this information alongside the respective year.
// Arguments:
// - what: object with data
// - multilingual: object with multilingual entries
// - lang: Language code for fetching language-specific text from the YAML data.
#let cv-auto-list(
  what,
  multilingual,        
  lang: "de"   
) = {
  // Initialize variables
  let name = ""       // Name of the event.
  let action = ""     // Action associated with the event.
  let year = ""       // Year extracted from the YAML data.
  let subset = ""     // Subset of events for the current year.
  let index = 0       // Index for iterating through dictionary keys.

  // Iterate over the keys (years) in the dictionary
  for key in what.keys() {
    // Extract the year from the dictionary
    year = what.keys().at(index)

    // Initialize an empty list to hold events for the current year
    let conf-in-year = []
    
    // Get the subset of events for the current year
    let subset = what.at(key) 

    // Iterate over each event in the subset
    for event in subset.keys() {
      let subset2 = subset.at(event)

      // Extract the name and action of the event
      if type(subset2.name) == dictionary {
         for language in multilingual.lang.keys() {
            if lang == language {
              name = subset2.name.at(lang)
            }
         }
      } else {
        name = subset2.name
      }
      
      action = subset2.action

      // Format the event details as text and concatenate to the list
      if conf-in-year.children.len() == 0 {
        conf-in-year = text([#name#super[#action]])
      } else {
        conf-in-year = conf-in-year + ", " + text([#name#super[#action]])
      }     
    }
    // Increment the index to process the next year
    index = index + 1

    // Generate a column with the year and concatenated event details
    cv-cols(
      year,          // Year column
      conf-in-year   // Concatenated event details for the year
    )
  }
}

// Function cv-auto-skill: generates a table of skills based on data from a YAML file and multilingual labels. It processes skills data to categorize them into "computer," "programs," and "languages" sections, and generates a table with this information. The skill levels are represented with icons.
// see example dbs/skills.toml
// Arguments:
// - what: object with data
// - multilingual: object with multilingual entries
// - lang:  language of cv; the language code to use for fetching language-specific fields from the YAML data.
#let cv-auto-skills(
  what,
  multilingual,      
  metadata,    
  lang: "de"    
) = {
  // Initialize variables
  let skill = ""                      // Temporary variable to store skill names.
  let index1 = 0                     // Index variable for iterating through dictionary keys.
  let index2 = 0                     // Index variable for iterating through multilingual language keys.
  let overview = (:)                  // Container for storing categorized skills.
  let tab-header = ()                // Container for storing table headers.
  let help = ()                      // Temporary variable to store individual skill details.
  let name = ""                     // Skill name.
  let level = 0                     // Skill level.
  let level-text = ""               // Text representation of the skill level icons.
  let description = ""              // Skill description.
  let main_color = rgb(metadata.colors.main_color)
  let gray_color = rgb(metadata.colors.gray_color)
  let lightgray_color = rgb(metadata.colors.lightgray_color)

  // Initialize helper arrays
  let computer = ()                 // List to store computer-related skills.
  let programs = ()                 // List to store program-related skills.
  let languages = ()                // List to store language-related skills.
  let header = ""                   // Temporary variable to store the current category header.

  // Function to generate level icons based on the skill level
  let level-icons(level) = {
    let i = 1 
    let filled_icons = (
      // Generate icons representing filled levels
      while i <= level {
        [#fa-icon("square", solid: true, fill: main_color) ]
        i += 1
      }
    )
    
    let rest = 4 - level
    let i = 1
    let unfilled_icons = (
      // Generate icons representing unfilled levels
      while i <= rest {
        [#fa-icon("square", solid: true, fill: lightgray_color) ]
        i += 1
      }
    )
    
    // Combine filled and unfilled icons
    filled_icons + unfilled_icons
  }

  // Function to get language-specific field
  let getLangField = (field, lang) => if type(field) == dictionary { field.at(lang) } else { field }

  // Process all categories dynamically
  for category in what.keys() {
    let category_skills = ()  // Array to store skills for current category
    let subset = what.at(category)

    for skill_name in subset.keys() {
      let details = subset.at(skill_name)

      // Get the name and description based on the language
      if type(details.name) == dictionary {
        name = getLangField(details.name, lang)
      } else {
        name = details.name
      }

      if type(details.description) == dictionary {
        description = getLangField(details.description, lang)
      } else {
        description = details.description
      }

      level = details.level
      level-text = level-icons(level)
      
      help = (name, level-text, description)
      category_skills.push(help)
    }

    // Store the category's skills in the overview dictionary
    overview.insert(category, category_skills)
  }


  // Load multilingual labels for the current language
  let sublang = multilingual.lang.at(lang)
  // let tab-header = (sublang.skills-computer, sublang.skills-programs, sublang.skills-languages)
  let skills-tab-skills = sublang.skills-tab-skills
  let skills-tab-level = sublang.skills-tab-level
  let skills-tab-comment = sublang.skills-tab-comment
  let skills-leg1 = sublang.skills-leg1
  let skills-leg2 = sublang.skills-leg2
  let skills-leg3 = sublang.skills-leg3
  let skills-leg4 = sublang.skills-leg4
  
  // Create the skills table
  table(
    columns: (1.12fr, 0.95fr, 0.8fr, 1.5fr, 1.7fr), // Define column widths
    rows: 1,                             // Set initial number of rows
    stroke: none,                        // No border strokes
    table.header(
      text("test", fill: white),        // Table header title
      [#skills-tab-skills],
      [#skills-tab-level],
      [#skills-tab-comment],
      [],
    ),
    table.hline(start: 1, stroke: (paint: gray_color, thickness: 1.25pt, dash: "dotted")), // Horizontal line after the header
    
    // Dynamically generate table sections for each category
    ..for (category, skills) in overview {
      let category_header = if "skills-" + category in sublang {
        sublang.at("skills-" + category)
      } else {
        category
      }

      (
        // Category header cell
        table.cell(
          rowspan: skills.len(),
          align: top + right,
        )[
          #strong(category_header)
        ],
        // Skills rows
        ..for (name, level_icons, desc) in skills {
          (
            name,
            level_icons,
            table.cell(colspan: 2)[#desc]
          )
        },
        // Separator line after category
        table.hline(start: 1, stroke: (paint: gray_color, thickness: 1.25pt, dash: "dotted")),
      )
    },
    // Add legends for skill levels
    table.cell(""),
    table.cell(colspan: 2)[
      #level-icons(1)
      #text(skills-leg1, size: 0.7em)
    ],
    table.cell(colspan: 2)[
      #level-icons(3)
      #text(skills-leg3, size: 0.7em)
    ],
    table.cell(""),
    table.cell(colspan: 2)[
      #level-icons(2)
      #text(skills-leg2, size: 0.7em)
    ],
    table.cell(colspan: 2)[
      #level-icons(4)
      #text(skills-leg4, size: 0.7em)
    ]
  )
}
