// NAME: Utilities submodule (internal)


// FEAT: utils.purl() get elements of package urls
#let purl(url) = {
  // REPR: pkg:type/namespace/name@version

  // Remove optional pkg: scheme
  if url.starts-with("pkg:") {url = url.slice(4)}
  // Fallback type/ to typst
  if not url.contains("/") {url = "typst/" + url}

  url.match(regex("^(.*)/(.*?)(?:[@:](.*))?$")).captures
}


// FEAT: utils.storage() manages and store configurations and other data (see USAGE)
#let storage(
  add: none,
  get: none,
  del: none,
  upd: none,
  ..val
) = {
  let state-name = "min-manual-configuration-storage"
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


// FEAT: standard defaults used
#let defs = (
  justify: true,
  margin: (top: 3cm, bottom: 2cm, x: 2cm),
  font: ("tex gyre heros", "arial"),
  "font.title": ("tex gyre adventor", "century gothic"),
  "font.raw": ("fira mono", "inconsolata"),
  comment-delim: ("///", "/**", "**/"),
  size: 13pt,
)


// FEAT: Manages min-manual/Typst defaults
#let def(test, key, ..others) = {
  let name = key.split(".").first()
  let stop = others.pos().at(0, default: none) 
  let option = (:)
  
  option.insert(name, defs.at(key))
  
  if stop == none {stop = storage().final().at("use-defaults")}
  
  if stop or not test {(:)} else {option}
}


// FEAT: #show: utils.enable-term() allows "term/terminal" #raw syntax
#let enable-term(doc) = {
  show selector.or(
    raw.where(lang: "term"), raw.where(lang: "terminal"),
  ): set raw(
    syntaxes: "assets/term.sublime-syntax",
    theme: "assets/term.tmTheme"
  )
  
  show selector.or(
    raw.where(lang: "term"), raw.where(lang: "terminal"),
  ): it => {
    set text(fill: rgb("#CFCFCF"))
    
    // Disable #raw 1em padding here
    storage(add: "raw-padding", false)
    
    pad(
      x: 1em,
      block(
        width: 100%,
        fill: rgb("#1D2433"),
        inset: 8pt,
        radius: 2pt,
        it
      )
    )
    
    // Re-enable #raw 1em padding
    storage(add: "raw-padding", true)
  }
  
  doc
}


// FEAT: #show: utils.enable-example() allows "eg/example" #raw lang
#let enable-example(elem) = {
  import "lib.typ": example

  show raw: set text(size: text.size)
  
  if ("eg", "example").contains(elem.lang) {example(elem.text, block: true)}
  else {elem}
}