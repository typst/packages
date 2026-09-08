# intl-math

Math operators that **print in the language of the document**.

Mathematical abbreviations are not universal. In Spanish, sine is `sen`, tangent
is `tg`, limit is `lím` and the greatest common divisor is `mcd`; in English they
are `sin`, `tan`, `lim` and `gcd`. Typst only ships the English ones, so a Spanish
document comes out in English notation — unless you redefine the operators by hand
in every project.

**The idea: the identifier does not change, the printed word does.** You keep
writing `sin(x)`, the name Typst documents; what decides the output is `text.lang`.
Adopting the package **does not force you to rewrite your content**.

```typst
#import "@preview/intl-math:0.1.0": intl
#let m = intl()

#set text(lang: "es")
$#m.sin (x)$          // sen(x)
$#(m.lim)_(x->0)$     // lím
$#m.gcd (12, 18)$     // mcd(12, 18)

#set text(lang: "en")
$#m.sin (x)$          // sin(x)
```

## Why the `#`, and why the parentheses

You need the `#` because in math mode a bare identifier would be read as a product
of variables:

```typst
$#m.sin (x)$     ✅
$m.sin(x)$       ❌  "m times dot times sin…"
```

And **if it carries a subscript or superscript, wrap it in parentheses**, or Typst
tries to read it as a method of the dictionary:

```typst
$#(m.lim)_(x->0) f(x)$    ✅
$#m.lim_(x->0) f(x)$      ❌  "type dictionary has no method `lim_`"
```

That is the one rough edge of the API, and it comes from the way Typst parses math
mode.

## Languages

Shipped right now: **English** and **Spanish** (conventions used in Spain).

English is also the **reference** table: it defines which keys exist, and the
fallback comes from it. The cascade is *document language → English → the key
itself*, so an incomplete table never breaks a document (you get the English word)
and neither does an unknown language (everything comes out in English).

### Adding a language without forking

If yours is not there, pass it in when you build:

```typst
#let m = intl(extra: (fr: (sin: "sin", tan: "tg", gcd: "pgcd", lcm: "ppcm")))
#set text(lang: "fr")
$#m.gcd (12, 18)$     // pgcd(12, 18)
```

You only need the keys that **differ** from English. Anything you leave out is
printed in English.

### Disagreeing with the conventions

`extra` can also **override** a language the package does ship, so you don't need
to fork it just to disagree. If in your country the tangent is written `tan` and
probability is `Pr`:

```typst
#let m = intl(extra: (es: (tan: "tan", Pr: "Pr")))
```

Only the keys you list are replaced; the rest of Spanish stays as it is.

### Contributing a language

It is one file and one line:

1. Copy `lang/es.typ` to `lang/xx.typ` with your language code.
2. Keep only the keys whose printed word differs from English, and delete the
   rest. **You do not have to translate everything**: `cos`, `log`, `ln`, `exp`,
   `det`, `dim`, `tr`, `mod`, `arg`, `Re`, `Im`… are the same in many languages.
3. Add `xx: xx-lang.words` to the `BUILTIN` dictionary in `lib.typ`.

No operator needs touching: they are built automatically from the keys in
`lang/en.typ`. The complete list of keys lives there, commented by family.

## Symbols

It covers Typst's predefined operators (trigonometry, limits and extrema,
logarithms, algebra) plus a few that Typst does not ship and that maths teaching
material needs:

| Key | English | Spanish |
|---|---|---|
| `sin` `arcsin` `sinh` | sin, arcsin, sinh | **sen, arcsen, senh** |
| `tan` `arctan` `tanh` | tan, arctan, tanh | **tg, arctg, tgh** |
| `cot` `coth` `csc` | cot, coth, csc | **cotg, cotgh, cosec** |
| `lim` `liminf` `limsup` | lim, lim inf, lim sup | **lím, lím inf, lím sup** |
| `max` `min` `inf` | max, min, inf | **máx, mín, ínf** |
| `gcd` `lcm` | gcd, lcm | **mcd, mcm** |
| `rank` `adj` | rank, adj | **rang, Adj** |
| `opp` | opp | **op** |
| `dom` `proj` | dom, proj | **Dom, proy** |
| `Pr` | Pr | **P** |
| `mvt` | MVT | **TVM** |
| `pw-if` | if | **si** |

`pw-if` is not an operator: it is the word used in piecewise functions, and it is
printed with a space on each side.

```typst
$f(x) = cases(x^2 & #m.pw-if x > 0, -x & #m.pw-if x <= 0)$
```

`opp` is the additive inverse: `opp(-17)` prints "op(−17)" in Spanish. The key is
called `opp` and not `op` on purpose: `op` is a **native** Typst function
(`math.op`), and a package that takes it away from whoever installs it is a trap —
and a silent one, because `$op(-17)$` would still compile, only with a different
meaning.

Keys not listed above print the same in both languages (`cos`, `sec`, `log`, `ln`,
`lg`, `exp`, `det`, `dim`, `tr`, `mod`, `arg`, `deg`, `ker`, `hom`, `id`, `dist`,
`rad`, `Re`, `Im`, `sinc`, `sup`, `Normal`, `Bin`).

## Relation to `alterlang`

[`alterlang`](https://typst.app/universe/package/alterlang/) does something similar
for the standard operators. The differences:

- `intl-math` **does not make you change identifiers**: you write `sin` and get
  `sen`. With `alterlang` you import the already-translated symbol (`sen`).
- `intl-math` lets you **add a language without forking**, by passing it in.
- `intl-math` also covers symbols Typst does not ship (`rank`, `dom`, `proj`,
  `mvt`, `pw-if`).

They are complementary; if you only need the standard operators and you are happy
writing the translated names, `alterlang` is more direct.

The gap this fills is acknowledged in Typst itself:
[#3238](https://github.com/typst/typst/issues/3238) and
[#7159](https://github.com/typst/typst/issues/7159).

## Compatibility

- Typst `>= 0.14.0`
- No dependencies.

## Tests

```bash
just test      # installs the package and compiles tests/smoke.typ (3 languages)
               # plus tests/fallback.typ (unknown language, incomplete table, override)
```

## License

[MIT](LICENSE).
