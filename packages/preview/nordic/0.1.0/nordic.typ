// Blacks. Not in base Nord.
#let black0 = rgb("#191D24")
#let black1 = rgb("#1E222A")
// Slightly darker than bg.  Very useful for certain popups
#let black2 = rgb("#222630")

// Grays
// This color is used on their website"s dark theme.
#let gray0 = rgb("#242933")
// Polar Night.
#let gray1 = rgb("#2E3440")
#let gray2 = rgb("#3B4252")
#let gray3 = rgb("#434C5E")
#let gray4 = rgb("#4C566A")

// A light blue/gray.
// From @nightfox.nvim.
#let gray5 = rgb("#60728A")

// Dim white.
// default fg, has a blue tint.
#let white0-normal = rgb("#BBC3D4")
// less blue tint
#let white0-reduce-blue = rgb("#C0C8D8")

// Snow storm.
#let white1 = rgb("#D8DEE9")
#let white2 = rgb("#E5E9F0")
#let white3 = rgb("#ECEFF4")

// Frost.
#let blue0 = rgb("#5E81AC")
#let blue1 = rgb("#81A1C1")
#let blue2 = rgb("#88C0D0")

// cyan
#let cyan-base = rgb("#8FBCBB")
#let cyan-bright = rgb("#9FC6C5")
#let cyan-dim = rgb("#80B3B2")

// Aurora.
// These colors are used a lot, so we need variations for them.
// Base colors are from original Nord palette.
// red
#let red-base = rgb("#BF616A")
#let red-bright = rgb("#C5727A")
#let red-dim = rgb("#B74E58")

// orange
#let orange-base = rgb("#D08770")
#let orange-bright = rgb("#D79784")
#let orange-dim = rgb("#CB775D")

// yellow 
#let yellow-base = rgb("#EBCB8B")
#let yellow-bright = rgb("#EFD49F")
#let yellow-dim = rgb("#E7C173")

// green
#let green-base = rgb("#A3BE8C")
#let green-bright = rgb("#B1C89D")
#let green-dim = rgb("#97B67C")

// magenta
#let magenta-base = rgb("#B48EAD")
#let magenta-bright = rgb("#BE9DB8")
#let magenta-dim = rgb("#A97EA1")

#let default(body, show-todo: true) = {
    show heading.where(level: 1): set text(fill: yellow-bright)
    show heading.where(level: 2): set text(fill: orange-bright)
    show heading.where(level: 3): set text(fill: magenta-bright)
    show heading.where(level: 4): set text(fill: green-bright)

    set text(fill: white1)
    set page(fill: black0)

    show regex("TODO"): bd => {
        if show-todo {
            box(inset: 0pt, outset: 2pt, fill: gray2)[
                #text(stroke: 0.5pt + red-base)[#bd]
            ]
        } else {
            bd
        }
    }

    show cite: set text(fill: green-dim)

    body
}
