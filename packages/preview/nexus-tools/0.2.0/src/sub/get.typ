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

..date <- arguments | array | dictionary | string <required>
  `(year, month, day)`\
  Components of the data, as positional/named arguments, array, dictionary, or
  string; fallback to current year, month 1, and day 1 when these components are
  not set.

pattern: <- string
  Pattern used to parse datetime from string (basic `dd`, `mm`, and `yyyy` support).
**/
#let date(..date, pattern: "mm/dd/yyyy") = {
  if type(date.pos().at(0, default: "")) == datetime {return date.pos().at(0)}
  
  let pos = date.pos()
  let named = date.named()
  let first-type = type(pos.first(default: 0))
  let named-keys
  
  if first-type == array {pos = pos.first()}
  else if first-type == dictionary {
    named = pos.first()
    
    let _ = pos.remove(0)
  }
  else if first-type == str {
    let re = lower(pattern).replace(regex("(?:y+|m+|d+)"), "(\d+)")
    let results = pos.first().match(regex(re))
      
    if results != none {results = results.captures.map(item => int(item))}
    else {panic("Date '" + pos.first() + "' not in '" + pattern + "' pattern")}
    
    pattern = pattern
      .replace(regex("[^ymd]"), "")
      .replace(regex("y+"), "year|")
      .replace(regex("m+"), "month|")
      .replace(regex("d+"), "day|")
      .split("|")
    
    for (i, value) in pattern.enumerate() {
      if value == "" {continue}
      
      named.insert(value, results.at(i, default: none))
    }
    
    let _ = pos.remove(0)
  }
  
  named-keys = named.keys()
  
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


/**
== Relative Luminance
:relative-luminance:
Returns the relative relative luminance --- something like the "amount of light" --- of a color, ranging from 0 (darkest) to 1 (lightest).

colour <- color
  Color to be evaluated.

`#relative-luminance()` -> float
  The relative luminance obtained, as a floating-point number.
**/
#let relative-luminance(colour) = {
  assert.eq(type(colour), color, message: "Argument must be a color")
  
  let components = rgb(colour).components().map(c => c / 100%)
  let luminance = 0
  
  luminance += 0.2126 * components.at(0)
  luminance += 0.7152 * components.at(1)
  luminance += 0.0722 * components.at(2)
  
  return luminance
}


/**
== Dynamic colors
:dynamic-color: => #get.<name>(<capt>)

Derive different colors based on the relative luminance of a color.
This is ideal to set optimal foreground colors that contrasts with background colors (e.g.: texts).
**/
#let dynamic-color(
  background, /// <- color
    /// Color evaluated. |
  dark: white, /// <- color
    /// Color returned when the relative luminance evaluated is low (darker color). |
  light: black, /// <- color
    /// Color returned when the relative luminance evaluated is high (lighter color). |
  limit: 0.55 /// <- float
    /// Relative luminance limit (0--1). |
) = {
  assert.eq(type(background), color, message: "Argument must be a color")
  assert.eq(type(dark), color, message: "Dark must be a color")
  assert.eq(type(light), color, message: "Light must be a color")
  
  if relative-luminance(background) < limit {dark} else {light}
}