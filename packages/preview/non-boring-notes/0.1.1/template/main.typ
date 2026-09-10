#import "@preview/non-boring-notes:0.1.0": *

#show: template.with(
  title: [Document Title],
  subtitle: [Optional Subtitle],
  short_title: "Notes",
  description: [Document description],
  abstract: [
    Your abstract or brief summary goes here.
  ],
  creation_date: datetime.today(),
  authors: (
    (
      name: "Your Name",
      link: "https://example.com",
    ),
  ),
  paper_size: "us-letter",
  cols: 1,
  h1_prefix: "lecture",
  text_lang: "en",
)

= Introduction

Start writing your notes here...
