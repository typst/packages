#import "../includes.typ" as inc
#import "/isc_templates.typ" as isc

#let cover_page(
  title: "Life, the Universe and Everything",
  summary: "",
  content: none,
  language: none, // Valid values are en, fr
  authors: "Stormy Peters",
  picture: none, // [Optional], put none if not used
  permanent-email: "", // [Optional], put none if not used
  video-url: none, // Link to the video, if any
  supervisors: "",
  expert: "Dr Grace Hopper", // Optional, use none if not needed
  academic-year: "2025-2026", // Optional, use none if not needed
  is-executive-summary: true, // This is an executive summary, not a full thesis
  school: "Haute École d'Ingénierie de Sion",
  programme: "Informatique et Systèmes de communication (ISC)",
  keywords: ("engineering", "data", "machine learning", "meteorology"), // Some keywords related to your thesis
  major: "Data engineering", // "Software engineering", "Networks and systems", "Embedded systems", "Computer security", "Data engineering""
  bind: none, // Bind the left side of the page
  footer: none,
  font: none,  
) = {

  let i18n = isc.i18n.with(extra-i18n: none, language)
  let hei_color = color.rgb("#d41367") // HEI color

  if(bind == none){
    bind = left
  }

  let marg = if(bind == left) {
      (left: 1.5cm, right: 1cm, bottom: 1.3cm, top: 1.3cm)}
    else{
      (left: 1cm, right: 1.5cm, bottom: 1.3cm, top: 1.3cm)}    

  // Executive summary specific settings
  set page(
    margin: marg, // Binding inside
    paper: "a4",
    footer: footer
  )

  // Make the caption for the executive summary 
  set figure(numbering: none, supplement: none)
  set heading(numbering: none)
  
  show figure.caption: set text(8pt) // Smaller font size
  show figure.caption: emph // Use italics
  set figure.caption(separator: " - ") // With a nice separator  

  let colon = if language == "fr" { " : " } else { ": " }
  set text(font: font, size: 8.5pt)

  set par(leading: 0.4em)

  let title_block = block(align(horizon, text(title, size: 22pt, weight: "bold")), fill: none, width: if video-url != none {100%} else {100%}, spacing: 0em, height: 6em)  

  let author-text = if(permanent-email != none and permanent-email != "") {
    text(authors + " | " + permanent-email, size: 14pt, fill: hei_color)
  } else {
    text(authors, size: 14pt, fill: hei_color)
  }

  title_block
  v(0.5em)
  text(author-text, size: 14pt)

  set par(leading: 0.6em)

  // Title etc.
  stack(
    // Author
    stack(spacing: 1em, if (supervisors != none) {
      text(i18n("programme-title")) + text(colon + programme + " | " + major, style: "italic")
      linebreak()

      if type(supervisors) != array {
        text(i18n("supervising-examiner") + colon + supervisors, style: "italic")
      } else {
        if (supervisors.len() == 1) {
          text(i18n("supervising-examiner") + colon + text(supervisors.first(), style: "italic"))
        }
        if (supervisors.len() > 1) {
          text(i18n("supervising-examiner") + colon + text(supervisors.first(), style: "italic") + ", ")
          text(lower(i18n("supervising-second-examiner")) + colon + text(supervisors.at(1), style: "italic"))
        }
        if expert != none {
          linebreak()
          text(i18n("supervising-expert") + colon + text(expert, style: "italic"))
        }
      }
    }, 
    v(1.3em), 
    line(start: (0pt, 0pt), length: 25pt, stroke: 1mm),     
    ),
  )

  v(-0.5em)

  if (summary.len() == 0) {
    panic("You must provide a summary for the executive summary cover page.")
  }

  if (summary.len() > 375) {
    panic("The summary must be less than 375 characters long. Currently it is " + str(summary.len()) + " characters long.")
  }

  block(align(horizon, text(summary, fill: hei_color, size: 14pt)), fill: none, height: 3cm)

  // v(.5em)

  // set rect(
  //   inset: 5pt,
  //   fill: rgb("#eff0f5"),
  //   width: 100%,
  // )

  set rect(
    inset: 0pt,
    stroke: none,
    fill: none,
    width: 100%
  )

  // The main content of the executive summary
  let student-content = rect[#columns(2, gutter: 9pt, content)]  
  
  let w = 30mm
  let h = w * 9 / 6.5

  show heading: set text(size: 10pt, weight: "bold", fill: hei_color)

  let student-picture = [
    #{
      // Make local rule for student photograph
      set image(
        fit: "cover",
        width: 100%,
        height: 100%
      )

      grid.cell(      
        colspan: 1,
        stack(     
          spacing: 0.5em, 
          box(
            clip: true,
            stroke: stroke(paint: color.luma(40%), thickness: .2pt, cap: "round"),
            radius: 1pt,
            picture,
            width: w,
            height: h
          ),        
          align(bind, text(authors, size: 7pt, fill: hei_color)),
          // align(right)[#text(permanent-email, size: 6pt)],
          )
      )
    }
  ]
  
  // How do we layout the content, depending on the presence of a picture and binding
  let layout = if(picture != none and bind == left) {(5fr, 1fr)}
               else if (picture != none and bind == right) {(1fr, 5fr)}
               else {(1fr)}  

  let content = if(bind == left){(student-content, student-picture)} else{(student-picture, student-content)}

  block(
    height: 1fr,
    grid(
      columns: layout, // If no picture, use one column
      rows: (auto),
      gutter:15pt,
      ..content
    ) 
  )
  
  if(video-url != none) {  
    // QR code generation
    import "@preview/tiaoma:0.3.0"

    place(
      top+right,
      float: false,        
      dx: 0mm,
      dy: 25mm,
      clearance: 0em,
      // Put it in a box to be resized
      stack(
        spacing: 0.5em,                
        tiaoma.barcode(video-url, "QRCode", options: (            
            scale: 1.0,
            fg-color: black,
            bg-color: white,
            output-options: (
              barcode-dotty-mode: false
            ),
            dot-size: 1.0,
        )),        
        align(center)[#text("Video", size: 8pt)],
      )
    )
  }


}
