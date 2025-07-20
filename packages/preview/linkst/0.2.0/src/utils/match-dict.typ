///
/// Returns the given dictionary in the given standard format dictionary.
/// 
/// **Example:**
/// ```typst
/// let style = (arrow: true, width: 2)
/// let std-style = (arrow: false, width: 1, height: 1)
/// 
/// let style = match-dict(style, std-style)
/// // style is now (arrow: true, width: 2, height: 1)
/// ```
/// 
#let match-dict(dict, std-dict) = {

  // get keys
  let keys = dict.keys()
  let std-keys = std-dict.keys()

  
  for std-key in std-keys {

    let std-value = std-dict.at(std-key)

    if std-key not in keys { // insert standard key if not given

      dict.insert(std-key, std-value) 

    } else if type(dict.at(std-key)) == dictionary and type(std-value) == dictionary { // if dict has a dictionary in it, it recursively matches it

      dict.at(std-key) = match-dict(dict.at(std-key), std-value)

    }

  }

  dict

}
