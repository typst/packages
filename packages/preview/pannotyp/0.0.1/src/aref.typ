#import "util.typ"

#let AAZ(i) = {
  if i > 999 {
    return AAZ(i / 1000)
  }
  if i == 1 or i == 5 or (i > 49 and i < 60) or (i > 499 and i < 600) {
    "Az "
  } else {
    "A "
  }
}

#let Anoref(target, form: "normal", supplement: auto) = {
  context {
    let i = none
    if form == "page" {
      i = counter(page).at(target).first()
    } else {
      i = util.getLabelCounterFirst(target)
    }
    AAZ(i)
  }
}

#let Aref(target, form: "normal", supplement: auto) = {
  Anoref(target, form: form, supplement: supplement)
  ref(target, form: form, supplement: supplement)
}

#let aaz(i) = {
  if i > 999 {
    return aaz(i / 1000)
  }
  if i == 1 or i == 5 or (i > 49 and i < 60) or (i > 499 and i < 600) {
    "az "
  } else {
    "a "
  }
}

#let anoref(target, form: "normal", supplement: auto) = {
  context {
    let i = none
    if form == "page" {
      i = counter(page).at(target).first()
    } else {
      i = util.getLabelCounterFirst(target)
    }
    aaz(i)
  }
}

#let aref(target, form: "normal", supplement: auto) = {
  anoref(target, form: form, supplement: supplement)
  ref(target, form: form, supplement: supplement)
}
