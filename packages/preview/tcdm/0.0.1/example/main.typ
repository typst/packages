#import "@preview/tcdm:0.0.1": load, md, placeholder

#let (configuration, statistics, assets, body) = load(
  projects-data: json(placeholder.latest-history-json),
  projects-yaml: yaml(placeholder.projects-yaml),
)

#set text(lang: "en")
#set document(
  title: "Best of Typst (TCDM)",
  description: [
    A ranked list of awesome projects related to Typst,
    or the charted dark matter in Typst Universe (TCDM).
  ],
  author: "YDX-2147483647",
  keywords: ("typst", "community", "best-of", "tooling"),
)
#assets

#show: html.main

#md.render(
  md.preprocess(
    if "markdown_header_file" in configuration {
      read("/" + configuration.markdown_header_file)
    } else {
      placeholder.header-md
    },
    ..statistics,
  ),
  ..md.config,
)

#quote(block: true)[
  💡 We are migrating the website generator from Pandoc to Typst.
  If you encounter any issue, please #link("https://github.com/YDX-2147483647/best-of-typst/issues/39")[report it in GitHub Issue \#39].
  (The old version is still alive at #link("./pandoc.html", `pandoc.html`).)
]

#body

#if "markdown_footer_file" in configuration {
  md.render(
    md.preprocess(read("/" + configuration.markdown_footer_file), ..statistics),
    ..md.config,
  )
}
