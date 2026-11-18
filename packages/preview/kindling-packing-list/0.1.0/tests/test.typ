// Run (in the package folder): typst compile --root . tests/test.typ /tmp/test.pdf  (fails on the first broken assert)
#import "../lib.typ": *

#assert.eq(parse-item("- [ ] Stove"), (text: "Stove", packed: false))
#assert.eq(parse-item("  * [X] Fuel"), (text: "Fuel", packed: true))
#assert.eq(parse-item("+ [x] Jug"), (text: "Jug", packed: true))
#assert.eq(parse-item("# Fire"), none)
#assert.eq(parse-item("- Lantern"), none)
#assert.eq(parse-item("-[ ] a"), none)
#assert.eq(parse-item("- [v] a"), none)

#let p = parse-camp("- [x] loose\n# Fire\n- [x] Stove\n- [ ] Fuel\n# Empty\n# Water\r\n- [x] Jug\r\nnote\n")
#assert.eq(p.map(s => s.title), ("(no section)", "Fire", "Empty", "Water"))
#assert.eq(p.at(1).items.len(), 2)
#assert.eq(p.at(2).items.len(), 0)
#assert.eq(progress(p), (packed: 3, total: 4))

#assert.eq(status-text(12, 22), "Packed 12/22 (55%)")
#assert.eq(status-text(5, 5), "Packed 5/5 - all packed")
#assert.eq(status-text(0, 0), "")

#let s = parse-camp(starter-list)
#assert.eq(s.map(x => x.title), ("Fire", "Cold", "Water", "Prep", "Clean", "Store"))
#assert.eq(progress(s), (packed: 0, total: 19))

#assert.eq(water-estimate(people: 4, days: 2), (gallons: 8, liters: 30.3))
#assert.eq(water-estimate(people: 4, days: 2, hot: true).gallons, 12.0)

All tests passed.
