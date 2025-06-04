
///
/// this file is used to import and config packages
///

#import "@preview/uwnibook-color:0.1.0": *
#import "header_imgs/imgs.typ": imgs
#import "my-preset.typ"

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
  // ["en"|"ja"]
  preset: my-preset,
  title: (
    lzh: [
      樣本
    ],
  ),
  // author information
  author: (en: "Uwni", lzh: "枚鴉"),
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

#import "@preview/equate:0.3.0"
