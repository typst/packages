#import "../types.typ" as z;
#import "../coercions.typ" as coerce;

#let author = z.dictionary(
  aliases: (
    "affiliation": "affiliations",
    "website": "url",
    "homepage": "url",
    "ORCID": "orcid",
    "equal_contributor": "equal-contributor",
    "equalContributor": "equal-contributor",
  ),
  (
    name: z.string(),
    url: z.string(optional: true),
    phone: z.string(optional: true),
    fax: z.string(optional: true),
    orcid: z.string(optional: true),
    note: z.string(optional: true),
    email: z.email(optional: true),
    corresponding: z.boolean(optional: true),
    equal-contributor: z.boolean(optional: true),
    deceased: z.boolean(optional: true),
    roles: z.array(z.string(), pre-transform: coerce.array),
    affiliations: z.array(
      z.either(
        z.string(),
        z.number(),
      ),
      pre-transform: coerce.array,
    ),
  ),
  pre-transform: coerce.dictionary(it => (name: it)),
  post-transform: (self, it) => {
    if (it.at("email", default: none) != none and "corresponding" not in it) {
      it.insert("corresponding", true)
    }
    return it
  },
)
