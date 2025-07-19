#let UGentlogo(language: "EN") = image(
  "../img/logo_UGent_" + upper(language) + ".svg",
  height: 21mm,
)
#let facultylogo(faculty: none, language: "EN") = image(
  "../img/logo_" + upper(faculty) + "_" + upper(language) + ".svg",
  height: 10mm,
)

#let titlepage(
  title: none,
  author: none,
  supervisors: none,
  counsellors: none,
  supervisor: none,
  counsellor: none,
  date: none,
  language: "EN", // "EN" or "NL", case-insensitive
  faculty: none, // faculty code, case-insensitive
  description: none,
  ids: none, // ID(s) such as ISBN, NIR code, ... : single string/content or array
  font: auto,
  fontsize: auto
) = {

  {
    set text(font: font) if font!=auto 
    set text(size: fontsize) if fontsize!=auto 
  
    facultylogo(faculty: faculty, language: language)

    v(2fr)

    text(size: 1.8em, weight: "bold", title)
    
    v(3em)
    
    align(right, text(size: 1.2em, weight: "bold", author))
    
    v(6em)
    
    [#description]

    v(2em)
    
    if supervisors!=none { 
      par({
      [*Supervisors*]
      linebreak()
      supervisors
      })
    } else if supervisor!=none { 
      par({
      [*Supervisor*]
      linebreak()
      supervisor
      })
    }
    
    if counsellors!=none { 
      par({
      [*Counsellors*] 
      linebreak()
      counsellors
      })
    } else if counsellor!=none { 
      par({
      [*Counsellor*] 
      linebreak()
      counsellor
      })
    }

    v(5em)
    
    text(size: 1.1em, date)

    v(1fr)

    UGentlogo(language: language)
  }
  
  pagebreak()

  v(1fr)

  if type(ids) == array { for id in ids [#id \ ] } else [#ids]
  
  pagebreak(weak: true, to: "odd")
}
