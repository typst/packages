#let counter-id(counter) = {
  let counter-repr = repr(counter)
  return "thmbox-counter-level" + counter-repr.slice("counter(".len(), counter-repr.len() - 1)
}

/// Initializes a custom counter to work with thmbox.
/// It has a level, which means how many numbers it uses. The last one will increase per usage
/// of the counter (in thmboxes for example) while the previous ones will reflect the headings
/// 
/// For example, with level 2, the counter uses the format X.Y where X is the chapter the counter
/// is used and Y increases in this chapter.
///
/// - counter (counter): The counter to use
/// - level (int): How many numbers the counter should have. 2 makes the numbers have the format X.X, for example.
#let sectioned-counter(counter, level: 2) = doc => {
  // Metadata
  [
    #metadata(level) #label(counter-id(counter))
  ]

  show heading: it => {
    if it.level < level {
      context counter.update(
        (..std.counter(heading).get(), 0)
      )
    }
    it
  }

  context {
    let current-heading = std.counter(heading).get()
    let slice = current-heading.slice(
      0, calc.min(level, current-heading.len()) - 1
    )
    counter.update((..slice, 0))
  }

  doc
}