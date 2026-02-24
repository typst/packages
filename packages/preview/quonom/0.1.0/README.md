# quonom

A [Typst](https://typst.app/) package for polynomial division.



## Usage

```typ
#import "@preview/quonom:0.1.0": manual-synthdiv, synthdiv

#figure(
	caption: "Manual synthetic division, fill the missing fields by yourself",
	manual-synthdiv(
		(1, -1, -1, 10),
		-2,
		1, -2, -3, 6, 5, -10, 0
	)
) \

#figure(
	caption: "Automatic synthetic division",
	synthdiv(
		(1, -1, -1, 10),
		-2,
	)
)
```



## Etymology

Quonom is a combination of the words *quotient* and *polynomial*.



## Acknowledgements

I would like to thank the maintainers of the following projects which are used in this package.

- [Typst](https://typst.app/)
