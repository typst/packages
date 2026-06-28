// NAME: Utilities sub-module (internal)

// UTIL: utils.numbering-std() access standard numbering() after being shadowed
#let numbering-std = numbering

// UTIL: utils.numbering() handles book numbering strings/arrays
#let numbering(
  patterns: (),
  scope: (:),
) = (
  ..nums
) => context {
  import "@preview/numbly:0.1.0": numbly

  // Set #patterns final value
  let patterns = if patterns.at(0) != auto {patterns.at(0)}
    else if scope.h1 != none {patterns.at(1, default: none)}
    else {patterns.at(2, default: none)}
  let scope = scope
  
  // Set all numbering to none
  if patterns == none {return none}
  
  // Convert string patterns into array
  if type(patterns) == str {patterns = (patterns,)}
  
  // Transform patterns into positional arguments
  patterns = arguments(..patterns).pos()
  
  // Defines whether the heading being numbered is before or after TOC
  let after-toc = query(selector(label("outline")).before(here())) != ()

  // When using a default numbering string:
  if patterns.len() == 1 and not patterns.at(0).contains(regex("\{.*\}")) {
    return {
      numbering-std(..patterns, ..nums)
      if not after-toc {h(0.5em)}
    }
  }
  
  // When numbering-style == none
  if patterns == () {
    if scope.h1 != none {
      patterns.push("\n")
      scope.h1 = scope.h1 + ":"
    }
    if scope.h2 != none {
      patterns.push("\n")
       scope.h2 = scope.h2 + ":"
    }
  }
  
  
  if after-toc {
    if scope.h1 != none and patterns.len() >= 1 {
      // Heading level 1 become part
      patterns.at(0) = scope.h1 + " " + patterns.at(0)
  
      // Heading level 2 become chapter
      if scope.h2 != none and patterns.len() >= 2 {
        patterns.at(1) = scope.h2 + " " + patterns.at(1)
      }
    } else {
      let n = scope.at("n", default: 0)
      
      // Heading level 1 become chapter, if no part
      if scope.h2 != none and patterns.len() >= 1 {
        patterns.at(n) = scope.h2 + " " + patterns.at(n)
      }
    }
  }
  else {
    let contents = ()
    
    for pattern in patterns {
      // Remove any "\n" at the end of numbering patterns:
      if type(pattern) == str {pattern = pattern.trim(regex("\n+$"))}
      
      contents.push(pattern)
    }
    patterns = contents
  }

  // HACK: #book(part: "") defines title-only parts, without name nor numbering.
  if scope.h1 == "" {
    patterns.at(0) = ""
  }
  
  // Set the numbering for current level to none
  if patterns.at(nums.pos().len() - 1, default: "") == none {return none}
  
  // Get numbering using numbly
  numbly(default: "I.I.1.1.1.a", ..patterns)(..nums)
  
  // Numbering-title gap in TOC
  if not after-toc {h(0.5em)}
}


// UTIL: utils.date() creates a date using named and/or positional arguments
#let date(..date) = {
  if type(date.pos().at(0)) == datetime {return date.pos().at(0)}
  
  // Convert array or dictionary to arguments
  if type(date.pos().at(0)) == array or type(date.pos().at(0)) == dictionary {
    date = arguments(..date.pos().at(0))
  }
  
  let year = if date.pos().len() >= 1 {date.pos().at(0)}
    else if date.named().at("year", default: none) != none {date.named().year}
    else {datetime.today().year()}
  
  let month = if date.pos().len() >= 2 {date.pos().at(1)}
    else if date.named().at("month", default: none) != none {date.named().month}
    else {1}

  let day = if date.pos().len() == 3 {date.pos().at(2)}
    else if date.named().at("day", default: none) != none {date.named().day}
    else {1}

  datetime(
    year: year,
    month: month,
    day: day
  )
}


// UTIL: utils.storage() manages and store configurations and other data (see USAGE)
#let storage(
  add: none,
  get: none,
  del: none,
  upd: none,
  ..val
) = {
  let state-name = "min-book-configuration-storage"
  let this = state(state-name)
  let val = val.pos().at(0, default: none)
  
  // USAGE: utils.storage(add: <string>, [any])
  if add != none {
    this.update(curr => {
      if curr == none {curr = (:)}
      let val = val
      
      if add.contains(".") {
        let p = str(add).split(".")
        
        if add.ends-with("+") {
          p.last() = p.last().trim("+")
          let arr = curr.at(p.at(0), default: (:)).at(p.at(1), default: ())
          val = (..arr, val)
        }
        
        // Insert curr.at(p0)
        if curr.at(p.at(0), default: (:)) == (:) {
          curr.insert(str(p.at(0)), (:))
        }
        curr.at(p.at(0)).insert(p.at(1), val)
      }
      else {
        if add.ends-with("+") {
          add = add.trim("+")
          let arr = curr.at(add, default: ())
          val = (..arr, val)
        }
        curr.insert(str(add), val)
      }
      curr
    })
  }
 // USAGE:  utils.storage(del: <string>)
  else if del != none {
    this.update(curr => {
      if curr == none {curr = (:)}
      if del.contains(".") {
        let path = del.trim(".").split(".")
        let last = path.last()
        let res = curr
        
        for part in path {
          if type(res) != dictionary {res = (:)}
          if not res.keys().contains(part) {panic("Invalid path: " + del)}
          
          res = res.at(part)
        }
        
        let _ = path.remove(path.len() - 1)
        path = path.join(".")
        
        curr = eval(
          "let _ = curr." + path + ".remove(\"" + last + "\"); curr",
          scope: (curr: curr)
        )
      }
      else {
        let _ = curr.remove(str(del), default: val)
      }
      curr
    })
  }
  // USAGE: utils.storage(get: <string>, [any])
  else if get != none {
    if get.contains(".") {
      get = get.trim(".")
      
      let parts = get.split(".")
      let res = this.get()
      
      for part in parts {
        if res.at(part, default: none) == none {res = val}
        if type(res) != dictionary {
          if part == parts.last() {res = val}
          break
        }
        res = res.at(part)
      }
      return res
    }
    else  {return this.get().at(str(get), default: val)}
  }
  // USAGE: utils.storage(upd: <any>)
  else if upd != none {this.update(val)}
  // USAGE: context utils.storage()
  else {return this}
}


// DEBUG: utils.storage-repr() shows an utils.storage() representation in YAML
#let storage-repr(mode: "get", path: none, ..body) = {
  if body.pos() == () or type(body.pos().last()) != content []
  else {body.pos().last()}
  
  context {
    set page(width: auto, height: auto, margin: 1cm)
    
    let data = if mode == "get" {storage().get()}
      else if mode == "final" {storage().final()}
      else {panic("Invalid mode: " + repr(mode))}
  
    if path != none {
      data = eval("data." + path, scope: (data: data))
    }
    
    raw(
      lang: "yaml",
      yaml.encode(data)
    )
  }
}


// UTIL: Languages with support for automatic translation
#let std-langs = (
  "en", "pt", "la", "zh", "hi", "es", "ar", "fr", 
  "bn", "ru", "ur", "id", "de", "ja", "it",
)