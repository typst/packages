// Each node carries a `kind` tag so the engines can dispatch on
// structural type without ad-hoc type sniffing.

#let str-type     = (kind: "str")
#let content-type = (kind: "content")
#let number-type  = (kind: "number")

#let array-of(elem) = (kind: "array", elem: elem)

// Default `()` preserves the canonical schema's all-optional stance.
// Extension schemas opt in per-section; the validator emits
// "missing required key" when an absent key is required. Reject
// required-keys that don't appear in shape so a schema typo fails at
// schema-construction time instead of as a phantom validation error.
#let object(shape, required-keys: ()) = {
  let unknown = required-keys.filter(k => k not in shape)
  assert(
    unknown.len() == 0,
    message: "json-resume: object() required-keys references keys not in shape: " +
      unknown.join(", ") + ".",
  )
  (
    kind: "object",
    shape: shape,
    required-keys: required-keys,
  )
}

// Canonical JSON Resume schema (https://jsonresume.org/schema).
// All fields optional, types checked when present. Format checks for
// dates / URLs / emails are v0.2+ work.

#let _location = object((
  address: str-type,
  postalCode: str-type,
  city: str-type,
  countryCode: str-type,
  region: str-type,
))

#let _profile = object((
  network: str-type,
  username: str-type,
  url: str-type,
))

#let _basics = object((
  name: str-type,
  label: str-type,
  image: str-type,
  email: str-type,
  phone: str-type,
  url: str-type,
  summary: content-type,
  location: _location,
  profiles: array-of(_profile),
))

#let _work-item = object((
  name: str-type,
  location: str-type,
  description: str-type,
  position: str-type,
  url: str-type,
  startDate: str-type,
  endDate: str-type,
  summary: content-type,
  highlights: array-of(content-type),
))

#let _volunteer-item = object((
  organization: str-type,
  position: str-type,
  url: str-type,
  startDate: str-type,
  endDate: str-type,
  summary: content-type,
  highlights: array-of(content-type),
))

#let _education-item = object((
  institution: str-type,
  url: str-type,
  area: str-type,
  studyType: str-type,
  startDate: str-type,
  endDate: str-type,
  score: str-type,
  courses: array-of(str-type),
))

#let _award = object((
  title: str-type,
  date: str-type,
  awarder: str-type,
  summary: content-type,
))

#let _certificate = object((
  name: str-type,
  date: str-type,
  url: str-type,
  issuer: str-type,
))

#let _publication = object((
  name: str-type,
  publisher: str-type,
  releaseDate: str-type,
  url: str-type,
  summary: content-type,
))

#let _skill = object((
  name: str-type,
  level: str-type,
  keywords: array-of(str-type),
))

#let _language = object((
  language: str-type,
  fluency: str-type,
))

#let _interest = object((
  name: str-type,
  keywords: array-of(str-type),
))

#let _reference = object((
  name: str-type,
  reference: content-type,
))

#let _project = object((
  name: str-type,
  description: content-type,
  highlights: array-of(content-type),
  keywords: array-of(str-type),
  startDate: str-type,
  endDate: str-type,
  url: str-type,
  roles: array-of(str-type),
  entity: str-type,
  type: str-type,
))

#let _meta = object((
  canonical: str-type,
  version: str-type,
  lastModified: str-type,
))

#let resume-schema = object((
  "$schema": str-type,
  basics: _basics,
  work: array-of(_work-item),
  volunteer: array-of(_volunteer-item),
  education: array-of(_education-item),
  awards: array-of(_award),
  certificates: array-of(_certificate),
  publications: array-of(_publication),
  skills: array-of(_skill),
  languages: array-of(_language),
  interests: array-of(_interest),
  references: array-of(_reference),
  projects: array-of(_project),
  meta: _meta,
))
