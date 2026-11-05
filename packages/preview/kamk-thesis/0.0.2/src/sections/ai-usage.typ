// Load the translations
#let lang-data = toml("../data/lang.toml")

// A bold label followed by its content on the next line.
#let ai-usage-item(label, body) = {
  block(width: 100%)[
    #strong(label)
    #parbreak()
    #body
  ]
}

// Template-generated AI-usage disclosure;
// only `tools` and `usage` are author-supplied.
#let render-ai-usage(
  language: "fi",
  tools: none,
  usage: none,
) = {
  let d = lang-data.at(language)

  heading(
    level: 1,
    outlined: true,
    numbering: none,
    d.ai_usage_title,
  )

  strong(d.ai_usage_intro)

  ai-usage-item(
    d.ai_usage_tools_label + ":",
    tools,
  )

  v(1em)

  ai-usage-item(
    d.ai_usage_purpose_label + ":",
    usage,
  )

  v(1em)

  d.ai_usage_declaration
}