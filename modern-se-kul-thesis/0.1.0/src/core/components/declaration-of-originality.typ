#let insert-dec-of-orig(declaration-of-originality, lang:"en") = {
  if declaration-of-originality != none{
  heading(
    level: 1,
    numbering: none,
    outlined: false,
    if lang == "en" {
      "Declaration of Originality"
    } else {
      "Declaratie van originaliteit"
    }
  )
  text(style: "italic", declaration-of-originality.at(lang))
  }
}