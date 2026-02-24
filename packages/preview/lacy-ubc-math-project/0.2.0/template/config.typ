#import "@preview/lacy-ubc-math-project:0.2.0": author, defaults

// Your group's name.
#let group-name = [Group Name]

// The group members.
// They are here, rather than being in the project file, so they can be conveniently reused in other projects of your group.
// Note that the `author` function is used for creating authors, please do the same for your authors.

#let jane-doe = author("Jane", "Doe", 31415926)
#let alex-conquitlam = author(
  "Alex",
  // If the name is a bit unusual, you can still have them!
  // This example uses Typst's Unicode conversion capability,
  // you can also just type the character, or even supply `content`.
  "k\u{02b7}ik\u{02b7}\u{0259}\u{019b}\u{0313}",
  27182818,
  // Just in case the name is incompatible with PDF metadata or your reader...
  // you can provide a `str` containing only Ascii characters.
  // (Or whatever works, really.)
  plain: "Alex Coquitlam",
)

// This is the user config, it should be named "config".
// The package as a default config, but you can write the same thing here with different values to override the defaults...
// just like below the line enabling markscheme.

#let config = (
  solution: (
    // Enable the default solution container's markscheme mode.
    // To disable it, simply comment out or remove this line, and add a ":" right after the "(" above.
    container: defaults.solution.container.with(markscheme: true),
  ),
)
