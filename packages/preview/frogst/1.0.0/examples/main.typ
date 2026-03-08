#import "@preview/frogst:1.0.0": fr-nb, fr-int
// #import "@local/frogst:1.0.0": fr-nb, fr-int
// #import "../lib.typ": fr-nb, fr-int

#set document(date: none)
#set page("a5", columns: 2)
#set text(hyphenate: false)
#set par(justify: false)

#let fr-nb-test(nb) = [
    // - #fr-int(nb) : #fr-nb(nb) \
    / #fr-int(nb): #fr-nb(nb)
]

#let N = 101
#for i in range(N + 1) {
    fr-nb-test(i)
}
#fr-nb-test(113)
#fr-nb-test(176)
#fr-nb-test(191)
#fr-nb-test(200)
#fr-nb-test(201)
#fr-nb-test(300)
#fr-nb-test(355)
#fr-nb-test(678)
#fr-nb-test(692)
#fr-nb-test(999)
#fr-nb-test(1000)
#fr-nb-test(1001)
#fr-nb-test(1729)
#fr-nb-test(2000)
#fr-nb-test(2001)
#fr-nb-test(16999)
#fr-nb-test(17000)
#fr-nb-test(116999)
#fr-nb-test(189695)
#fr-nb-test(300000)
#fr-nb-test(470147)
#fr-nb-test(1618099)
#fr-nb-test(9389461)
#fr-nb-test(23000999)
#fr-nb-test(23200100)
#fr-nb-test(23001201)
#fr-nb-test(43200100)
#fr-nb-test(63001201)
#fr-nb-test(8871618999)
#fr-nb-test(-9814072356)
