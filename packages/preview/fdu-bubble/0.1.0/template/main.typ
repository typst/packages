#import "@preview/fdu-bubble:0.1.0": *

#show: bubble.with(
  title: "Bubble template",
  subtitle: "Simple and colorful template",
  author: "david",
  affiliation: "复旦大学",
  date: datetime.today().display(),
  year: "Year",
  class: "Class",
  other: ("Made with Typst", "https://typst.app"),
  main-color: "0E419C",
  logo: image("pics/logo.png"),
)

= Introduction

This is a simple template that can be used for a report.

#codly(header: [hello.cpp])
```cpp
#include <iostream>
using namespace std;

int main() {
  cout << "hello world!";
}
```

= Features

== Colorful items

The main color can be set with the `main-color` property, which affects inline
code, lists, links, and important items. For example, the words highlight and
important are highlighted.

- These bullet
- points
- are colored

+ It also
+ works with
+ numbered lists!

== Customized items

Figures are customized but this is settable in the template file. You can of
course reference them: @ref.

#figure(caption: [Code example], ```rust
fn main() {
  println!("Hello Typst!");
}
```)<ref>

#lorem(300)

#pagebreak()

= Enjoy!

#lorem(100)

= 中文字体测试

以下是中文测试。

$
  (a + b)^2 = a^2 + 2 a b + b^2
$
