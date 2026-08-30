#import "states.typ": *
#import "utils.typ": *
#import "main.typ": hide-page-number, split-locale, localise

#let ugent-logo(language: auto, ..args) = context{
  let the-language=upper(if language==auto{split-locale(auto).language} else {language})
  if the-language not in ("EN","NL") {the-language="EN"}
  image("../img/logo_UGent_"+the-language+".svg", ..args)
  }
#let faculty-icon(faculty, language: auto, ..args) = context{
  let the-language=upper(if language==auto{split-locale(auto).language} else {language})
  if the-language not in ("EN","NL") {the-language="EN"}  
  image("../img/icon_"+upper(faculty)+"_"+the-language+".svg", ..args)
  }

#let title-page(
  authors: auto,
  title: auto,
  supervisors: auto,
  multiple-supervisors: auto,
  counsellors: auto,
  multiple-counsellors: auto,
  date: auto,
  language: auto, // case-insensitive
  region: auto,
  faculty: auto, // faculty code, case-insensitive
  description: auto,
  additional-logo: none,
  ids: none, // ID(s) such as ISBN, NIR code, ... : single string/content or array
  terminology: auto,
  font: auto,
  font-size: auto, 
  title-font-size: auto,
  author-font-size: auto,
  description-font-size: auto,
  supervisor-font-size: auto,
  date-font-size: auto
) = context{

  hide-page-number
  
  
  let locale=split-locale(language, region: region)

  let the-localise=localise.with(locale: locale.locale)
  let the-terminology=the-localise(terminology-defaults.get())
  if type(terminology)==dictionary {the-terminology+=the-localise(terminology)}

  
  let the-authors=the-localise(if authors==auto {thesis-authors.get()} else {authors})
  let the-title=the-localise( if title==auto {thesis-title.get()} else {title})
  let the-description=the-localise(if description==auto {thesis-description.get()} else {description})
  let the-date= if date==auto {thesis-date.get()} else {date}
  let the-language=locale.language // if language==auto {thesis-language.get()} else {language}
  let the-faculty= if faculty==auto {thesis-faculty.get()} else {faculty}

  let the-supervisors=the-localise(if supervisors==auto {thesis-supervisors.get()} else {supervisors})
  let the-multiple-supervisors= if multiple-supervisors==auto or type(multiple-supervisors)!=bool { 
    thesis-multiple-supervisors.get()
  } else {multiple-supervisors}
  
  let the-counsellors=the-localise(if counsellors==auto {thesis-counsellors.get()} else {counsellors})
  let the-multiple-counsellors= if multiple-counsellors==auto or type(multiple-counsellors)!=bool { 
    thesis-multiple-counsellors.get()
  } else {multiple-counsellors}
  
  
  { set text(font: font) if font!=auto 
    set text(size: font-size) if font-size!=auto 
    
    set text(
      lang: locale.language, 
      region: locale.region
    ) 
    
    pagebreak(to: "odd", weak: true)
    
    if the-terminology.at("title-page", default: none)!=none {
      show heading: (it) => {}
      set heading(outlined: false, bookmarked: true)
      [= #the-terminology.title-page]
    }
    
    let top-logo-height=2.8em // for faculty logo 
    let bottom-logo-height=48/22*top-logo-height  // for UGent logo ; the ratio 48/22 preserves the original height ratio of the logos; the text sizes in UGent logo and faculty logo are then equal  
  
    faculty-icon(the-faculty, language: the-language, height: top-logo-height)

    v(2fr)
    
    text(size: if title-font-size==auto {1.8em} else {title-font-size} , weight: "bold", hyphenate: false, the-title)
    
    v(3em)
    
    align(right, { 
      set text(size: if author-font-size==auto {1.2em} else {author-font-size} , weight: "bold")
      if type(the-authors)==array {the-authors.join(", ", last: get-prefix-last(the-terminology,the-authors.len()))} else {the-authors}
    })
    
    v(6em)
    
    text(size: if description-font-size==auto {1em} else {description-font-size}, the-description)
    
    v(2em)
    
    {  
      set text(size:  if supervisor-font-size==auto {1em} else {supervisor-font-size})
      if the-supervisors!=none { 
        par({
          text(weight: "bold", if the-multiple-supervisors {the-terminology.supervisor.at(1)} else {the-terminology.supervisor.at(0)}) 
          linebreak()
          if type(the-supervisors)==array {the-supervisors.join(", ", last: get-prefix-last(the-terminology,the-supervisors.len()))} else {the-supervisors}
        })
      }
    
      if the-counsellors!=none { 
        par({
          text(weight:"bold", if the-multiple-counsellors {the-terminology.counsellor.at(1)} else {the-terminology.counsellor.at(0)}) 
          linebreak()
          if type(the-counsellors)==array {the-counsellors.join(", ", last: get-prefix-last(the-terminology,the-counsellors.len()))} else {the-counsellors}
        })
      }
    }
    
    v(5em)
    
    text(size: if date-font-size==auto {1.1em} else {date-font-size}, the-date)

    v(1fr)
    
    set box(baseline:50%)
    box(ugent-logo(language: the-language, height: bottom-logo-height))
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

  hide-page-number
  
  if ids!=none {
    v(1fr)
    if type(ids)==array { for id in ids [#id \ ] } else [#ids]
  }
//   pagebreak(to: "odd", weak: true)
}
