#import "regex.typ"

#let process-trait-action-entry(key, body) = {
  if not body.keys().contains(key) { return }
  if body.at(key) == none { return }

  if type(body.at(key)) == array {
    return body
      .at(key)
      .map(entry => {
        if type(entry) == dictionary {
          // keys: name <str>, entries <array of str>

          [==== #entry.name
            #entry.entries.join(", ")#linebreak()#v(0pt)]
        } else {
          panic("not supported entry type: ", type(entry))
        }
      })
      .join("")
  }
  panic("not supported entry type: ", type(body.at(key)))
}
