#import "@preview/cuni-thesis:0.1.0": template_conf, datetime_today_translated

//Calling template function to apply to document
#show: template_conf.with(vars: (
    Title: "Název práce v češtině",
    TitleEN: "Title of the thesis in english",
    Author: "Autor práce",
    StudyPrograme: "Studijní program",
    StudyField: "Studijní obor",
    Department: "Název katedry",
    Supervisor: "Vedoucí práce včetně titulů",
    // Rok odevzdání lze ho napsat nebo načíst automaticky při kompilaci ["2026"/datetime.today().display("[year]")]
    Year: datetime.today().display("[year]"),
    // Datum odevzdání lze ho napsat nebo načíst automaticky při kompilaci ["13. března"/datetime_today_translated()]
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
  ),)

//These are only example files, remove these or comment them out with //
#include "chapters/Introduction.typ"
#include "chapters/lorem.typ" 
#include "chapters/ipsum.typ"
#include "chapters/Conclusion.typ"

//paste your chapters here #include "chapters/<your-chapter-name>.typ>"
//

#bibliography(
  "bib/bibliography.bib",
  title: "Seznam použité literatury",
  style: "bib/iso-690-2022-ciselne-odkazy-ntk.csl",
  full: true
  )
#pagebreak()