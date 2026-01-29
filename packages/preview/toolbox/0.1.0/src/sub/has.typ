/**
= Has
```typ
#import "@preview/toolbox: 0.1.0": has
```

== Field
:field: => #has.<name>(<capt>)

Check if content has a given field.
 
data <- content
  The content itself.

values <- string | array of strings
  One or more field names.
**/
#let field(data, values) = {
  assert.eq(type(data), content, message: repr(data) + " is not content")
  
  if type(values) != array {values = (values,)}
  
  for value in values {
    assert.eq(type(value), str, message: repr(value) + " is not string")
    
    if data.at(value, default: "") != "" {return true}
  }
  return false
}


/**
== Key
:key: => #has.<name>(<capt>)

Check if dictionary or module has a given key.

data <- dictionary | module
  The dictionary or module itself.

values <- string | array of strings
  One or more key names.
**/
#let key(data, values) = {
  assert(
    type(data) == dictionary or type(data) == module,
    message: repr(data) + " is not dictionary nor module"
  )
  
  if type(data) == module {data = dictionary(data)}
  if type(values) != array {values = (values,)}
  
  for value in values {
    if data.keys().contains(value) {return true}
  }
  return false
}

/**
== Value
:value: => #has.<name>(<capt>)

Check if dictionary or module has a given value.

data <- dictionary | module
  The dictionary or module itself.

values <- string | array
  One or more values.
**/
#let value(data, values) = {
  assert(
    type(data) == dictionary or type(data) == module,
    message: repr(data) + " is not dictionary nor module"
  )
  
  if type(data) == module {data = dictionary(data)}
  if type(values) != array {values = (values,)}
  
  for value in values {
    if data.values().contains(value) {return true}
  }
  return false
}


/**
== Item
:item: => #has.<name>(<capt>)

Check if an array has one or more given items.

data <- string
  The array itself.

values <- string | array of strings
  One or more items.
**/
#let item(data, values) = {
  assert.eq(type(data), array, message: repr(data) + " is not array")
  
  if type(values) != array {values = (values,)}
  
  for value in values {
    if data.contains(value) {return true}
  }
  return false
}