# Hy-dro-gen

Unofficial bindings from [`typst/hypher`](https://github.com/typst/hypher) to native Typst.

<!-- @scrybe(if publish; grep https; grep {{version}}) -->
Full documentation [here](https://github.com/Vanille-N/hy-dro-gen/releases/download/0.1.2/docs.pdf).

## Versions

<!-- @scrybe(jump latest; grep ' {{version}} ') -->
| `hy-dro-gen`   | `hypher`                       |
|----------------|--------------------------------|
| 0.1.0          | [0.1.5](https://github.com/typst/hypher/releases/tag/v0.1.5) |
| 0.1.1          | [0.1.6](https://github.com/typst/hypher/releases/tag/v0.1.6) |
| 0.1.2 (latest) | [0.1.6](https://github.com/typst/hypher/releases/tag/v0.1.6) forked to [83aa0d2](https://github.com/Vanille-N/hypher/commit/83aa0d2d562e268caac7a7ad5b3e71530784dcbc) |

## Basic usage

<!-- @scrybe(not publish; jump import; grep local; grep {{version}}) -->
<!-- @scrybe(if publish; jump import; grep preview; grep {{version}}) -->
```typ
#import "@preview/hy-dro-gen:0.1.2" as hy

// `exists` checks if a language is supported
#assert(hy.exists("fr"))
#assert(not hy.exists("xz"))

// `syllables` splits words according to the language provided (default "en")
#assert.eq(hy.syllables("hydrogen"), ("hy", "dro", "gen"))
#assert.eq(hy.syllables("hydrogène", lang: "fr"), ("hy", "dro", "gène"))
#assert.eq(hy.syllables("υδρογόνο", lang: "el"), ("υ", "δρο", "γό", "νο"))
```

## More features

`hy-dro-gen` also supports dynamically loaded patterns to hyphenate languages not
natively supported by Typst.
<!-- @scrybe(if publish; grep https; grep {{version}}) -->
See the documentation [here](https://github.com/Vanille-N/hy-dro-gen/releases/download/0.1.2/docs.pdf) for more details.

