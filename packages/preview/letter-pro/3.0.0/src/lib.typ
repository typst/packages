// ####################
// # typst-letter-pro #
// ####################
// 
// Project page:
// https://github.com/Sematre/typst-letter-pro
// 
// References:
// https://de.wikipedia.org/wiki/DIN_5008
// https://www.deutschepost.de/de/b/briefvorlagen/normbrief-din-5008-vorlage.html
// https://www.deutschepost.de/content/dam/dpag/images/P_p/printmailing/downloads/automationsfaehige-briefsendungen-2023.pdf
// https://www.edv-lehrgang.de/din-5008/
// https://www.edv-lehrgang.de/anschriftfeld-im-din-5008-geschaeftsbrief/

// ##################
// # Letter formats #
// ##################
#let letter-formats = (
  "DIN-5008-A": (
    folding-mark-1-pos: 87mm,
    folding-mark-2-pos: 87mm + 105mm,
    header-size: 27mm,
  ),
  
  "DIN-5008-B": (
    folding-mark-1-pos: 105mm,
    folding-mark-2-pos: 105mm + 105mm,
    header-size: 45mm,
  ),
)

// ##################
// # Generic letter #
// ##################

/// This function takes your whole document as its `body` and formats it as a simple letter.
/// 
/// - format (string): The format of the letter, which decides the position of the folding marks and the size of the header.
///   #table(
///     columns: (1fr, 1fr, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Format],
///     text(weight: "semibold")[Folding marks],
///     text(weight: "semibold")[Header size],
///     
///     [DIN-5008-A], [87mm, 192mm],  [27mm],
///     [DIN-5008-B], [105mm, 210mm], [45mm],
///   )
/// 
/// - header (content, none): The header that will be displayed at the top of the first page.
/// - footer (content, none): The footer that will be displayed at the bottom of the first page. It automatically grows upwords depending on its body. Make sure to leave enough space in the page margins.
/// 
/// - folding-marks (boolean): The folding marks that will be displayed at the left margin.
/// - hole-mark (boolean): The hole mark that will be displayed at the left margin.
/// 
/// - address-box (content, none): The address box that will be displayed below the header on the left.
/// 
/// - information-box (content, none): The information box that will be displayed below below the header on the right.
/// - reference-signs (array, none): The reference signs that will be displayed below below the the address box. The array has to be a collection of tuples with 2 content elements.
///   
///   Example:
///   ```typ
///   (
///     ([Foo],   [bar]),
///     ([Hello], [World]),
///   )
///   ```
/// 
/// - page-numbering (auto, string, function, none): Defines the format of the page numbers.
///   #table(
///     columns: (auto, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Type], text(weight: "semibold")[Description],
///     [auto],     [Automatically determines the document language and chooses an appropriate translation.],
///     [string],   [A numbering pattern as specified by the official documentation of the #link("https://typst.app/docs/reference/model/numbering/", text(blue)[_numbering_]) function.],
///     [function], [
///       A function that returns the page number for each page.\
///       Parameters:
///       - current-page (integer)
///       - page-count (integer)
///       Return type: _content_
///     ],
///     [none],     [Disable page numbering.],
///   )
/// 
/// - margin (dictionary): The margin of the letter.
///   
///   The dictionary can contain the following fields: _left_, _right_, _top_, _bottom_.\
///   Missing fields will be set to the default. 
///   Note: There is no _rest_ field.
/// 
/// - body (content, none): The content of the letter
/// -> content
#let letter-generic(
  format: "DIN-5008-B",
  
  header: none,
  footer: none,
  
  folding-marks: true,
  hole-mark: true,
  
  address-box: none,
  information-box: none,
  
  reference-signs: none,
  
  page-numbering: auto,

  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  
  body,
) = {
  if not letter-formats.keys().contains(format) {
    panic("Invalid letter format! Options: " + letter-formats.keys().join(", "))
  }
  
  margin = (
    left:   margin.at("left",   default: 25mm),
    right:  margin.at("right",  default: 20mm),
    top:    margin.at("top",    default: 20mm),
    bottom: margin.at("bottom", default: 20mm),
  )
  
  set page(
    paper: "a4",
    flipped: false,
    
    margin: margin,
    
    background: {
      if folding-marks {
        // folding mark 1
        place(top + left, dx: 5mm, dy: letter-formats.at(format).folding-mark-1-pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
        
        // folding mark 2
        place(top + left, dx: 5mm, dy: letter-formats.at(format).folding-mark-2-pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
      }
      
      if hole-mark {
        // hole mark
        place(left + top, dx: 5mm, dy: 148.5mm, line(
          length: 4mm,
          stroke: 0.25pt + black
        ))
      }
    },
    
    footer-descent: 0%,
    footer: context {
      show: pad.with(top: 12pt, bottom: 12pt)
      
      let current-page = here().page()
      let page-count = counter(page).final().first()
      
      grid(
        columns: 1fr,
        rows: (0.65em, 1fr),
        row-gutter: 12pt,
        
        if page-count > 1 {
          if page-numbering == auto {
            if text.lang == "de" {
              align(right)[Seite #current-page von #page-count]
            } else {
              align(right)[Page #current-page of #page-count]
            }
          } else if type(page-numbering) == str {
            align(right, numbering(page-numbering, current-page, page-count))
          } else if type(page-numbering) == function {
            align(right, page-numbering(current-page, page-count))
          } else if page-numbering != none {
            panic("Unsupported option type!")
          }
        },
        
        if current-page == 1 {
          footer
        }
      )
    },
  )
  
  // Reverse the margin for the header, the address box and the information box
  pad(top: -margin.top, left: -margin.left, right: -margin.right, {
    grid(
      columns: 100%,
      rows: (letter-formats.at(format).header-size, 45mm),
      
      // Header box
      header,
      
      // Address / Information box
      pad(left: 20mm, right: 10mm, {
        grid(
          columns: (85mm, 75mm),
          rows: 45mm,
          column-gutter: 20mm,
          
          // Address box
          address-box,
          
          // Information box
          pad(top: 5mm, information-box)
        )
      }),
    )
  })

  v(12pt)

  // Reference signs
  if (reference-signs != none) and (reference-signs.len() > 0) {
    grid(
      // Total width: 175mm
      // Delimiter: 4.23mm
      // Cell width: 50mm - 4.23mm = 45.77mm
      
      columns: (45.77mm, 45.77mm, 45.77mm, 25mm),
      rows: 12pt * 2,
      gutter: 12pt,
      
      ..reference-signs.map(sign => {
        let (key, value) = sign
        
        text(size: 8pt, key)
        linebreak()
        text(size: 10pt, value)
      })
    )
  }
  
  // Add body.
  body
}

// ####################
// # Helper functions #
// ####################

/// Creates a simple header with a name, an address and extra information.
/// 
/// - name (content, none): Name of the sender
/// - address (content, none): Address of the sender
/// - extra (content, none): Extra information about the sender
#let header-simple(name, address, extra: none) = {
  set text(size: 10pt)

  if name != none {
    strong(name)
    linebreak()
  }
  
  if address != none {
    address
    linebreak()
  }

  if extra != none {
    extra
  }
}

/// Creates a simple sender box with a name and an address.
/// 
/// - name (content, none): Name of the sender
/// - address (content, none): Address of the sender
#let sender-box(name: none, address) = rect(width: 85mm, height: 5mm, stroke: none, inset: 0pt, {
  set text(size: 7pt)
  set align(horizon)
  
  pad(left: 5mm, underline(offset: 2pt, {
    if name != none {
      name
    }

    if (name != none) and (address != none) {
      ", "
    }

    if address != none {
      address
    }
  }))
})

/// Creates a simple annotations box.
/// 
/// - content (content, none): The content
#let annotations-box(content) = {
  set text(size: 7pt)
  set align(bottom)
  
  pad(left: 5mm, bottom: 2mm, content)
}

/// Creates a simple recipient box.
/// 
/// - content (content, none): The content
#let recipient-box(content) = {
  set text(size: 10pt)
  set align(top)
  
  pad(left: 5mm, content)
}

/// Creates a simple address box with 2 fields.
/// 
/// The width is is determined automatically. Row heights:
/// #table(
///   columns: 3cm,
///   rows: (17.7mm, 27.3mm),
///   stroke: 0.5pt + gray,
///   align: center + horizon,
///   
///   [sender\ 17.7mm],
///   [recipient\ 27.3mm],
/// )
/// 
/// See also: _address-tribox_
/// 
/// - sender (content, none): The sender box
/// - recipient (content, none): The recipient box
#let address-duobox(sender, recipient) = {
  grid(
    columns: 1,
    rows: (17.7mm, 27.3mm),
      
    sender,
    recipient,
  )
}

/// Creates a simple address box with 3 fields and optional repartitioning for a stamp.
/// 
/// The width is is determined automatically. Row heights:
/// #table(
///   columns: 2,
///   stroke: none,
///   align: center + horizon,
///   
///   text(weight: "semibold")[Without _stamp_],
///   text(weight: "semibold")[With _stamp_],
///   
///   table(
///     columns: 3cm,
///     rows: (5mm, 12.7mm, 27.3mm),
///     stroke: 0.5pt + gray,
///     align: center + horizon,
///     
///     [_sender_ 5mm],
///     [_annotations_\ 12.7mm],
///     [_recipient_\ 27.3mm],
///   ),
///   
///   table(
///     columns: 3cm,
///     rows: (5mm, 21.16mm, 18.84mm),
///     stroke: 0.5pt + gray,
///     align: center + horizon,
///     
///     [_sender_ 5mm],
///     [_stamp_ +\ _annotations_\ 21.16mm],
///     [_recipient_\ 18.84mm],
///   )
/// )
/// 
/// See also: _address-duobox_
/// 
/// - sender (content, none): The sender box
/// - annotations (content, none): The annotations box
/// - recipient (content, none): The recipient box
/// - stamp (boolean): Enable stamp repartitioning. If enabled, the annotations box and the recipient box divider is moved 8.46mm (about 2 lines) down.
#let address-tribox(sender, annotations, recipient, stamp: false) = {
  if stamp {
    grid(
      columns: 1,
      rows: (5mm, 12.7mm + (4.23mm * 2), 27.3mm - (4.23mm * 2)),
      
      sender,
      annotations,
      recipient,
    )
  } else {
    grid(
      columns: 1,
      rows: (5mm, 12.7mm, 27.3mm),
      
      sender,
      annotations,
      recipient,
    )
  }
}

// #################
// # Simple letter #
// #################

/// This function takes your whole document as its `body` and formats it as a simple letter.
/// 
/// The default font is set to _Source Sans Pro_ without hyphenation. The body text will be justified.
/// 
/// - format (string): The format of the letter, which decides the position of the folding marks and the size of the header.
///   #table(
///     columns: (1fr, 1fr, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Format],
///     text(weight: "semibold")[Folding marks],
///     text(weight: "semibold")[Header size],
///     
///     [DIN-5008-A], [87mm, 192mm],  [27mm],
///     [DIN-5008-B], [105mm, 210mm], [45mm],
///   )
/// 
/// - header (auto, content, none): The header that will be displayed at the top of the first page. If header is set to _auto_, a default header will be generaded instead.
/// - footer (content, none): The footer that will be displayed at the bottom of the first page. It automatically grows upwords depending on its body. Make sure to leave enough space in the page margins.
/// 
/// - folding-marks (boolean): The folding marks that will be displayed at the left margin.
/// - hole-mark (boolean): The hole mark that will be displayed at the left margin.
/// 
/// - sender (dictionary): The sender that will be displayed below the header on the left.
///   
///   The name and address fields must be strings (or none).
/// 
/// - recipient (content, none): The recipient that will be displayed below the annotations.
/// 
/// - stamp (boolean): This will increase the annotations box size is by two lines in order to provide more room for the postage stamp that will be displayed below the sender.
/// - annotations (content, none): The annotations box that will be displayed below the sender (or the stamp if enabled).
/// 
/// - information-box (content, none): The information box that will be displayed below below the header on the right.
/// - reference-signs (array, none): The reference signs that will be displayed below below the the address box. The array has to be a collection of tuples with 2 content elements.
///   
///   Example:
///   ```typ
///   (
///     ([Foo],   [bar]),
///     ([Hello], [World]),
///   )
///   ```
/// 
/// - date (content, none): The date that will be displayed on the right below the subject.
/// - subject (string, none): The subject line and the document title.
/// 
/// - page-numbering (auto, string, function, none): Defines the format of the page numbers.
///   #table(
///     columns: (auto, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Type], text(weight: "semibold")[Description],
///     [auto],     [Automatically determines the document language and chooses an appropriate translation.],
///     [string],   [A numbering pattern as specified by the official documentation of the #link("https://typst.app/docs/reference/model/numbering/", text(blue)[_numbering_]) function.],
///     [function], [
///       A function that returns the page number for each page.\
///       Parameters:
///       - current-page (integer)
///       - page-count (integer)
///       Return type: _content_
///     ],
///     [none],     [Disable page numbering.],
///   )
/// 
/// - margin (dictionary): The margin of the letter.
///   
///   The dictionary can contain the following fields: _left_, _right_, _top_, _bottom_.\
///   Missing fields will be set to the default. 
///   Note: There is no _rest_ field.
/// 
/// - font (string, array): Font used throughout the letter.
/// 
///   Keep in mind that some fonts may not be ideal for automated letter processing software
///   and #link("https://en.wikipedia.org/wiki/Optical_character_recognition", text(blue)[OCR]) may fail.
/// 
/// - body (content, none): The content of the letter
/// -> content
#let letter-simple(
  format: "DIN-5008-B",
  
  header: auto,
  footer: none,

  folding-marks: true,
  hole-mark: true,
  
  sender: (
    name: none,
    address: none,
    extra: none,
  ),
  
  recipient: none,

  stamp: false,
  annotations: none,
  
  information-box: none,
  reference-signs: none,
  
  date: none,
  subject: none,

  page-numbering: auto,

  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),

  font: "Source Sans Pro",

  body,
) = {
  margin = (
    left:   margin.at("left",   default: 25mm),
    right:  margin.at("right",  default: 20mm),
    top:    margin.at("top",    default: 20mm),
    bottom: margin.at("bottom", default: 20mm),
  )
  
  // Configure page and text properties.
  set document(
    title: subject,
    author: sender.name,
  )

  set text(font: font, hyphenate: false)

  // Create a simple header if there is none
  if header == auto {
    header = pad(
      left:   margin.left,
      right:  margin.right,
      top:    margin.top,
      bottom: 5mm,
      
      align(bottom + right, header-simple(
        sender.name,
        if sender.address != none {
          sender.address.split(", ").join(linebreak())
        },
        extra: sender.at("extra", default: none),
      ))
    )
  }

  let sender-box      = sender-box(name: sender.name, sender.address)
  let annotations-box = annotations-box(annotations)
  let recipient-box   = recipient-box(recipient)

  let address-box     = address-tribox(sender-box, annotations-box, recipient-box, stamp: stamp)
  if (annotations == none) and (stamp == false) {
    address-box = address-duobox(align(bottom, pad(bottom: 0.65em, sender-box)), recipient-box)
  }
  
  letter-generic(
    format: format,
    
    header: header,
    footer: footer,

    folding-marks: folding-marks,
    hole-mark: hole-mark,
    
    address-box:     address-box,
    information-box: information-box,

    reference-signs: reference-signs,

    page-numbering: page-numbering,
    
    {
      // Add the date line, if any.
      if date != none {
        align(right, date)
        v(0.65em)
      }
      
      // Add the subject line, if any.
      if subject != none {
        pad(right: 10%, strong(subject))
        v(0.65em)
      }
      
      set par(justify: true)
      body
    },

    margin: margin,
  )
}
