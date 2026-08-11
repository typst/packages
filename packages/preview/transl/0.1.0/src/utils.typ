// NAME: Utilities internal sub-module

// UTIL: Check if given required arguments are provided
#let required-args(..args) = {
  for arg in args.named().keys() {
    if args.named().at(arg) == none {
      panic("Missing required argument: " + arg)
    }
  }
}


// UTIL: Check if given value is of one of the types
#let type-check(arg, ..types, die: false) = {
  let contxt = [#context()].func()
  let match = false

  if types.pos().contains(type(arg)) {match = true}
  else if type(arg) == content and arg.func() == contxt {match = true}
  
  if die == false {return match}
  else if match == false {panic("Invalid value type: " + type(arg))}
  }
}


// UTIL: Manage and store data in the translation database (see USAGE)
#let db(
  add: none,
  get: none,
  del: none,
  upd: none,
  ..val
) = {
  let state-name = "transl-translation-database"
  let this = state(state-name)
  let val = val.pos().at(0, default: none)
  
  // USAGE: utils.cfg(add: <string>, <any>)
  if add != none {
    this.update(curr => {
      if curr == none {curr = (:)}
      let val = val
      
      if type(val) == dictionary {
        if curr.at("add", default: none) == none {curr.insert(add, (:))}
        
        for key in val.keys() {
          curr.at(add).insert(key, val.at(key))
        }
      }
      else {curr.insert(str(add), val)}
      
      curr
    })
  }
  else if get != none {
    return this.get().at(str(get), default: val)
  }
  // USAGE: context utils.cfg()
  else {
    return this
  }
}


// UTIL: Manages Fluid L10n data (see USAGE)
#let fluent-data(
  get: none,
  lang: none,
  data: none,
  args: (:)
) = {
  // USAGE: utils.fluid-data(get: <string|array>, args: [string], [any])
  if get != none {
    let ftl = plugin("./linguify_fluent_rs.wasm")
    let source = data.at(lang)
    let config = cbor.encode((source: source, msg-id: get, args: args))
    
    cbor(ftl.get_message(config))
  }
  else {panic("Missing #fluent-data(get) argument")}
}


// DEBUG: Get the translation database at this point
#let show-db(..mode) = {
  import "utils.typ": db
  
  let data = if mode.pos() != () {db().final()} else {db().get()}
  
  set page(height: auto)
  raw(
    lang: "yaml",
    yaml.encode(data)
  )
}