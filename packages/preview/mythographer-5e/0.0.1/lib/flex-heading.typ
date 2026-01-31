// Thanks: https://forum.typst.app/t/how-to-use-different-text-in-outline-and-actual-heading/3093
#let in-outline = state("in-outline", false)
#let flex-heading(long, short) = context if in-outline.get() { short } else { long }
