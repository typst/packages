#import "@preview/sapians-slides:0.3.2": * // x-release-please-version

#show: sapians-slides.with(
  title: "Presentation Title",
  author: "Author Name",
)

// 01 Cover
#slide-cover(
  title: "SAPIANS",
  subtitle: "A Clear, One-Line Statement\nof What This Deck Argues",
  author: "Author Name",
  affiliation: "Your Team or Institution",
  dark: true,
  // `note:` lands in the pdfpc sidecar: scripts/export_pdfpc.sh main.typ
  note: "Welcome the audience and state the one thing they should remember.",
)

// 02 Problem
#slide-problem(
  title: "TOPIC",
  section: "DIAGNOSIS",
  counter: "02 / 06",
  hero: "State the problem\nin one strong sentence.",
  subtext: "One supporting sentence explaining why the problem matters and what it costs.",
  question-label: "THE QUESTION",
  question: "What is the single question\nthis deck answers?",
  visual: block(
    fill: sapians-white,
    stroke: stroke-light,
    radius: radius-sm,
    inset: 4mm,
    [
      #kicker("KEY DIRECTIVE")
      #v(1.5mm)
      #text(
        size: 7.5pt,
        weight: "bold",
        fill: sapians-text-dark,
      )[A short, memorable statement that frames the argument.]
    ],
  ),
)

// 03 Definition blocks
#slide-definition(
  title: "TOPIC",
  section: "ARCHITECTURE",
  counter: "03 / 06",
  hero: "Name the core idea\nin one line.",
  explanation: "One sentence expanding the idea: what it is made of and why it is structured this way.",
  definitions: (
    ("PART ONE", "What it does"),
    ("PART TWO", "What it does"),
    // `pause` splits the slide into steps: the entries below it keep their box
    // but stay hidden until you advance. Delete it for a static slide.
    pause,
    ("PART THREE", "What it does"),
    ("PART FOUR", "What it does"),
  ),
  note: "Walk through the first two parts, pause for questions, then reveal the rest.",
)

// 04 Three columns (Model | Code | Idea)
#slide-three-column(
  title: "TOPIC",
  section: "MECHANISM",
  counter: "04 / 06",
  column1-title: "THE CONCEPT",
  column1-content: block(
    fill: sapians-white,
    stroke: stroke-light,
    radius: radius-sm,
    inset: 3.5mm,
    height: 100%,
    [
      #text(size: 7.5pt, weight: "bold")[Concept headline]
      #v(1.5mm)
      #small-text(
        "One or two sentences describing the concept shown in this column.",
      )
    ],
  ),
  column1-caption: "One-line caption.",
  column2-title: "THE CODE",
  column2-code: [
    ```typst
    #import "@preview/sapians:0.3.0": *

    #show: sapians-slides.with(
      title: "Project Alpha",
    )

    #slide-cover(
      title: "SAPIANS",
      subtitle: "Deep Intelligence",
    )
    ```
  ],
  column3-title: "THE TAKEAWAY",
  column3-hero: "The point, in 3 words.",
  column3-sub: "One sentence connecting the concept and the code to the takeaway.",
  column3-footer: "Footer annotation.",
)

// 05 Contrast: Not This vs This
#slide-contrast(
  title: "GUIDELINES",
  section: "DECISION",
  counter: "05 / 06",
  hero: "What do we optimize for?",
  not-this-content: ["A common but wrong interpretation, quoted the way people say it."],
  this-content: ["The correct interpretation, stated just as concretely."],
  not-this-label: "NOT THIS",
  this-label: "THIS",
  this-sub: "CLARITY > NOISE",
)

// 06 Dark takeaway
#slide-takeaway(
  title: "TOPIC",
  section: "NEXT STEPS",
  counter: "06 / 06",
  hero: "Close with the single\nsentence they should remember.",
  subtext: "One line about what happens next or what you are asking the audience to do.",
  takeaway-title: "START NOW",
  takeaway-text: "TYPE: typst watch main.typ",
)
