/*
  Défini des function utile pour le reste du projet
*/
#import "constant.typ"

//state pour les chants
#let _index-list = state("index-list", ())
#let _page = counter(page)

#let value-odd-even(number, if-odd, if-even) = {
  if calc.odd(number) { return if-odd } else { return if-even }
}

#let get-page-number() = {
  return here().position().at("page")
}

#let get-footer-alignemnt() = {
  let page-number = get-page-number()
  return value-odd-even(page-number, right, left)
}

#let get-repeat(number) = {
  if (number == 2) {return "(bis)"}
  else if (number == 3) {return "(ter)"}
  else if (number == 4) {return "(quarter)"}
  else {return [(#number x)]}
}

#let get-line-size(number-of-line, font-size) = {
  return number-of-line * font-size

}


#let get-page-measure-margin() = {
  //dictionary
  return (
    width : 10.5cm - (constant.margin.inside + constant.margin.outside),
    height : 14.8cm - (constant.margin.top + constant.margin.bottom)
  )
}

#let get-grid-column(alignement) = {
  if (alignment == right){
    return (auto, 0.4cm)
  } else {
    return (0.4cm, auto)
  }
}


#let get-rectangle-position(page-type, alignment) = {
  let dx = 0cm
  let dy = - constant.margin.top
  
  if (alignment == right){
    dx = constant.margin.outside
  } else {
    dx = -constant.margin.outside
  }

  if (constant.type.at(page-type) != 0){
    dy += (constant.type.at(page-type) - 1)*(constant.rectangle.height)
  }

  return (dx : dx, dy : dy)
}