
#let assertType(val, typ, message: none) = {
  assert(type(typ) == "string", message: "Value hat falschen Typen. Muss `string` sein war aber " + typ)

  if type(val) == typ {
    return
  }
  
  let msg = ""
  if message != none {
    msg += message + ". "
  }
  msg += "Der erwartet Typ war `" + typ + "`, jedoch wurde `" + type(val) + "` für den Wert `" + repr(val) + "` erhalten"

  assert(type(val) == typ, message: msg)
}

#let _sentence(msg) = {
  if msg == none or msg == "" {
    return ""
  }

  if msg.ends-with(".") {
    return msg + " "
  }
  return msg + ". "
}

#let assertDictKeys(val, fields, message: none) = {
  assertType(val, "dictionary", message: message)
  assertType(fields, "array", message: "Fields Argument muss ein Array sein")

  for f in fields {
    let msg = _sentence(message) + "Key `" + f + "` wurde erwartet in `" + repr(val) + "`" 
    assert(val.keys().contains(f), message: msg)
  }
}

#let assertEnum(val, options, message: none) = {
  assertType(val, "string", message: message)
  assertType(options, "array", message: "Options Argument muss ein Array sein")

  let msg = _sentence(message) + "Wert `" + val + "` war nicht einer der folgenen Werte `" + repr(options) + "`" 
  assert(options.contains(val), message: msg)
}

#let assertNotNone(val, message: none) = {
  let msg = _sentence(message) + "Erhaltener Wert war `none`." 
  assert(val != none, message: msg)
}

