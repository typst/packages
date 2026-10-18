// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: (C) 2025 Andreas Hartmann <hartan@7x.de>
#import "@preview/cloudy:0.2.0"
#import "@preview/suiji:0.4.0"

#let languages = (
    // SPDX-SnippetBegin
    // SPDX-License-Identifier: MIT
    // SPDX-FileCopyrightText: Copyright (c) 2023 nvim-tree
    // SPDX-FileComment: Icons and Colors taken from \
    //                   <https://github.com/nvim-tree/nvim-web-devicons>
    "Bash": (icon: "", color: "#447028", url: "https://www.gnu.org/software/bash/"),
    "C": (icon: "", color: "#3B69AA", url: "https://www.c-language.org/"),
    "Go": (icon: "", color: "#0082A2", url: "https://go.dev/"),
    "Haskell": (icon: "", color: "#6B4D83", url: "https://www.haskell.org/"),
    "Julia": (icon: "", color: "#6C4B7C", url: "https://julialang.org/"),
    "JavaScript": (icon: "", color: "#666620", url: ""),
    "Lua": (icon: "", color: "#366B8A", url: "https://www.lua.org/"),
    "Makefile": (icon: "", color: "#526064", url: "https://www.gnu.org/software/make/"),
    "Python": (icon: "", color: "#805E02", url: "https://www.python.org/"),
    "R": (icon: "󰟔", color: "#1A4C8C", url: "https://www.r-project.org/"),
    "Ruby": (icon: "", color: "#701516", url: "https://www.ruby-lang.org/en/"),
    "Rust": (icon: "", color: "#6F5242", url: "https://rust-lang.org"),
    "Tex": (icon: "", color: "#3D6117", url: ""),
    "Typst": (icon: "", color: "#097D80", url: "https://typst.app/"),
    "Zig": (icon: "", color: "#7B4D0E", url: "https://ziglang.org/"),
    // SPDX-SnippetEnd
)

// Shuffle languages into a random order so it looks nicer
#let rng = suiji.gen-rng-f(636)
#let (rng, shuffled_language_pairs) = suiji.shuffle(rng, languages.pairs())
#let shuffled_languages = shuffled_language_pairs.to-dict()

// Scale languages in size according to my personal preference.
#let scaling = (
    Typst: 2,
    Rust: 1.8,
    Bash: 1.6,
    Lua: 1.6,
    Julia: 1.4,
    Makefile: 1.4,
)

#set page(width: 7cm, height: 3.5cm, margin: 0pt)
#set text(font: ("Carlito", "SauceCodePro NF"))
#cloudy.cloud(
    shuffled_languages
        .pairs()
        .map(((lang, obj)) => {
            let label = box(
                // Leave a little space between adjacent items
                inset: 2pt,
                text(
                    fill: rgb(obj.color),
                    size: scaling.at(lang, default: 1.0) * 1em,
                )[#obj.icon~~#lang],
            )

            if obj.at("url", default: "") != "" {
                link(obj.url, label)
            } else {
                label
            }
        }),
)
