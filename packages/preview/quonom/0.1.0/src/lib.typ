#let manual-synthdiv(
	coefficients,
	divisor,
	stroke: 1pt + black,
	..steps
) = {
	set table(
		stroke: (x, y) => if x == 0 and y < 2 {
			(right: stroke)
		} else if x > 0 and y == 2 {
			(top: stroke)
		}
	)
	table(
		align: right,
		columns: coefficients.len() + 1,
		none,
		..coefficients.map(x => $#x$),
		$#divisor$,
		none,
		..range(coefficients.len() - 1).map(i => $#steps.at(i * 2 + 1, default: none)$),
		none,
		..range(coefficients.len()).map(i => $#steps.at(i * 2, default: none)$)
	)
}



#let synthdiv(
	coefficients,
	divisor,
	stroke: 1pt + black
) = {
	let steps = (coefficients.first(),)

	for i in range(coefficients.len() - 1) {
		steps.push(steps.at(i * 2) * divisor)
		steps.push(coefficients.at(i + 1) + steps.at(i * 2 + 1))
	}

	manual-synthdiv(coefficients, divisor, stroke: stroke, ..steps)
}
