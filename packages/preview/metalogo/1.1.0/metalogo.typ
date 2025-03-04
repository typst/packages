// TODO: base should *actually* be lowered by 0.5ex, but Typst does not yet
// have an ex unit, only em. See https://github.com/typst/typst/issues/2405
#let baseline-drop = 0.22em

#let TeX = [#box[T#h(-.1667em)#box[#move(dy: baseline-drop)[E]]#h(-.125em)X]]
#let Xe = [#box[X#h(-.1667em)#box[#move(dy: baseline-drop)[#scale(x: -100%)[E]]]#h(-.125em)]]
#let LaTeX = [#box[L#h(-.33em)#box[#move(dy: -0.2em)[#text(0.7em)[A]]]#h(-.15em)#TeX]]
#let XeTeX = [#box[#Xe#TeX]]
#let XeLaTeX = [#box[#Xe#LaTeX]]
#let LuaLaTeX = [#box[Lua#LaTeX]]

