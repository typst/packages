#import "utils.typ": *

#let title-page(
  title: str,
  subtitle: str,
  authors: array,
  department: str,
  year: int,
  type: str,
  gu: bool,
) = {
  {
    set text(size: 14pt, hyphenate: false)
    set par(justify: false)
    
    align(center)[
      #smallcaps(large([#THESIS_TYPE, #year]))
    ]
  
    align(horizon + center)[
        #Large(weight: "bold", title)
        #if subtitle != "" {
          v(1cm)
          large(subtitle)
        }
        #v(1cm)
        #upper(authors.join(linebreak()))
    ]
    
    align(bottom + center)[
      #LOGO_VERTICAL
      #v(1cm)
      #department_of(department) \
      #smallcaps(CHALMERS) \
      #if gu {smallcaps(GOTHENBURG_UNIVERSITY); linebreak()}
      #GOTHENBURG_CITY, #year
    ]
  }
  pagebreak()
}

#let imprint(
  title: str,
  subtitle: str,
  program: str,
  authors: array,
  supervisors: array,
  advisor: str,
  examiner: str,
  co-examiner: str,
  department: str,
  cover-description: str,
  year: int,
  type: str,
  gu: bool,
) = {
  align(top + left)[
    #title \
    #subtitle \
    #upper[#authors.join(", ")] 
    #v(1em)
    $copyright$ #upper[#authors.join(", ")], #year.
    //#for author in authors {
    //  [$copyright$ ~ #upper(author), #year]
    //  linebreak()
    //}
    #v(1em)
    #for supervisor in supervisors [
      #tr("Handledare", "Supervisor"): #supervisor 
      #linebreak()
    ]
    #if advisor != "" { 
      [#tr("Rådgivare", "Advisor"): #advisor]
      linebreak()
    } 
    #if co-examiner != "" { 
      [#tr("Medrättande lärare", "Co-examiner"): #co-examiner]
      linebreak()
    } 
    #tr("Examinator", "Examiner"): #examiner
    #v(1em)
    #THESIS_TYPE, #year
    #linebreak()
    #department_of(department) \
    #CHALMERS \
    #if gu {GOTHENBURG_UNIVERSITY; linebreak()}
    SE-412 96 #GOTHENBURG_CITY \
    #tr("Telefon", "Telephone") +46 31 772 1000
    #align(bottom)[
      #if cover-description != "" [#tr("Omslag", "Cover"): #cover-description]
      #v(1em)
      #tr("Typsättning i", "Typeset in") Typst \
      #GOTHENBURG_CITY, #year
    ]
  ]
  pagebreak()
}

#let abstract(body, iso) = {
  set text(lang: iso)
  heading(tr("Sammanfattning", "Abstract"), level: 1, outlined: false)
  body
}

#let abstract-page(
  title: str,
  subtitle: str,
  authors: array,
  department: str,
  body: [],
  keywords: array,
  gu: bool,
) = {
  //set text(lang: "en")
  [
    #title \
    #if subtitle != "" {subtitle; linebreak()}
    #upper[#authors.join(", ")] \
    #department_of(department) \ 
    #CHALMERS #if gu {[#tr("och", "and") #GOTHENBURG_UNIVERSITY]}
  ]
  abstract(body, "en")
  if keywords.len() > 0 {
    align(bottom)[
      #tr("Nyckelord", "Keywords"): #keywords.join(", ")
    ]
  }
}

#let acknowledgments-page(
  body: str,
  authors: array,
) = {
  [
    #heading(tr("Författarnas tack", "Acknowledgments"), outlined: false)
    #body
    #v(1em)
    #align(right)[
      #box(width: 90%)[
        #authors.join(", "), #GOTHENBURG_CITY,~#datetime.today().display("[month repr:long] [year]")
      ]
    ]
  ]
  pagebreak()
}

#let preface-page(body: str) = {
  [
    #heading(tr("Förord", "Preface"), outlined: false)
    #body
  ]
  pagebreak()
}

#let abbreviations-list(list) = {
  let sorted-pairs = list.pairs().sorted(key: it => it.at(0))
  [
    #heading(tr("Förkortningslista", "List of Abbreviations"), outlined: false)
    #v(0.5em)
    #grid(
      columns: (1fr, 3fr),
      row-gutter: 0.65em,
      ..for (abbr, desc) in sorted-pairs {
        (h(0.5em) + abbr, desc)
      }
    )
  ]
}

#let nomenclature-list(list) = {
  let sorted-categories = list.pairs().sorted(key: it => it.at(0))
  [
    #heading(tr("Nomenklatur", "Nomenclature"), outlined: false)
    #v(0.5em)
    #for (category, entry) in sorted-categories [
      #let sorted-entries = entry.pairs().sorted(key: it => it.at(0))
      #heading(level: 2, category, outlined: false)
      #v(0.5em)
      #grid(
        columns: (1fr, 3fr),
        row-gutter: 0.65em,
        ..for (abbr, desc) in sorted-entries {
          (h(0.5em) + abbr, desc)
        }
      )
      #v(0.5em)
    ]
  ]
}