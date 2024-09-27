// TODO: base should *actually* be lowered by 0.5ex, but Typst does not yet
// have an ex unit, only em. See https://github.com/typst/typst/issues/2405
#let baseline-drop = 0.22em

#let TeX = [#box(baseline: baseline-drop)[T#h(-.1667em)#box(baseline: baseline-drop)[E]#h(-.125em)X]]
#let Xe = [#box(baseline: baseline-drop)[X#h(-.1667em)#box(baseline: baseline-drop)[#scale(x: -100%)[E]]#h(-.125em)]]
#let LaTeX = [#box(baseline: baseline-drop)[L#h(-.33em)#box(baseline: -0.2em)[#text(0.7em)[A]]#h(-.15em)#TeX]]
#let XeTeX = [#box(baseline: baseline-drop)[#Xe#TeX]]
#let XeLaTeX = [#box(baseline: baseline-drop)[#Xe#LaTeX]]
#let LuaLaTeX = [#box(baseline: baseline-drop)[Lua#LaTeX]]

