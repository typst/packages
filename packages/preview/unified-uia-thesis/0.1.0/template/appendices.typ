#import "/src/lib.typ": append-typ

= First appendix <appendix-1>
This is the first appendix, which can be referenced with `@appendix-1`.

== Second level appendix
And second level

= Included .typ file
If you need to include `.typ` files as an appendix, you'll want to import them using the `append-typ()` function, so that it doesn't inherit this stupid appendix heading syntax:
```typ
#append-typ(include "file.typ")
// or if you want numbering:
#append-typ(include "file.typ", numbering: "1.1")
```
