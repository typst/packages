#import "@preview/icu-datetime:0.2.1" as icu
#import "settings.typ": *
#import "states.typ": *


#let merge-dictionaries(orig, plus)={
  if type(orig)==dictionary and type(plus)==dictionary {
    let merged=(:)
    for (key, value) in orig {
        if key in plus {
          merged.insert(key, merge-dictionaries(value, plus.at(key)))
        } else {merged.insert(key, value)}
    }
    for (key, value) in plus {
      if key not in orig {merged.insert(key, value)}
    }
    merged
  } else {plus}
}



#let get-prefix-last(terms,n, space: true)={
  let the-term=terms.at("prefix-last")
  if type(the-term)==array {the-term.at(calc.min( calc.max(n - 2, 0), 1))} else {the-term}
  if space [ ]
}

#let capitalise(string)={
 if type(string)==str {upper(string.first())+string.slice(1)} else {string}
}

