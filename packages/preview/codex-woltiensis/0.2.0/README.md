# Codex Woltiensis

Highly customizable student songbook template that provides a macro system and a semantic format to describe songs, including metadata, lyrics, refrains, and various annotations. The goal is to simplify songbook creation while maintaining high typographic quality.

## ✨ Features

- **Semantic Song Definition**: Write songs using high-level, readable commands like `#header`, `#bis`, and custom footnotes.
- **Metadata Blocks**: Specify song metadata like melody (`air`), lyrics author (`paroles`), and comments using a structured format.
- **Line Duplication**: Automatically duplicate lines with `#bis()` and control the repetition count (`#bis(n:3)`).
- **Formatted Refrains**: Define language-specific refrains (`=== fr.`, `=== nl`) and support custom-styled chorus sections.
- **Rich Text Formatting**: Supports bold (`*bold*`), italics (`_italic_`), strikethrough (`#strike[...]`), underline (`#underline[...]`), and footnotes (`#note[...]`).
- **Multiline Bis**: Repeat entire blocks of lines using `#bis()[...]` with multiple lines.
- **Comment Annotations**: Provide context and background to each song using the `#header.commentaire` field.
- **Refrain Sections**: Clearly separate verses from refrains with dedicated syntax (`=== fr.`, `=== Refrain custom`, etc).

## 📄 Example

Here is a sample song using the Codex Woltiensis format:

```typst
== Song of Demonstration
#header(
  air: air(author: "Traditional")[The Drunken Sailor],
  paroles: paroles(date: "1850")[Anonymous],
  commentaire: com()[This song demonstrates all features of the Codex Woltiensis template in English, including repeats, formatting, footnotes, and structured metadata.]
)

What shall we do with a drunken sailor \
What shall we do with a drunken sailor \
What shall we do with a drunken sailor #bis() \
Early in the morning? \

Put him in the longboat till he's sober #bis(n:3) \
Put him in the scuppers with a hosepipe on him #bis(n:4) \
Shave his belly with a rusty razor #bis(n:69) \

=== fr.
_This is the chorus section \
Repeated after each verse \
May include footnotes #note()[Footnotes are useful for contextual notes] \
May be marked as en (English), nl (Dutch), fr (French), or custom._

This shows repeated multiline blocks \
#bis()[
Haul him up and let him dangle\
Haul him up and let him dangle\
Let the bosun give a warning\
]

=== nl

This stanza tests text formatting \
*Bold Text* \
_Italic Text_ \
#strike[Strikethrough Text] \
#underline[Underlined Text]

=== Custom Refrain
```
