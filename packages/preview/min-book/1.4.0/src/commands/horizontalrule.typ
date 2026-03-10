/**
== Horizontal Rule
```typ
#horizontalrule()
```
Adds a horizontal rule, visual separators used to distinguish subtle changes
of subject in extensive texts. Its appearance is controlled by the current theme.
**/
#let horizontalrule() = [#metadata("hr placeholder") <horizontalrule:insert>]


/// The `#horizontalrule` command is also available as the smaller `#hr` alias.
#let hr = horizontalrule