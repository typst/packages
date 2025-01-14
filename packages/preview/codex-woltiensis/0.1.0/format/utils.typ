/*
  Défini des function utile pour le reste du projet
*/

#import "constant.typ"

//state pour les chants
#let _index-list = state("index_list", ())
#let _page = counter(page)

#let value_odd_even(number, if_odd, if_even) = {
  if calc.odd(number) { return if_odd } else { return if_even }
}

#let get_page_number() = {
  return here().position().at("page")
}

#let get_footer_alignemnt() = {
  let page_number = get_page_number()
  return value_odd_even(page_number, right, left)
}

#let get_repeat(number) = {
  if (number == 2) {return "(bis)"}
  else if (number == 3) {return "(ter)"}
  else if (number == 4) {return "(quarter)"}
  else {return [(#number x)]}
}

#let get_line_size(number_of_line, font_size) = {
  return number_of_line * font_size
}


#let get_page_measure_margin() = {
  //dictionary
  return (
    width : 10.5cm - (constant.margin.inside + constant.margin.outside),
    height : 14.8cm - (constant.margin.top + constant.margin.bottom)
  )
}

#let get_grid_column(alignement) = {
  if (alignment == right){
    return (auto, 0.4cm)
  } else {
    return (0.4cm, auto)
  }
}


#let get_rectangle_position(page_type, alignment) = {
  let dx = 0cm
  let dy = - constant.margin.top
  
  if (alignment == right){
    dx = constant.margin.outside
  } else {
    dx = -constant.margin.outside
  }

  if (constant.type.at(page_type) != 0){
    dy += (constant.type.at(page_type) - 1)*(constant.rectangle.height)
  }

  return (dx : dx, dy : dy)
}