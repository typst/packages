/**
= Get
```typ
#import "@preview/nexus-tools: 0.1.0": get
```

== Null Value
```typ
#get.null
```
A null value that matches only itself. Useful as substitute for `none` default
values, as it is truly unique and not naturally returned by anything in Typst.
**/
#let null() = [#sym.zws#sym.zwnj#sym.zws#sym.zwnj#sym.zws]


/**
== Automatic Values
:auto-val: => #get.<name>(<capt>)

Sets a meaningful value to `auto` values: if a value is automatic, returns the
replacement; otherwise, returns the value unchanged.
**/
#let auto-val(
  origin, /// <- auto | any
    /// Value to be checked. |
  replace, /// <- any
    /// Replacement for the value if `auto`. |
) = {if origin == auto {return replace} else {return origin}}


/**
== Date
:date: => #get.<name>(<capt>)

Create a `#datetime` date from named and/or positional arguments, combined or not.
Panics if two values are set for the same data component — like a positional and
also a named value for the year.

..date <- arguments <required>
  `(year, month, day)`\
  Components of the data, as positional and/or named arguments; fallback to
  current year, month 1, and day 1 when these components are not set.
**/
#let date(..date) = {
  if type(date.pos().at(0, default: "")) == datetime {return date.pos().at(0)}
  
  let pos = date.pos()
  let named = date.named()
  let named-keys = named.keys()
  
  if named-keys.contains("year") and pos.len() > 0 {
    panic("Duplicated positional and named year defined")
  }
  if named-keys.contains("month") and pos.len() > 1 {
    panic("Duplicated positional and named month defined")
  }
  if named-keys.contains("day") and pos.len() > 2 {
    panic("Duplicated positional and named day defined")
  }
  
  let values = (
    year: named.at("year",
      default: pos.at(0,
        default: datetime.today().year()
      )
    ),
    month: named.at("month",
      default: pos.at(1,
        default: 1
      )
    ),
    day: named.at("day",
      default: pos.at(2,
        default: 1
      )
    ),
  )
  
  datetime(
    year: values.year,
    month: values.month,
    day: values.day
  )
}