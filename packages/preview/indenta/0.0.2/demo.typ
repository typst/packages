#import "lib.typ": fix-indent
#set par(first-line-indent: 2em)
#show: fix-indent()

= Title 1

== Section 1

Indent // an empty line before this paragraph is needed

Indent

== Section 2

#figure(rect(),caption: lorem(2))
no indent

#figure(rect(),caption: lorem(2))

$"Indent"$

+ item
+ item

Indent

= Title 2

no indent // this is intentional

$ f(x) $
$ f(x) $
no indent

Indent
$ f(x) $

$ f(x) $

Indent

#table()[table]

Indent

```py
print("hello")
```

`Indent`
