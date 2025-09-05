// === [ String functions ] ====================================================

#let title-case(s) = {
	let c = s.first()
	upper[#c]
	s.slice(c.len(),)
}
