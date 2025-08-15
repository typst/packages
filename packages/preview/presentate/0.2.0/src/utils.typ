#let merge-dicts(dictA, base: (:)) = {
  for (key, val) in dictA {
    if type(val) == dictionary and key in base.keys() {
      base.insert(key, merge-dicts(dictA.at(key), base: base.at(key)))
    } else {
      base.insert(key, val)
    }
  }
  return base
}

// This can be used to create multiple column layout. 
#let multicols(columns, ..kwargs) = grid(columns: columns, gutter: 1em, ..kwargs) 

// Hide list marker and enum number, but shift the layout. To use this, change the hider to `utils.hide-enum-list` and create a  "non-tight" enum and list for not affecting the layout. 
#let hide-enum-list = it => {
  show list: hide
  show enum: hide 
  show: hide
  it
}