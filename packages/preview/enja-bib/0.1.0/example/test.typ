#import "@preview/enja-bib:0.1.0": *

#import bib-setting-jsme: *
#show: bib-init

#set text(font: ("Times New Roman", "Harano Aji Mincho"))

#heading(numbering: none)[引用例]

#table(
  columns: (auto, auto),
  [`@Reynolds:PhilTransRoySoc1883`],[@Reynolds:PhilTransRoySoc1883],
  [`#citet(<Matsukawa:ICFD2022>)`],[#citet(<Matsukawa:ICFD2022>)],
  [`#citep(<Matsukawa:ICFD2022>)`],[#citep(<Matsukawa:ICFD2022>)],
  [`#citen(<Matsukawa:ICFD2022>)`],[#citen(<Matsukawa:ICFD2022>)],
  [`#citefull(<Reynolds:PhilTransRoySoc1883>)`],[#citefull(<Reynolds:PhilTransRoySoc1883>)],
  [`@Reynolds:PhilTransRoySoc1883[Manual String]`],[@Reynolds:PhilTransRoySoc1883[Manual String]],
)


#block(width: 100%, stroke: black, inset: 10pt,[
```typst
#bibliography-list(
  title: [参考文献],
  ..bib-file(read("mybib_jp.bib")),
  ..bib-file(read("mybib_en.bib"))
)
```
]
)

#bibliography-list(
  title: [参考文献],
  ..bib-file(read("mybib_jp.bib")),
  ..bib-file(read("mybib_en.bib"))
)
