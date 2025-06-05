#import "@preview/versatile-apa:7.1.2": *

= Computer code
The template has some support for raw/computer code, but if further customization is wanted, I recommend using #link("https://typst.app/universe/package/codly/")[Codly].

== Code block
=== Code block as a figure

#apa-figure(
  ```py
  def main():
      print("Hello, World!")
  ```,
  caption: [Python code block],
)

=== Non-figure code block

```cs
using System;

public class Program
{
    public static void Main(string[] args)
    {
        Console.WriteLine("Hello, World!");
    }
}

class MyClass
{
    public void MyMethod()
    {
        Console.WriteLine("Hello, World!");
    }
}

Console.WriteLine("Long line of code that exceeds the width of the page and needs to be wrapped to fit within the margins of the document.");
```

=== Parse file content

#raw(
  read("../assets/src/main.py"),
  lang: "py",
)

== Inline code
Inline code can be inserted within a sentence, like this: `print("Hello, World!")`.
