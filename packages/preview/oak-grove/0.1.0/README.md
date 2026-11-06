# Oak Grove

Create problem sets with multiple solutions, tags, links and code.

## Features

- Generate a section for **listing problems** and another section for **showing solutions**.
- Organize problems in **sections**.
- Write **solutions** in **code blocks** or automatically **read from files**.
- Use colorful **tags** to categorize problems.
- Add **hyperlinks** to problems.
- Support for English, Spanish and Catalan.
## Usage

Here's a short but complete example:

```typst
#import "@preview/oak-grove:0.1.0" as oak

#show: oak.set-config(
  read-func: (filename) => read(filename),
  // You can also specify a function that receives the problem
  // object and returns the link for more advanced use cases.
  link: "https://jutge.org/problems/", // IDs will be appended to this.
  tags: (
    oak.tag("easy", green.darken(60%)),
    oak.tag("hard", red.darken(60%))
  ),
  default-lang: "cc",
)

#show link: underline

#let data = (
  // Use sections to organize problems. The second parameter
  // must be a list of problem objects.
  oak.section("A section", (
    // Name is the first string parameter, and the solution
    // is the first content or raw block parameter.
    oak.problem("Hello world!", [
      A text solution.

      This one's easy.
    ], descr: [Good luck solving this!], tags: ("easy"), author: "Who Knows"),
    // Problem ID is the second string parameter.
    oak.problem("Time decomposition", "P37469", ```cpp
    #include <bits/stdc++.h>

    using namespace std;

    int main() {
      int n;
      cin >> n;

      cout << (n / 3600) << ' ';

      n %= 3600;

      cout << (n / 60) << ' ';

      n %= 60;

      cout << n << '\n';
    }
    ```)
  )),
  oak.section("Another section", (
    // Using auto will read the file "P52109.cc" in the current directory
    // and use it as the solution.
    oak.problem("Siracusa function", "P52109", auto),

    // Use the oak.solution function to add a title or description or
    // override the language. You can specify multiple solutions.
    oak.problem("Darkened", "P79756", author: "Salvador Roura", (
      // This will read "P79756-1.cc"
      oak.solution(auto, title: "Obvious solution"),
      // This will read "P79756-2.cc"
      auto, // Unnamed solution
      // This will read "P79756-3.py"
      oak.solution(auto, title: "Even more efficient solution", descr: [
        This one even has a description.
      ], lang: "py")
    ))
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
```

## Examples

See the [examples](examples) directory.

- [`basic.typ`](./examples/basic.typ)
- [`links.typ`](./examples/links.typ)
- [`sections.typ`](./examples/sections.typ)
- [`multiple-solutions.typ`](./examples/multiple-solutions.typ)
- [`tags.typ`](./examples/tags.typ)
- [`reading-files/main.typ`](./examples/reading-files/main.typ)

## License

MIT

## Author

Àlex Touza