#import "../external.typ": transl
#import "@preview/t4t:0.4.2": get // use get.text[stuff]

#let capitalize(body) = {
  [#upper(body.slice(0, 1))#body.slice(1)]
}

#let tr-wrap(word, t, comparison-list) = {
  if lower(word) in comparison-list {
    return [#transl(word, t: t)]
  }
  return [#capitalize(word)]
}

#let translate-top-level-word-if-possible(word, comparison-list) = {
  if word in comparison-list{
    return capitalize(get.text(transl(word, mode: str)))
  }

  return capitalize(word)
}

#let translate-t-word-if-possible(family, word, comparison-list) = {
  let word = lower(word)
  if word in comparison-list{
    return capitalize(get.text(transl(family, t:word, mode: str)))
  }

  return capitalize(word)
}