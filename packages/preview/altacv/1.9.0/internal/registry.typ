// The renderer bound to each column section in `data/sections.typ`.
// A new section needs a spec there, a renderer under `sections/`
// registered here, and a heading in `data/labels-en.toml`.

#import "../sections/awards.typ": _awards
#import "../sections/certificates.typ": _certificates
#import "../sections/education.typ": _education
#import "../sections/experience.typ": _volunteer, _work
#import "../sections/focus-areas.typ": _focus-areas
#import "../sections/languages.typ": _languages
#import "../sections/projects.typ": _projects
#import "../sections/publications.typ": _publications
#import "../sections/references.typ": _references
#import "../sections/skills.typ": _interests, _skills
#import "data/sections.typ": _section-specs

// Renderers take `(entries, ctx)`, `ctx` being `(labels, prefs,
// format-date, owner, owners)`.
#let _renderers = (
  work: _work,
  volunteer: _volunteer,
  focus-areas: _focus-areas,
  skills: _skills,
  languages: _languages,
  education: _education,
  certificates: _certificates,
  awards: _awards,
  projects: _projects,
  publications: _publications,
  interests: _interests,
  references: _references,
)

// Checked at load, as `data/` can't hold its renderers: a spec without
// one would otherwise surface as a bare missing-key error in `alta()`.
#assert.eq(
  _renderers.keys().sorted(),
  _section-specs.keys().sorted(),
  message: "every section in data/sections.typ needs a renderer here, and vice versa",
)
