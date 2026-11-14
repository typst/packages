#import "@preview/kalt:0.1.2": all, any, comp, map, reduce

#let samples = $mat(12, 18; 24, 31)$
#let corrected = map((value, x, y) => (value - 20) * 100, samples)
#let total = reduce((sum, value) => sum + comp(value), 0, samples)
#let has-over-limit = any(value => comp(value) > 30, samples)
#let all-positive = all(value => comp(value) > 0, samples)
