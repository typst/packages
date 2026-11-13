/// Check a plain-text response against the chosen form's word limits.
///
/// Counts whitespace-separated words, then prints the response and its count.
/// For rich content with figures or citations, use ordinary markup and verify
/// the full official word count, including all counted material, externally.
/// Must be called inside `nwo-proposal`.
///
/// - field (str): a limit key from the active profile. Pre-proposals use
///   `academic-profile`, `key-output`, `research-culture`, `research-idea`, or
///   `special-circumstances`; Vici full proposals use `scientific-summary`,
///   `public-summary-nl`, or `public-summary-en`
/// - response (str): plain-text response; rich content is rejected
#let nwo-text(field, response) = context {
  let profile = state("satz-nwo-profile").get()
  assert(type(profile) == dictionary, message: "Use nwo-text inside nwo-proposal.")
  assert(type(field) == str, message: "nwo-text field must be a string.")
  assert(type(response) == str, message: "nwo-text accepts plain strings, not rich content.")
  assert(field in profile.limits, message: "Unknown word-limited field for this NWO form: " + field)
  let limits = profile.limits.at(field)
  let count = response.matches(regex("\S+")).len()
  assert(count >= limits.min and count <= limits.max,
    message: "NWO " + field + " requires " + str(limits.min) + "–" + str(limits.max) + " words; got " + str(count) + ".")
  set text(lang: if field == "public-summary-nl" { "nl" } else { "en" })
  response
  parbreak()
  text(size: profile.size, style: "italic")[Word count: #count]
}

/// A narrative-CV key output with explicit contribution.
///
/// Bibliographic reference, URL, type, and indicators are separated from the
/// narrative so authors can apply the form's exclusions when counting key-output
/// words. Must be used inside `nwo-proposal`; at most ten key outputs per document.
///
/// ```example
/// #nwo-key-output(
///   reference: [Example et al. (2026). Example paper.],
///   output-type: [Journal article],
///   contribution: [Designed the study and analysed the data.],
///   urls: ("https://example.org/paper",),
/// )
/// ```
///
/// - reference (content, str): bibliographic reference; defaults to empty
/// - output-type (content, str): output type; defaults to empty
/// - contribution (content, str): explicit contribution; defaults to empty
/// - indicators (array of content, str): up to three indicators
/// - urls (array of str): up to two URLs (output and open-access copy)
/// - open-access (bool, none): open-access status; `none` prints "Yes / No"
#let nwo-key-output(reference: [], output-type: [], contribution: [], indicators: (), urls: (), open-access: none) = {
  for (field, value) in (("reference", reference), ("output-type", output-type), ("contribution", contribution)) {
    assert(type(value) == content or type(value) == str,
      message: "NWO key-output `" + field + "` must be a string or content.")
  }
  assert(type(indicators) == array and indicators.all(i => type(i) == content or type(i) == str),
    message: "NWO indicators must be an array of strings or content.")
  assert(type(urls) == array and urls.all(u => type(u) == str),
    message: "NWO URLs must be an array of strings.")
  assert(indicators.len() <= 3, message: "NWO permits at most three indicators per key output.")
  assert(urls.len() <= 2, message: "Use at most two URLs: output and open-access copy.")
  assert(open-access == none or type(open-access) == bool, message: "open-access must be true, false or none.")
  counter("satz-nwo-output").step()
  [#metadata("key-output") <satz-nwo-key-output>]
  block(breakable: false, stroke: 0.5pt + luma(80%), inset: 8pt)[
    #context strong[Key output #counter("satz-nwo-output").display("1")]
    #h(1fr)
    Open access: #if open-access == none [Yes / No] else if open-access [Yes] else [No]
    #parbreak()
    #strong(reference)
    #parbreak()
    #output-type
    #parbreak()
    #contribution
    #for indicator in indicators { parbreak(); indicator }
    #for url in urls { parbreak(); link(url) }
  ]
}

/// Check a bounded section's vertical extent, including its own headings.
///
/// Use a unique key and include every figure or table inside the scope.
/// Page-wide floats or placed content escaping the scope need separate visual
/// review. Fractional limits (e.g. Vici impact 2.5 pages) use the configured
/// text height. Must be called inside `nwo-proposal`.
///
/// - key (str): unique, non-empty section key used for the internal labels
/// - max-pages (int, float): allowed extent; defaults to 14
/// - body (content): the bounded section, including headings
#let nwo-page-budget(key, max-pages: 14, body) = {
  assert(type(key) == str and key.len() > 0, message: "NWO page-budget key must be a nonempty string.")
  assert((type(max-pages) == int or type(max-pages) == float) and max-pages > 0,
    message: "NWO max-pages must be a positive number.")
  let start = label("satz-nwo-start-" + key)
  let end = label("satz-nwo-end-" + key)
  [#metadata(key) #start]
  body
  [#metadata(key) #end]
  context {
    let starts = query(start)
    let ends = query(end)
    assert(starts.len() == 1 and ends.len() == 1, message: "Each NWO page-budget key must be unique.")
    let a = starts.first().location().position()
    let b = ends.first().location().position()
    let height = state("satz-nwo-page-height").get()
    assert(type(height) == length, message: "Use nwo-page-budget inside nwo-proposal.")
    let used = b.page - a.page + (b.y - a.y) / height
    assert(used <= max-pages + 0.001,
      message: "NWO section " + key + " exceeds " + str(max-pages) + " pages.")
  }
}
