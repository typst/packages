// Handles book numbering
#let numbering(
  pattern,
  part: none,
  chapter: none,
  default: "I.I.1.1.1.a",
) = (..level) => context {
  import "@preview/numbly:0.1.0": numbly
  import "orig.typ"
  
  if pattern == none {return none}
  
  let level = level.pos()
  let after-toc = query(selector(<toc:inserted>).before(here())) != ()
  let spacing = not after-toc and pattern.at(level.len() - 1, default: none) != ""
  let pattern = pattern
  let part = part
  let chapter = chapter
  
  if pattern.at(level.len() - 1, default: "") == none {return none}
  if type(pattern) == str {
    if not pattern.contains(regex("[{}]")) {
      return {
        orig.numbering(pattern, ..level)
        
        if spacing {h(0.3em)}
      }
    }
    
    pattern = (pattern,)
  }
  
  if after-toc {
    if part != none and pattern.len() >= 1 {
      pattern.at(0) = part + " " + pattern.at(0) // set part (level 1)
      
      if part == "" {pattern.at(0) = ""}
      if chapter != none and pattern.len() >= 2 {
        if chapter != "" {chapter += " "}
        
        pattern.at(1) = chapter + pattern.at(1) // set chapter (level 2)
      }
    }
    else if chapter != none and pattern.len() >= 1 {
      if chapter != "" {chapter += " "}
      
      pattern.at(0) = chapter + pattern.at(0) // set chapter (level 1)
    }
  }
  else {
    pattern = pattern.map(
      item => if type(item) == str { item.trim(regex("\n+")) }
    )
  }
  
  numbly(default: default, ..pattern)(..level)
  
  if spacing {h(0.3em)} // gap between numbering and title in TOC
}


// Generate #transl Fluent database for standard languages
#let std-langs() = {
  let database = (l10n: "ftl")
  let langs = (
    "en", "pt", "la", "zh", "hi", "es", "ar", "fr", 
    "bn", "ru", "ur", "id", "de", "ja", "it",
  )
  
  for lang in langs {
    database.insert(lang, read("l10n/" + lang + ".ftl"))
  }
  return database
}