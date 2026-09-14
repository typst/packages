#let this = state("nexus-tools:general-data-storage", (:))

/**
= Storage
```typ
#import "preview/nexus-tools:0.1.0": storage
```

== Set Namespace
```typ
#storage.namespace(name)
```
Set the namespace used as storage. Namespaces allows multiple packages/templates
to use `#storage` at the same time, each accessing its own proper space. This
changes where data is stored *globally*, use it with caution.

name <- string <required>
  Namespace name.
**/
#let namespace(name) = {
  assert.ne(
    name, "namespace",
    message: "Cannot use reserved 'namespace' name"
  )
  
  this.update(curr => {
    curr.insert("namespace", name)
    curr
  })
}


/**
== Add Data
:add: => #storage.<name>(<capt>)

Insert a new entry in the storage.
**/
#let add(
  key, /// <- string
    /// Storage entry name. |
  value, /// <- ant
    /// Value to be stored. |
  append: false, /// <- boolean
    /// If entry already exists, append value when `true`; replaces it when `false`. |
  namespace: auto, /// <- string
    /// Add to the given namespace. |
) = {
  this.update(curr => {
    if curr == none {curr = (:)}
    
    let value = value
    let ns = namespace
    
    if ns == auto {ns = curr.at("namespace", default: "std")}
    
    if curr.at(ns, default: none) == none {curr.insert(ns, (:))}
    
    if append {
      let stored = curr
        .at(ns)
        .at(key, default: if type(value) == dictionary {(:)} else {()})
      
      if not (dictionary, array).contains(type(stored)) {stored = (stored,)}
      if not (dictionary, array).contains(type(value)) {value = (value,)}
      
      value = stored + value
    }
    
    curr.at(ns).insert(str(key), value)
    
    return curr
  })
}


/**
== Remove Data
:remove: => #storage.<name>(<capt>)

Removes an existing entry from storage.
**/
#let remove(
  key, /// <- string
    /// Storage entry name. |
  namespace: auto, /// <- string
    /// Remove from the given namespace. |
) = {
  this.update(curr => {
    if curr == none {curr = (:)}
    
    let ns = namespace
    
    if ns == auto {ns = curr.at("namespace", default: "std")}
    
    let _ = curr.at(ns).remove(str(key), default: none)
    
    return curr
  })
}

/**
== Get Data
:get: => #storage.<name>(<capt>)

Retrieves a value from storage, or the entire namespace itself.

args.pos().at(0) <- string
  Storage entry name; if not set, returns the whole namespace.

args.pos().at(1) <- any
  Default value returned when the storage entry is not found; otherwise returns `none`.
**/
#let get(
  ..args,
  namespace: auto, /// <- string
    /// Get from the given namespace. |
) = {
  let key = args.pos().at(0, default: none)
  let default = args.pos().at(1, default: none)
  let ns = namespace
  
  if ns == auto {ns = this.get().at("namespace", default: "std")}
  
  let stored = this.get().at(ns, default: (:))
  
  if key != none {stored = stored.at(str(key), default: default)}
  
  return stored
}

/**
== Get Final Data
:final: => #storage.<name>(<capt>)

Retrieves the final value (or namespace) state from storage.

args.pos().at(0) <- string
  Storage entry name; if not set, returns the final state for the whole namespace.

args.pos().at(1) <- any
  Default value returned when the storage entry is not found; otherwise returns `none`.
**/
#let final(
    ..args,
  namespace: auto, /// <- string
    /// Final state from the given namespace. |
) = {
  let key = args.pos().at(0, default: none)
  let default = args.pos().at(1, default: none)
  let ns = namespace
  
  if ns == auto {ns = this.get().at("namespace", default: "std")}
  
  let stored = this.final().at(ns, default: (:))
  
  if key != none {stored = stored.at(str(key), default: default)}
  
  return stored
}

/**
== Reset Database
:reset: => #storage.<name>(<capt>)

Set a new value for the entire storage namespace. While the new value can be of
any type, the other storage commands can only work with `dictionary` values.
**/
#let reset(
  data, /// <- dictionary | any
    /// New namespace value. |
  namespace: auto, /// <- string
    /// Reset the given namespace. |
) = {
  this.update(curr => {
    let ns = namespace
    
    if ns == auto {ns = curr.at("namespace", default: "std")}
    
    curr.at(ns) = data
    curr
  })
}