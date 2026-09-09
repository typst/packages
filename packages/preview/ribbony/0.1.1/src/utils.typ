#let point-mix = (p1, p2, t) => (p1.at(0) + (p2.at(0) - p1.at(0)) * t, p1.at(1) + (p2.at(1) - p1.at(1)) * t)
#let point-translate = (p, offset) => (p.at(0) + offset.at(0), p.at(1) + offset.at(1))
#let polar-to-cartesian = (r, angle) => (r * calc.cos(angle), r * calc.sin(angle))
#let dict-merge = (d1, d2) => {
	let result = (:)
	for (key, value) in d1 {
		result.insert(key, value)
	}
	for (key, value) in d2 {
		result.insert(key, value)
	}
	result
}