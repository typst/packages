#import "/src/lib.typ" as oak

#show: oak.set-config(
  // default language and extension for read files
  // can be omitted if all solutions specify a language
  default-lang: "cc",
  // file reading function, needed due to how Typst treats packages
  read-func: filename => read(filename)
)

#let data = (

  // use auto to read a file
  oak.problem("Siracusa function", "P52109"),
  // use the "solution" type for more options
  oak.problem("Increasing circles", "P88106", oak.solution(auto, lang: "py")),
  // multiple solutions will append -N to the filename, starting by 1
  oak.problem("Darkened", "P79756", (
    oak.solution(auto, title: "Obvious solution"),
    auto, // Unnamed solution
    oak.solution(auto, title: "Even more efficient solution", descr: [
      This one even has a description.
    ], lang: "py")
  ))
)

= Problem list

#oak.problems-list(
  data,
)

#pagebreak()

= Solutions
#oak.problems-solutions(
  data,
)

