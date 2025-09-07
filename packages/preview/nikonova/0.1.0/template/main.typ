// SPDX-FileCopyrightText: Copyright (C) 2025 Nile Jocson <atraphaxia@gmail.com>
// SPDX-License-Identifier: 0BSD

#import "@preview/nikonova:0.1.0": nikonova, nikonova-problem as problem, nikonova-final as final

#show: nikonova.with(
	title: "Math 22",
	subtitle: "Notes and Solutions",
	subsubtitle: [
		Techniques of Integration \
		Integration by Parts
	],
	number: "1",
	email: "atraphaxia@gmail.com",
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
