/// Align the list marker with the baseline of the first line of the list item.
///
/// Usage: `#show: align-list-marker-with-baseline`
#let align-list-marker-with-baseline(body) = {
  show list.item: it => context {
    let current-marker = {
      set text(fill: text.fill)
      if type(list.marker) == array {
        list.marker.at(0)
      } else {
        list.marker
      }
    }
    let hanging-indent = measure(current-marker).width + .6em + .3pt
    set terms(hanging-indent: hanging-indent)
    if type(list.marker) == array {
      terms.item(
        current-marker,
        {
          // set the value of list.marker in a loop
          set list(marker: list.marker.slice(1) + (list.marker.at(0),))
          it.body
        },
      )
    } else {
      terms.item(current-marker, it.body)
    }
  }
  body
}

/// Align the enum marker with the baseline of the first line of the enum item. It will only work when the enum item has a number like `1.`.
///
/// Usage: `#show: align-enum-marker-with-baseline`
#let align-enum-marker-with-baseline(body) = {
  show enum.item: it => context {
    if not it.has("number") or it.number == none or enum.full == true {
      // If the enum item does not have a number, or the number is none, or the enum is full
      return it
    }
    let weight-map = (
      thin: 100,
      extralight: 200,
      light: 300,
      regular: 400,
      medium: 500,
      semibold: 600,
      bold: 700,
      extrabold: 800,
      black: 900,
    )
    let current-marker = {
      set text(
        fill: text.fill,
        weight: if type(text.weight) == int {
          text.weight - 300
        } else {
          weight-map.at(text.weight) - 300
        },
      )
      numbering(enum.numbering, it.number) + h(-.1em)
    }
    let hanging-indent = measure(current-marker).width + .6em + .3pt
    set terms(hanging-indent: hanging-indent)
    terms.item(current-marker, it.body)
  }
  body
}
