# Leetify
Leetify is a simple package for [Typst](https://typst.app) that allows you to write [Leet Speak](https://en.wikipedia.org/wiki/Leet) in your document.

## Usage
To apply leetify to the entire document just add the following:
```typ
#import "@preview/leetify:0.1.0": leetify

#show: leetify
```

To leetify only certain parts use:
```typ
#import "@preview/leetify:0.1.0": leetify

#leetify[
  This is an example of `leetify`.
  It also works in math
  $
    "define" a := lim_(n -> oo) a_n. // "define" and "lim" will be transformed
  $
]
```

By default leetify only transforms `text` functions. This behaviour can be changed by passing `text-only: false` to `leetify` calls.
```typ
#import "@preview/leetify:0.1.0": leetify

#show: leetify.with(text-only: false)
$
  pi > e // will transform "e" into "3"
$
```

You can also import the internally used conversion functions. Note that they require you to provide a string.
```typ
#import "@preview/leetify:0.1.0": convert-to-leet, convert-from-leet

#convert-to-leet("Hello world!") // H3ll0 w0rld!
#convert-to-leet("H3ll0 w0rld!") // Hello world!
```

## Contribution
Feel free to open an issue or submit a PR if you encounter issues or want to extend the functionality.

