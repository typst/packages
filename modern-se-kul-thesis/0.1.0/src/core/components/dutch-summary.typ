
#let insert-dutch-summary(summary, lang: "nl") = {
  if summary != none and lang == "en"{
    heading(
      level: 1,
      numbering: none,
      outlined: true,
      "Samenvatting"
    )
    summary
  }else{
    if lang == "en"{
      page[
        #text(red, size: 5em)[#rotate(45deg)[placeholder]
        
        You need a dutch summary if you are writing an English thesis set `overrule-dutch-summary` to true if you want to remove this warning]
      ]
    }
  }
}