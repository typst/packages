/**
= It's
```typ
#import "@preview/toolbox: 0.1.0": its
```

== None
:none-val: => #its.<name>(<capt>)

Check whether a value is `none`.

data <- none | any
  Value to be checked. 
**/
#let none-val(data) = {return data == none}


/**
== Null
:null: => #its.<name>(<capt>)

Check whether a value is `#get.null`.

data <- any
  Value to be checked. 
**/
#let null(data) = {
  import "get.typ": null
  
  return data == null
}


/**
== Empty
:empty: => #its.<name>(<capt>)

Check whether a value is empty: `""` or `[]` or `()` or `(:)`.

data <- any
  Value to be checked. 
**/
#let empty(data) = {return ("", [], (), (:)).contains(data)}


/**
== Context
:context-val: => #its.<name>(<capt>)

Check whether a value is a `#context()`.

data <- any
  Value to be checked.
**/
#let context-val(data) = { return data.func() == [#context()].func() }


/**
== Sequence of Contents
:sequence: => #its.<name>(<capt>)

Check whether a value is a sequence of contents.

data <- any
  Value to be checked.
**/
#let sequence(data) = { return data.func() == [*A* _B_].func() }


/**
== Space Content
:space: => #its.<name>(<capt>)

Check whether a value is a content with just a space.

data <- any
  Value to be checked. 
**/
#let space(data) = { return data.func() == [ ].func() }


/**
== Function
:func: => #its.<name>(<capt>)

Check whether a value function is one of the given ones.

data <- any
  Value to be checked.

values <- function | array of functions
  One or more functions.
**/
#let func(data, values) = {
  assert.eq(type(data), content, message: repr(data) + " is not content")
  
  if type(values) != array {values = (values,)}
  
  for value in values {
    if data.func() == value {return true}
  }
  return false
}


/**
== Type
:type: => #its.<name>(<capt>)

Check whether a value type is one of the given ones.

data <- any
  Value to be checked.

values <- type | array of types
  One or more types.
**/
#let type(data, values) = {
  import "assets/orig.typ"
  
  if orig.type(values) != array {values = (values,)}
  
  for value in values {
    if orig.type(data) == value {return true}
  }
  return false
}