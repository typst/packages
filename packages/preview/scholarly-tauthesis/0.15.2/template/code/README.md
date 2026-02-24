# code/

This is where you should add any code files you want to display in your thesis.
You can then include the code into your thesis with a combination of the
[`read`][read] and [`raw`][raw] functions:
```typst
#let code = read("relative/path/to/code/filename.jl")
#raw(code, lang:"julia")
```
If you place the `raw` call into a [`figure`][figure], you will get a numbered
code listing that you can reference.

[read]: https://typst.app/docs/reference/data-loading/read/
[raw]: https://typst.app/docs/reference/text/raw/
[figure]: https://typst.app/docs/reference/model/figure/
