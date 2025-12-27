#import "@preview/tcdm:0.0.1": load, md
#let (configuration, statistics, assets, body) = load(
  projects-data: json("/build/latest.json"),
  projects-yaml: yaml("/projects.yaml"),
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
  md.preprocess(read("/" + configuration.markdown_header_file), ..statistics),
  ..md.config,
)

#quote(block: true)[
  💡 We are migrating the website generator from Pandoc to Typst.
  If you encounter any issue, please #link("https://github.com/YDX-2147483647/best-of-typst/issues/39")[report it in GitHub Issue \#39].
  (The old version is still alive at #link("./pandoc.html", `pandoc.html`).)
]

#body

#md.render(
  md.preprocess(read("/" + configuration.markdown_footer_file), ..statistics),
  ..md.config,
)
