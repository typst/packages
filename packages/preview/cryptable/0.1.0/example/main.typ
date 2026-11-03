
#set par(justify: true)
#set page(margin: (left: 2cm, right: 2cm, top: 1cm, bottom: 1cm), "a4")

#let size = 13

#import "@preview/cryptable:0.1.0": create-puzzle

#let positions = (
  7,
  14, 16, 18, 20, 22, 24,
  29,
  40, 42, 44, 46, 48, 50, 51,
  60,
  66, 67, 68, 70, 72, 74, 76,
  84
)

#let pos = (..positions, ..positions.map(i => size * size - i - 1))

#let (puzzle, clues) = create-puzzle(
    solution: false,
    13,
    pos,
)

#let across-words = (
    "BELOVED",
    "POSSE",
    "NAG",
    "REDUNDANT",
    "MOTHERLY",
    "REED",
    "AERIAL",
    "CORPUS",
    "SHUN",
    "SUSPENSE",
    "CRITICISE",
    "PAT",
    "BAYOU",
    "SPOILER"
)

#let down-words = (
    "BYNOMEANS",
    "LEGIT",
    "VARIETAL",
    "DODDLE",
    "PANT",
    "SHAKEUP",
    "ENT",
    "DISSENTER",
    "SORPRESO",
    "REUNIFY",
    "PUPILS",
    "NEPAL",
    "LIEU",
    "CUB"
)
#let across-clues = (
    "Precious",
    "Gang",
    "Scold",
    "Useless",
    "Overly protective",
    "Shallow-water grass",
    "In the air",
    "Body",
    "Avoid with intention",
    "Excitement",
    "Express disapproval of",
    "Touch with affection",
    "Marsh",
    "Structure on a sports car"
)

#let down-clues = (
    ("Not at all!", "2,2,5"),
    "Truthful",
    "Showing character",
    "That was easy!",
    "Breathe quickly",
    ("Fundamental change", "5,2"),
    "Tree creatures in The Lord of the Rings",
    "One who disagrees with hostility",
    "Surprise in Italy!",
    "Bring together again",
    "Students",
    "Country with the Mount Everest",
    "Fox baby",
    "Instead"
)

#let (puzzle, clues) = create-puzzle(
    solution: true,
    size,
    pos,
    across-words: across-words,
    down-words: down-words,
    across-clues: across-clues,
    down-clues: down-clues,
)

= My Beautiful Crossword
\ \ 
#align(center, puzzle)
\ \ 
#align(center, clues)
