# nikonova

A [Typst](https://typst.app/) template package for math and math-related exercises and notes, using
a unique dark color theme.



## Usage

```typ
#import "@preview/nikonova:0.1.1": nikonova, nikonova-problem as problem, nikonova-final as final

#show: nikonova.with(
	title: "Math",
	subtitle: "Notes and Solutions",
	subsubtitle: "Algebra",
	number: "1",
	author: "Annie Nikonova",
	email: "annie@nikonova.com",
	font: "New Computer Modern",
	bg-color: rgb("#182133"),
	fg-color: rgb("#a1e3d2"),
	emph-color: rgb("#e3a1b2")
)

= Exercises
== Evaluate the following integrals.
#problem[
	$ integral ln x dif x $
][
	1. Find the integral using integration by parts.
		- $u = ln x$, $dif u = 1/x dif x$
		- $dif v = dif x$, $v = x$
	$ integral ln x dif x
		&= x ln x - integral x/x dif x \
		&= x ln x - integral dif x $

	$ final(integral ln x dif x = x ln x - x + C) $
]
```



## Etymology

Nikonova is a reference to AN-94, a character in Girls' Frontline, on whom this package's color
theme is based upon.



## Acknowledgements

I would like to thank the maintainers of the following projects which are used in this package.

- [Typst](https://typst.app/)
- [Mannot](https://github.com/ryuryu-ymj/mannot)
- [Showybox](https://github.com/Pablo-Gonzalez-Calderon/showybox-package)
