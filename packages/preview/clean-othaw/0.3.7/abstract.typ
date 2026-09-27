#import "locale.typ": *

#let abstract(
  authors,
  title,
  date,
  language,
  many-authors,
  at-university,
  university,
  date-format,
  type-of-thesis,
  course-of-studies,
  abstract-text,
  abstract-content,
  supervisor,
  keywords,
  formalities-in-frontmatter,
) = {
  heading(level: 1, type-of-thesis+" "+ABSTRACT.at(language),outlined:(not formalities-in-frontmatter))
  v(1em)

  if (abstract-content != none) {
    abstract-content
  } else {
    if (authors.len() == 1) {
      par(justify:true, DECLARATION_OF_AUTHORSHIP_SECTION_A_SINGLE.at(language)+" "+authors.first().name)


    } else {
    let author-list = ""
    for (author) in authors {
      author-list = author-list + author.name
      if (not (author==authors.last())){author-list=author-list+", "}
    }
      par(justify:true, DECLARATION_OF_AUTHORSHIP_SECTION_A_PLURAL.at(language)+" "+author-list)

    }
    par(justify:true, DECLARATION_OF_AUTHORSHIP_SECTION_B.at(language)+" "+authors.first().course-of-studies)
    v(1em)
    par(justify:true, ABSTRACT_SUPERVISOR.at(language)+" "+supervisor.university-first)
    if(at-university){
      par(justify:true, ABSTRACT_CONDUCTION.at(language)+" "+university)
    }else{
      par(justify:true, ABSTRACT_CONDUCTION.at(language)+" "+authors.first().company.name+", "+authors.first().company.city)
      par(justify:true,TITLEPAGE_COMPANY_SUPERVISOR.at(language)+" "+ supervisor.company)
    }
    par(justify:true, ABSTRACT_DATE_1.at(language)+" "+date.at(0).display(date-format) + " "+ABSTRACT_DATE_2.at(language)+" "+date.at(1).display(date-format))

    v(1em)
    line(length: 100%)
    par(justify:true,ABSTRACT_TITLE.at(language)+" "+ title)
    v(1em)
    line(length: 100%)
    text(ABSTRACT.at(language)+": ")
    linebreak()
    text(abstract-text)
    par(ABSTRACT_KEYWORDS.at(language)+" "+keywords)
  }
}
