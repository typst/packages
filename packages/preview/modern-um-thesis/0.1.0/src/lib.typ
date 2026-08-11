#import "@preview/hallon:0.1.2" as hallon: subfigure
#import "@preview/theorion:0.4.0": *
#import "@preview/unify:0.7.1": *
#import "layouts/appendix.typ": appendix
#import "layouts/doc.typ": doc
#import "layouts/frontmatter.typ": frontmatter
#import "layouts/mainmatter.typ": mainmatter
#import "pages/abstract.typ": abstract
#import "pages/cover-ms.typ": cover-ms
#import "pages/cover-phd.typ": cover-phd
#import "pages/declare-ms.typ": declare-ms
#import "pages/declare-phd.typ": declare-phd
#import "pages/outline.typ": outline-image, outline-table, outline-table-image
#import "utils/line.typ": toprule, midrule, bottomrule
#import "utils/symbols.typ": *

/// All functions and variables to be used in the Typst thesis template for University of Macau.
///
/// -> dictionary
#let documentclass(
  /// Type of thesis
  ///
  /// -> "doctor" | "master" | "bachelor"
  doctype: "doctor",
  /// Date of submission
  ///
  /// -> datetime
  date: datetime.today(),
  /// Language of the thesis
  ///
  /// Master's theses must be written in English.
  ///
  /// If you choose "master" doctype, DO NOT select the other 2 languages.
  ///
  /// -> "en" | "zh" | "pt"
  lang: "en",
  /// Enable double-sided printing
  ///
  /// For Doctoral theses, double-sided printing is required (i.e. please set to true).
  ///
  /// For Master's and Bachelor's theses though, single-sided printing is strongly recommended, but double-sided printing is still allowed.
  ///
  /// -> bool
  double-sided: true,
  /// Add margins to binding side for printing
  ///
  /// In most cases, this should be set to true.
  ///
  /// -> bool
  print: true,
  /// Thesis information, including:
  ///
  /// `title-en`: Title of Thesis, *required*\
  /// `title-zh`: 论文标题\
  /// `title-pt`: Título da Tese\
  /// `author-en`: Name of Author, *required*\
  /// `author-zh`: 作者姓名\
  /// `author-pt`: Nome do Autor\
  /// `degree-en`: Degree Title, *required*\
  /// `degree-zh`: 学位名称\
  /// `degree-pt`: Doutorado\
  /// `academic-unit-en`: Name of Academic Unit, *required*\
  /// `academic-unit-zh`: 学术单位名称\
  /// `academic-unit-pt`: Nome da Unidade Acadêmica\
  /// `supervisor-en`: Name of Supervisor, *required*\
  /// `supervisor-zh`: 导师姓名\
  /// `supervisor-pt`: Nome do Supervisor\
  /// `co_supervisor-en`: Name of Co-Supervisor\
  /// `co_supervisor-zh`: 共同导师姓名\
  /// `co_supervisor-pt`: Nome do Co-Supervisor\
  /// `department-en`: Name of Department\
  /// `department-zh`: 系名称\
  /// `department-pt`: Nome do Departamento\
  ///
  /// Apart from all *required* entries above, if you choose a language other than "en", you must also provide translations for all *required* entries in that language.
  ///
  /// -> dictionary
  info: (:),
) = {
  if not ("doctor", "master", "bachelor").contains(doctype) {
    panic("Invalid document type. Please select one of the following document types: doctor, master, bachelor.")
  }
  if not ("en", "zh", "pt").contains(lang) {
    panic("Invalid language. Please select one of the following languages: en, zh, pt.")
  }

  return (
    // Metadata
    doctype: doctype,
    date: date,
    lang: lang,
    double-sided: double-sided,
    print: print,
    info: info,
    // Layouts
    doc: (..args) => {
      doc(
        ..args,
        doctype: doctype,
        double-sided: double-sided,
        print: print,
        info: info + args.named().at("info", default: (:)),
      )
    },
    frontmatter: (..args) => {
      frontmatter(
        ..args,
        doctype: doctype,
        lang: lang,
      )
    },
    mainmatter: (..args) => {
      mainmatter(
        ..args,
        doctype: doctype,
        lang: lang,
      )
    },
    appendix: (..args) => {
      appendix(
        ..args,
        doctype: doctype,
        lang: lang,
      )
    },
    // Pages
    abstract: (..args) => {
      abstract(
        ..args,
        doctype: doctype,
        lang: lang,
        double-sided: double-sided,
        info: info + args.named().at("info", default: (:)),
      )
    },
    cover: (..args) => {
      if doctype == "doctor" {
        cover-phd(
          ..args,
          lang: lang,
          info: info + args.named().at("info", default: (:)),
          date: date,
        )
      } else if doctype == "master" {
        cover-ms(
          ..args,
          date: date,
          double-sided: double-sided,
          info: info + args.named().at("info", default: (:)),
        )
      }
    },
    declare: (..args) => {
      if doctype == "doctor" {
        declare-phd(
          ..args,
          lang: lang,
          double-sided: double-sided,
        )
      } else if doctype == "master" {
        declare-ms(
          ..args,
          lang: lang,
          double-sided: double-sided,
        )
      }
    },
    outline-image: (..args) => {
      outline-image(
        ..args,
        lang: lang,
      )
    },
    outline-table: (..args) => {
      outline-table(
        ..args,
        lang: lang,
      )
    },
    outline-table-image: (..args) => {
      outline-table-image(
        ..args,
        lang: lang,
      )
    },
  )
}
