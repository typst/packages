// A starting point for a Prinzipien deck. Prinzipien follows Jean-luc
// Doumont's principle of one message per slide: every `==` heading is the
// single message of its slide, and the body only supports it. Replace the
// placeholder content below with your own.

#import "@preview/prinzipien:0.1.1": *

#show: prinzipien-theme.with(
  config-info(
    title: [One sentence to remember],
    subtitle: [A line that supports the title],
    author: [Your Name],
    institution: [Your Institution],
    date: datetime.today(),
  ),
)

#title-slide()

== Give every slide a full-sentence message

The heading carries the takeaway; keep the body to a single
supporting thought.

// `#point` marks a main point of the talk; `#preview` shows the map of
// the points that are coming.
#preview()

#point(substatement: [Design everything else around it])[
  State one message per slide
]

== Emphasise only the words that carry the message

Mark what matters with #alert[a single accent], nothing more.

#point(substatement: [One accent colour, plus tints of it])[
  Let one colour do the work
]

== Keep the palette to one accent and its tints

Colour guides attention; more colours only compete for it.

// `#review` recaps the points before the conclusion.
#review()

== Your next deck can start from this file

Replace the placeholders with your content, one message per slide.
