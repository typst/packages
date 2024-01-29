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
#let letter_formats = (
  "DIN-5008-A": (
    folding_mark_1_pos: 87mm,
    folding_mark_2_pos: 87mm + 105mm,
    header_size: 27mm,
  ),
  
  "DIN-5008-B": (
    folding_mark_1_pos: 105mm,
    folding_mark_2_pos: 105mm + 105mm,
    header_size: 45mm,
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
/// - folding_marks (boolean): The folding marks that will be displayed at the left margin.
/// - hole_mark (boolean): The hole mark that will be displayed at the left margin.
/// 
/// - address_box (content, none): The letter's address box, which is displayed below the header on the left.
/// 
/// - information_box (content, none): The information box that will be displayed below below the header on the right.
/// - reference_signs (array, none): The reference signs that will be displayed below below the the address box. The array has to be a collection of tuples with 2 content elements.
///   
///   Example:
///   ```typ
///   (
///     ([Foo],   [bar]),
///     ([Hello], [World]),
///   )
///   ```
/// 
/// - page_numbering (string, function, none): Defines the format of the page numbers.
///   #table(
///     columns: (auto, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Type], text(weight: "semibold")[Description],
///     [string],   [A numbering pattern as specified by the official documentation of the #link("https://typst.app/docs/reference/meta/numbering/", text(blue)[_numbering_]) function.],
///     [function], [
///       A function that returns the page number for each page.\
///       Parameters:
///       - current_page (integer)
///       - page_count (integer)
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
#let letter_generic(
  format: "DIN-5008-B",
  
  header: none,
  footer: none,
  
  folding_marks: true,
  hole_mark: true,
  
  address_box: none,
  information_box: none,
  
  reference_signs: none,
  
  page_numbering: (current_page, page_count) => {
    "Page " + str(current_page) + " of " + str(page_count)
  },

  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  
  body,
) = {
  if not letter_formats.keys().contains(format) {
    panic("Invalid letter format! Options: " + letter_formats.keys().join(", "))
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
      if folding_marks {
        // folding mark 1
        place(top + left, dx: 5mm, dy: letter_formats.at(format).folding_mark_1_pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
        
        // folding mark 2
        place(top + left, dx: 5mm, dy: letter_formats.at(format).folding_mark_2_pos, line(
            length: 2.5mm,
            stroke: 0.25pt + black
        ))
      }
      
      if hole_mark {
        // hole mark
        place(left + top, dx: 5mm, dy: 148.5mm, line(
          length: 4mm,
          stroke: 0.25pt + black
        ))
      }
    },
    
    footer-descent: 0%,
    footer: locate(loc => {
      show: pad.with(top: 12pt, bottom: 12pt)
      
      let current_page = loc.page()
      let page_count = counter(page).final(loc).at(0)
      
      grid(
        columns: 1fr,
        rows: (0.65em, 1fr),
        row-gutter: 12pt,
        
        if page_count > 1 {
          align(right, page_numbering(current_page, page_count))
        },
        
        if current_page == 1 {
          footer
        }
      )
    }),
  )
  
  // Reverse the margin for the header, the address box and the information box
  pad(top: -margin.top, left: -margin.left, right: -margin.right, {
    grid(
      columns: 100%,
      rows: (letter_formats.at(format).header_size, 45mm),
      
      // Header box
      header,
      
      // Address / Information box
      pad(left: 20mm, right: 10mm, {
        grid(
          columns: (85mm, 75mm),
          rows: 45mm,
          column-gutter: 20mm,
          
          // Address box
          address_box,
          
          // Information box
          pad(top: 5mm, information_box)
        )
      }),
    )
  })

  v(12pt)

  // Reference signs
  if (reference_signs != none) and (reference_signs.len() > 0) {
    grid(
      // Total width: 175mm
      // Delimiter: 4.23mm
      // Cell width: 50mm - 4.23mm = 45.77mm
      
      columns: (45.77mm, 45.77mm, 45.77mm, 25mm),
      rows: 12pt * 2,
      gutter: 12pt,
      
      ..reference_signs.map(sign => {
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
#let header_simple(name, address, extra: none) = {
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
#let sender_box(name: none, address) = rect(width: 85mm, height: 5mm, stroke: none, inset: 0pt, {
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
#let annotations_box(content) = {
  set text(size: 7pt)
  set align(bottom)
  
  pad(left: 5mm, bottom: 2mm, content)
}

/// Creates a simple recipient box.
/// 
/// - content (content, none): The content
#let recipient_box(content) = {
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
/// See also: _address_tribox_
/// 
/// - sender (content, none): The sender box
/// - recipient (content, none): The recipient box
#let address_duobox(sender, recipient) = {
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
/// See also: _address_duobox_
/// 
/// - sender (content, none): The sender box
/// - annotations (content, none): The annotations box
/// - recipient (content, none): The recipient box
/// - stamp (boolean): Enable stamp repartitioning. If enabled, the annotations box and the recipient box divider is moved 8.46mm (about 2 lines) down.
#let address_tribox(sender, annotations, recipient, stamp: false) = {
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
/// Font is set to _Source Sans Pro_ without hyphenation.
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
/// - header (content, none): The header that will be displayed at the top of the first page. If header is set to _none_, a default header will be generaded instead.
/// - footer (content, none): The footer that will be displayed at the bottom of the first page. It automatically grows upwords depending on its body. Make sure to leave enough space in the page margins.
/// 
/// - folding_marks (boolean): The folding marks that will be displayed at the left margin.
/// - hole_mark (boolean): The hole mark that will be displayed at the left margin.
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
/// - information_box (content, none): The information box that will be displayed below below the header on the right.
/// - reference_signs (array, none): The reference signs that will be displayed below below the the address box. The array has to be a collection of tuples with 2 content elements.
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
/// - page_numbering (string, function, none): Defines the format of the page numbers.
///   #table(
///     columns: (auto, 1fr),
///     stroke: 0.5pt + gray,
///     
///     text(weight: "semibold")[Type], text(weight: "semibold")[Description],
///     [string],   [A numbering pattern as specified by the official documentation of the #link("https://typst.app/docs/reference/meta/numbering/", text(blue)[_numbering_]) function.],
///     [function], [
///       A function that returns the page number for each page.\
///       Parameters:
///       - current_page (integer)
///       - page_count (integer)
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
#let letter_simple(
  format: "DIN-5008-B",
  
  header: none,
  footer: none,

  folding_marks: true,
  hole_mark: true,
  
  sender: (
    name: none,
    address: none,
    extra: none,
  ),
  
  recipient: none,

  stamp: false,
  annotations: none,
  
  information_box: none,
  reference_signs: none,
  
  date: none,
  subject: none,

  page_numbering: (current_page, page_count) => {
    "Page " + str(current_page) + " of " + str(page_count)
  },

  margin: (
    left:   25mm,
    right:  20mm,
    top:    20mm,
    bottom: 20mm,
  ),
  
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

  set text(font: "Source Sans Pro", hyphenate: false)

  // Create a simple header if there is none
  if header == none {
    header = pad(
      left: margin.left,
      right: margin.right,
      top: margin.top,
      bottom: 5mm,
      
      align(bottom + right, header_simple(
        sender.name,
        if sender.address != none {
          sender.address.split(", ").join(linebreak())
        } else {
          "lul?"
        },
        extra: sender.at("extra", default: none),
      ))
    )
  }

  let sender_box      = sender_box(name: sender.name, sender.address)
  let annotations_box = annotations_box(annotations)
  let recipient_box   = recipient_box(recipient)

  let address_box     = address_tribox(sender_box, annotations_box, recipient_box, stamp: stamp)
  if annotations == none and stamp == false {
    address_box = address_duobox(align(bottom, pad(bottom: 0.65em, sender_box)), recipient_box)
  }
  
  letter_generic(
    format: format,
    
    header: header,
    footer: footer,

    folding_marks: folding_marks,
    hole_mark: hole_mark,
    
    address_box:     address_box,
    information_box: information_box,

    reference_signs: reference_signs,

    page_numbering: page_numbering,
    
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
