#import "@preview/tcdm:0.0.4": load, md, placeholder

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

#body

#if "markdown_footer_file" in configuration {
  md.render(
    md.preprocess(read("/" + configuration.markdown_footer_file), ..statistics),
    ..md.config,
  )
}
