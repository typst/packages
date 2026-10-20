// Apply transform to the first character of s, preserving the rest.
// Uses s.first().len() so the slice index lands on a character boundary
// even when the first character is multi-byte (e.g. "í", "é", "ñ").
#let _head-tail(s, transform) = transform(s.first()) + s.slice(s.first().len())


// Set text case of result based on expr
#let set-case(result, expr) = {
  let first = expr.first()

  if first == lower(first) {_head-tail(result, lower)}
  else if expr == upper(expr) {upper(result)}
  else if first == upper(first) {_head-tail(result, upper)}
  else {result}
}


// Retrieve Fluent data using wasm plugin
#let fluent(get, lang, data, args: (:)) = {
  let wasm = plugin("./plugin.wasm")
  let source = data.at(lang)
  let config = cbor.encode((source: source, msg-id: get, args: args, lang: lang))
  
  cbor(wasm.get_message(config))
}


// Retrieve translation
#let translate(expr, from, to, data, args, showing) = {
  import "@preview/nexus-tools:0.1.0": storage, has
  
  assert.ne(data, (:), message: "Set #transl(data) option before use")
  assert.eq(type(expr), str, message: "#transl(" + repr(expr) + ") isn't string")
  
  let std = data.at("std", default: (:))
  let ftl = data.at("ftl", default: (:))
  let placeable = regex("(?s)\{\s*\$([^\}].+?)\s*\}")
  let result = none
  
  // Return back expression (no translation needed)
  if from == to {return expr}
  
  if has.key(std.at(to, default: (:)), expr) {
    // Retrieve expr in standard database
    result = std
      .at(to, default: (:))
      .at(expr)
      .replace(placeable, m => {
        // Simple {$arg} substitution
        let key = m.captures.at(0)
        
        if has.key(args, key) {args.at(key)} else {m.text}
      })
      
    if not showing {result = set-case(result, expr)}
    
    return result
  }
  else {
    // Checks if expr is a regex with matches in std.at(to)
    let key = std
      .at(to, default: (:))
      .keys()
      .find( key => key.contains(regex("(?i)" + expr)) )
    
    if key != none {
      result = std
        .at(to, default: (:))
        .at(key)
        .replace(placeable, m => {
          // Simple {$arg} substitution
          let key = m.captures.at(0)
          
          if has.key(args, key) {args.at(key)} else {m.text}
        })
        
      if not showing {result = set-case(result, expr)}
      
      return result
    }
    
    assert.ne(
      ftl, (:),
      message: "'" + expr + "' not found for '" + to + "' (no Fluent database)"
    )
    assert.ne(
      ftl.at(to, default: (:)), (:),
      message: "'" + expr + "' not found for '" + to + "' (no Fluent file loaded)"
    )
    
    // Retrieve expr in Fluent database
    result = fluent(expr, to, ftl, args: args)
    
    if result == none {panic("'" + expr + "' not found for '" + to + "'")}
    
    return result
  }
}
