// Published NWO Talent Programme 2026 forms, checked 20 October 2026.
// Profile availability is explicit: do not silently relabel an older form.
#let domains = (
  science: [Science (ENW)], ssh: [Social Sciences and Humanities (SSH/SGW)],
  aes: [Applied and Engineering Sciences (AES/TTW)], zonmw: [Health Research and Development (ZonMw)],
)

/// Return the source and constraints for a supported NWO form.
///
/// Published 2026 pre-proposals and Vici full proposals are represented.
/// Unavailable combinations fail explicitly instead of inventing rules.
///
/// - scheme (str): `"veni"` (default), `"vidi"`, or `"vici"`
/// - domain (str): `"science"` (default), `"ssh"`, `"aes"`, or `"zonmw"`
/// - stage (str): `"pre"` (default) or `"full"`
/// - year (int): source-checked year; must be 2026
/// -> dictionary: `scheme`, `domain`, `domain-name`, `stage`, `year`, `source`,
///   `size`, and `limits`. `limits` maps each word-limited field to `(min:, max:)`.
#let nwo-profile(scheme: "veni", domain: "science", stage: "pre", year: 2026) = {
  assert(scheme in ("veni", "vidi", "vici"), message: "NWO scheme must be veni, vidi or vici.")
  assert(domain in domains, message: "NWO domain must be science, ssh, aes or zonmw.")
  assert(stage in ("pre", "full"), message: "NWO stage must be pre or full.")
  assert(type(year) == int and year == 2026, message: "Only integer year 2026 has source-checked NWO profiles.")
  assert(stage != "full" or scheme == "vici", message: "The Veni/Vidi 2026 full-proposal forms are not yet represented; do not substitute the old LaTeX form.")
  assert(not (stage == "pre" and scheme == "vici" and domain == "zonmw"),
    message: "The Vici 2026 ZonMw pre-proposal source was unavailable; this profile is not yet verified.")
  let files = (
    veni: "veni_pre-proposal_form_2026.docx",
    vidi: "Vidi-2026-Pre-proposal-form.docx",
    vici: "Vici-2026-pre-proposal-form_3.docx",
  )
  let source = if stage == "full" {
    if domain == "zonmw" { "https://www.zonmw.nl/sites/zonmw/files/2026-07/Vici-2026-Full-proposal-form-ZonMw.docx" }
    else { "https://www.nwo.nl/sites/nwo/files/media-files/vici-2026-full-proposal-form_2.docx" }
  } else if domain == "zonmw" {
    if scheme == "veni" { "https://www.zonmw.nl/sites/zonmw/files/2026-07/Veni-2026-Pre-proposal-form-ZonMw.docx" }
    else { "https://www.zonmw.nl/sites/zonmw/files/2026-08/Vidi-2026-Pre-proposal-form-ZonMw_2.docx" }
  } else { "https://www.nwo.nl/sites/nwo/files/media-files/" + files.at(scheme) }
  let ideas = if scheme == "veni" { if domain == "science" { 500 } else { 100 } } else { 150 }
  (
    scheme: scheme, domain: domain, domain-name: domains.at(domain), stage: stage,
    year: year, source: source,
    size: if stage == "pre" { 9.5pt } else { 10pt },
    limits: if stage == "pre" {
      (
        academic-profile: (min: if scheme == "veni" { 400 } else { 0 }, max: if scheme == "veni" { 700 } else { 1200 }),
        key-output: (min: if scheme == "veni" { 400 } else { 0 }, max: 700),
        research-culture: (min: 0, max: 50), research-idea: (min: 0, max: ideas),
        special-circumstances: (min: 0, max: 100),
      )
    } else {
      (
        scientific-summary: (min: 0, max: 300),
        public-summary-nl: (min: 50, max: 100), public-summary-en: (min: 50, max: 100),
      )
    },
  )
}
