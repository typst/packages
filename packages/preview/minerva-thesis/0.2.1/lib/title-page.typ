#import "states.typ": *

#let ugent-logo(language: "EN") = image("../img/logo_UGent_" + upper(language) + ".svg")
#let faculty-logo(faculty: none, language: "EN") = image("../img/logo_" + upper(faculty) + "_" + upper(language) + ".svg")

#let title-page(
  authors: auto,
  title: auto,
  supervisors: auto,
  multiple-supervisors: auto,
  counsellors: auto,
  multiple-counsellors: auto,
  date: auto,
  language: auto, // "EN" or "NL", case-insensitive
  faculty: auto, // faculty code, case-insensitive
  description: auto,
  additional-logo: none,
  ids: none, // ID(s) such as ISBN, NIR code, ... : single string/content or array
  font: auto,
  font-size: auto, 
  title-font-size: auto,
  author-font-size: auto,
  description-font-size: auto,
  supervisor-font-size: auto,
  date-font-size: auto
) = context{
  
  let the-authors= if authors==auto {thesis-authors.get()} else {authors}
  let the-title= if title==auto {thesis-title.get()} else {title}
  let the-description= if description==auto {thesis-description.get()} else {description}
  let the-date= if date==auto {thesis-date.get()} else {date}
  let the-language= if language==auto {thesis-language.get()} else {language}
  let the-faculty= if faculty==auto {thesis-faculty.get()} else {faculty}

  let the-supervisors= if supervisors==auto {thesis-supervisors.get()} else {supervisors}
  let the-multiple-supervisors= if multiple-supervisors==auto or type(multiple-supervisors)!=bool { 
    thesis-multiple-supervisors.get()
  } else {multiple-supervisors}
  
  let the-counsellors= if counsellors==auto {thesis-counsellors.get()} else {counsellors}
  let the-multiple-counsellors= if multiple-counsellors==auto or type(multiple-counsellors)!=bool { 
    thesis-multiple-counsellors.get()
  } else {multiple-counsellors}
  
  { set text(font: font) if font!=auto 
    set text(size: font-size) if font-size!=auto 
    
    let top-logo-height=2.8em // for faculty logo 
    let bottom-logo-height=48/22*top-logo-height  // for UGent logo ; the ratio 48/22 preserves the original height ratio of the logos; the text sizes in UGent logo and faculty logo are then equal  
  
    set image(height: top-logo-height)
    faculty-logo(faculty: the-faculty, language: the-language)

    v(2fr)
    
    text(size: if title-font-size==auto {1.8em} else {title-font-size} , weight: "bold", hyphenate: false, the-title)
    
    v(3em)
    
    align(right, { 
      set text(size: if author-font-size==auto {1.2em} else {author-font-size} , weight: "bold")
      if type(the-authors)==array {the-authors.join(", ", last: " and ")} else {the-authors}
    })
    
    v(6em)
    
    text(size: if description-font-size==auto {1em} else {description-font-size}, the-description)
    
    v(2em)
    
    {  
      set text(size:  if supervisor-font-size==auto {1em} else {supervisor-font-size})
      if the-supervisors!=none { 
        par({
          if the-multiple-supervisors [*Supervisors*] else [*Supervisor*] 
          linebreak()
          if type(the-supervisors)==array {the-supervisors.join(", ", last: " and ")} else {the-supervisors}
        })
      }
    
      if the-counsellors!=none { 
        par({
          if the-multiple-counsellors [*Counsellors*] else [*Counsellor*] 
          linebreak()
          if type(the-counsellors)==array {the-counsellors.join(", ", last: " and ")} else {the-counsellors}
        })
      }
    }
    
    v(5em)
    
    text(size: if date-font-size==auto {1.1em} else {date-font-size}, the-date)

    v(1fr)
    
    set box(baseline:50%)
    set image(height: bottom-logo-height)
    box(ugent-logo(language: the-language))
    if additional-logo!=none {
      let add-logo(logo)={
        set image(height: logo.height*bottom-logo-height)
        box(logo.image)
      }
      h(1fr)
      if type(additional-logo)==array {
        for logo in additional-logo {
          h(2em)
          add-logo(logo)
        }
      } else {add-logo(additional-logo)}
    }
  }
  
  pagebreak()

  v(1fr)

  if ids!=none {
    if type(ids)==array { for id in ids [#id \ ] } else [#ids]
  }
  pagebreak(weak: true, to: "odd")
}
