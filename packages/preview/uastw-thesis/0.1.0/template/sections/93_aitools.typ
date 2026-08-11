#let lightgray = rgb("#EEEEEE")

#heading(outlined: true, bookmarked: true, numbering: none)[Documentation table of AI-based tools] 

#figure(
  table(
		columns: (auto, 1fr, 1fr),
		align: left, 
		fill: (x, y) => if y == 0 { lightgray },
		table.header([*AI-based tools*], [*Intended use*],[*Prompt, source, page, paragraph...*],),
		[*DeepL Translate*], [Translation of an article in English], [Source (XXX), Chapter X on page X-X],
		[*ChatGPT (4.0)*], [Grammar and spelling], ["Please list issues with spelling and grammar in the following text: ..." Entire document]
    ),
)

