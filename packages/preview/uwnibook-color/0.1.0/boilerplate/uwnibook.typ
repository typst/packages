///
/// this file is used to import and config packages
///

#import "@preview/uwnibook-color:0.1.0": *
#import "header_imgs/imgs.typ": imgs
#import "../documentation/my-preset.typ"

#let (
  template,
  titlepage,
  outline,
  mainbody,
  appendix,
  proposition,
  highlighteq,
  example,
  definition,
  proof,
  components,
  make-index,
  note,
  notefigure,
  wideblock,
  subheading,
) = config_uwni(
  /// ["en"|"zh"|"lzh"]
  preset: "zh",
  title: (
    en: [
      Uwni Book
    ],
    zh: [
      Uwni 書籍模板
    ],
  ),
  // author information
  author: (en: "Uwni", zh: "著者"),
  // author affiliation
  affiliation: [部門，機構],
  // report date
  date: datetime.today(),
  // set to true to enable draft watermark, so that you can prevent from submitting a draft version
  draft: false,
  // set to true to enable two-sided layout
  two_sided: true,
  // "modern"|"classic"
  title_style: "book",
  chap_imgs: imgs,
)
