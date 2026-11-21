#import "pages/0_title.typ": template_title 
#import "pages/1_declaration_of_originality.typ": originality_sign
#import "pages/2_acknowledgements.typ": gratitude
#import "pages/3_abstract.typ": abstract
#import "pages/last_ai.typ": ai
#import "helpers.typ": *

#let print_outline_images(title: "Seznam obrázků") = {
  outline(
  title: title,
  target: figure.where(kind: image)
  )
  pagebreak()
}

#let print_outline_code(title: "Seznam kódů", identifier: "code") = {
  outline(
    title: title,
    target: figure.where(kind: identifier)
  )
  pagebreak()
}

#let print_bibliography(bib_path: "bib/bibliography.bib",title: "Seznam použité literatury", list_all: true) = {
  bibliography(
    bib_path,
    title: title,
    style: "bib/iso-690-2022-ciselne-odkazy-ntk.csl",
    full: list_all,
  )
  pagebreak()
}

#let show-numbers = state("show-numbers", false)

//Template function, sets all the setting for the document
#let template_conf(
  vars: (
    Title: "Název práce v češtině",
    TitleEN: "Title of the thesis in english",
    Author: "Autor práce",
    StudyPrograme: "Studijní program",
    StudyField: "Studijní obor",
    Department: "Název katedry",
    Supervisor: "Vedoucí práce včetně titulů",
    Year: datetime.today().display("[year]"),
    Date: datetime_today_translated(),
    Keywords: "Klíčová, slova, oddělená, čárkou",
    KeywordsEN: "Key, words, separated, by, commas",
    Acknowledgements: ([Poděkování_1],[Poděkování_2], [...]),
  ),
  list_include_settings: (
    list_images_show: true,
    list_images_title: "Seznam obrázků",
    list_code_show: true,
    list_code_title: "Seznam kódů",
    list_code_identifier: "code",
  ),
  doc,
  ) = {
    set document(title: vars.Title, author: vars.Author, keywords: vars.Keywords,)

    set page(
      paper: "a4",
      margin: (
        top:25mm,
        bottom:30mm,
        left:30mm,
        right:25mm,
      ),
      numbering: "1",
      number-align: center,
      footer: context {
        if show-numbers
        .at(here()){
          align(center, counter(page).display("1"))
        } else {
          none
        }
      },
    )
    set text(
      font: "New Computer Modern",
      size: 12pt,
      weight: "regular",
      region: "CZ",
      lang: "cs",
    )
    set par(
      justify: true,
      leading: 1.5em,
      spacing: 5mm,

    )
    show footnote.entry: set text(size: 10pt)
    set heading(
      numbering: "1.1.1"
    )

    //This adds more spacing after heading, this is used for cleaner look of the text
    //Found at https://forum.typst.app/t/how-to-add-spacing-around-headings-but-not-between-headings/5967
    show heading: it => {
    // Clever trick to reduce spacing between consecutive headings
    // See https://github.com/typst/typst/issues/2953
    let previous_headings = query(selector(heading).before(here(), inclusive: false))
    if previous_headings.len() > 0 {
      let prev_loc = previous_headings.last().location().position()
      let it_loc = it.location().position()
      if (it_loc.page == prev_loc.page and it_loc.x == prev_loc.x and it_loc.y - prev_loc.y < 60pt) { // threshold
        v(-1.5em) // amount to reduce spacing, could make this dependent on it.level
      }
      else {}
    }
    [#v(1em) #it #v(0.5em)]
  }

  let tableofcontents() = {     
  outline()
  pagebreak()
  }
    
  template_title(vars)
  originality_sign(vars)
  gratitude(vars)
  abstract(vars)
  tableofcontents()

  show-numbers.update(true)
  doc

  //print_bibliography(bib_path: list_include_settings.bib_path, title: list_include_settings.bib_title, list_all: list_include_settings.bib_list_all)
  if list_include_settings.list_images_show == true {
  print_outline_images(title: list_include_settings.list_images_title)    
  }
  
  if list_include_settings.list_code_show == true {
  print_outline_code(title: list_include_settings.list_code_title, identifier: list_include_settings.list_code_identifier)
  }

  ai()


}


