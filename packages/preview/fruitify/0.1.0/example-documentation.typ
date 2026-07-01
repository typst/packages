#set page(margin: (x: 2cm, y: 1cm))
#set raw(lang: "typst")
#import "fruitify.typ": fruitify-setup, fruitify, reset-symbols, vegetables

#let shown-imports = (
	fruitify-setup: fruitify-setup,
	fruitify: fruitify,
	reset-symbols: reset-symbols,
	vegetables: vegetables
)

#raw(block: true, `#import "@preview/fruitify:0.1.0": `.text + shown-imports.keys().join(", "))

#let showeval(block: true, it) = {
	let eval-text = if it.text.ends-with(regex("[.,]")) {
		it.text.slice(0, -1)
	} else {
		it.text
	}

	raw(block: block, it.text)
	eval(eval-text, mode: "markup", scope: shown-imports)
}

=== Basic usage

```
#show math.equation: fruitify
```
#show math.equation: fruitify

By default, it will look like this (the symbol order is predetermined):

$ x + 2 y = z sin(2 theta.alt) $
$ a^2 + b^2 = c^2 $

Each single letter in equations is replaced with a symbol.
This is done by index of occurrence, so *which* letters you use doesn't affect the output,
only *when* you first used them, relative to each other.

The package will produce an error when you run out of symbols:
```
$ #"qwertyuiopasdfghjklzxcvbnm".codepoints().join(" ") $
// => error: assertion failed: equation has more characters than possible symbols
```

=== Keep symbol map across equations

By default, different equations are isolated from each other
in order to avoid using up all available symbols.
You can disable this with

#showeval[`#fruitify-setup(reuse: true).`]

Now, the letter$->$symbol map will be kept across the whole document.

$ x + 2 y = z sin(2 theta.alt) $
$ a^2 + b^2 = c^2 $
$ y - x = 0 $

Manually reset it with:
#showeval[`#reset-symbols()`]

=== Randomize symbol order

You can choose a random seed that determines a different symbol order.
This is implemented using pseudo-random number generation,
but it is fully deterministic. The same seed will always give you the same order.

The seed can be an integer or an array of 16 integers, each of which has to be in the interval $[0, 255]$.

#showeval[`#fruitify-setup(random-seed: 2)`]

$ x + 2 y = z sin(2 theta.alt) $
$ a^2 + b^2 = c^2 $

The default (no PRNG, just take the symbols in their hard-coded order) is reachable via
#showeval[`#fruitify-setup(random-seed: none).`]

=== Use other symbols

#let predefined = ([`fruits` (the default)], "vegetables")

The `symbols` option takes an array of strings. This can be anything,
but the following #predefined.len() are predefined:
#list(..predefined.map(x => if type(x) == str { raw(x) } else { x }))

#showeval[`#fruitify-setup(symbols: vegetables)`]
(Don't forget to #showeval(block: false)[`#reset-symbols()`]
when using `reuse: true`, otherwise this won't affect any already-used letters.)

$ x + 2 y = z sin(2 theta.alt) $
$ a^2 + b^2 = c^2 $