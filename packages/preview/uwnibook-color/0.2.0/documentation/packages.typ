
///
/// this file is used to import and config packages
///

#import "@preview/uwnibook-color:0.2.0": *
#import "header_imgs/imgs.typ": imgs
#import "my-preset.typ"

#let (
  template,
  preamble,
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
) = config-uwni(
  // ["en"|"ja"]
  preset: my-preset,
  title: (
    lzh: [
      uwnibook Color 樣本
    ],
  ),
  // author information
  author: (en: "Uwni", lzh: "枚鴉"),
  // report date
  date: datetime.today(),
  // set to true to enable draft watermark, so that you can prevent from submitting a draft version
  draft: false,
  // "modern"|"classic"
  title-style: "book",
  chap-imgs: imgs,
)
