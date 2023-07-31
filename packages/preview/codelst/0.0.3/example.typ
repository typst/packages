#import "./codelst.typ": sourcecode, sourcefile, lineref, codelst-styles

#let codelst = text(fill: rgb(254,48,147), smallcaps("codelst"))

#let cmd( name ) = text(fill: rgb(99, 170, 234), raw(block:false, sym.hash + name.text + sym.paren.l + sym.paren.r))

Normal #cmd[raw] works as expected:

```typc
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```

Using #cmd[sourcecode] will add line numbers:

#sourcecode[```typc
#show "ArtosFlow": name => box[
  #box(image(
    "logo.svg",
    height: 0.7em,
  ))
  #name
]

This report is embedded in the
ArtosFlow project. ArtosFlow is a
project of the Artos Institute.
```]

Sourcecode can be loaded from a file and passed to #cmd[sourcefile]. Any #codelst sourcecode can be wrapped inside #cmd[figure] as expected.

#codelst blocks can be formatted via a #cmd[show] rules like:

```typc
#show <codelst>: (code) => { ... }
```

Line numbers can be formatted, too.

#[
	#show <codelst>: (code) => grid(
		columns: (25%, 1fr),
		gutter:.75em,
		[To the right in @lst-sourcefile you can see the `typst.toml` file of this package.],
		code
	)
	#figure(
		caption: "typst.toml",
		sourcefile(numbers-style: (i) => text(fill: blue, emph(i)), numbers-side:right, read("typst.toml"), file:"typst.toml")
	)<lst-sourcefile>
]

#codelst does add a minimal amount of formatting. Using #cmd[show] rules allows you to add your own styles. For easy formatting, some default styles like a colored block can be applied using #cmd[codelst-styles]:

```typc
#show : codelst-styles
```

#cmd[sourcecode] accepts a number of arguments to afffect the output., e.g. highlighting lines,  restirct the line range or place labels in specific lines to reference them later.

#[
	#show: codelst-styles
	#sourcecode(
		numbers-start: 9,
		highlighted: (14,),
		highlight-labels: true,
		gutter: 2em,
		label-regex: regex("<([a-z-]+)>")
	)[```typc
	#"hello world!" \
	#"\"hello\n  world\"!" \
	#"1 2 3".split() \ <split-example>
	#"1,2;3".split(regex("[,;]")) \
	#(regex("\d+") in "ten euros") \
	#(regex("\d+") in "10 euros")
	```]

	To reference a line use #cmd[lineref]:
	See #lineref(<split-example>) for an example of the `split()` function.
]
