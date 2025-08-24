#import "../util/typing.typ" as t
#import "../util/is.typ"


#let author = t.dictionary(
  (
    name: t.string(),
    email: t.email(optional: true),
    github: t.string(optional: true),
    urls: t.array(t.url(), optional: true, pre-transform: t.coerce.array),
    affiliation: t.string(optional: true),
  ),
  pre-transform: (self, it) => {
    if is.str(it) {
      let name-match = it.match(regex("^[^<]+"))
      let info = (
        name: if name-match != none { name-match.text.trim() } else { it },
      )

      let info-matches = it.matches(regex("<([^>]+?)>"))
      for m in info-matches {
        let _info = m.captures.last()
        if _info.starts-with("@") {
          info.insert("github", _info.trim("@"))
        } else if _info.starts-with("http") {
          info.insert("urls", (_info,))
        } else if "@" in _info {
          info.insert("email", _info)
        }
      }
      return info
    } else {
      return it
    }
  },
  aliases: (
    url: "urls",
  ),
)

#let package = t.dictionary((
  name: t.string(),
  version: t.version(),
  entrypoint: t.string(),
  authors: t.array(author, pre-transform: t.coerce.array),
  license: t.string(),
  description: t.string(),
  homepage: t.url(optional: true),
  repository: t.url(optional: true),
  keywords: t.array(t.string(), optional: true),
  categories: t.array(
    t.choice((
      "components",
      "visualization",
      "model",
      "layout",
      "text",
      "scripting",
      "languages",
      "integration",
      "utility",
      "fun",
      "book",
      "paper",
      "thesis",
      "flyer",
      "poster",
      "presentation",
      "office",
      "cv",
    )),
    assertions: (t.assert.length.max(3),),
    optional: true,
  ),
  disciplines: t.array(
    t.choice((
      "agriculture",
      "anthropology",
      "archaeology",
      "architecture",
      "biology",
      "business",
      "chemistry",
      "communication",
      "computer-science",
      "design",
      "drawing",
      "economics",
      "education",
      "engineering",
      "fashion",
      "film",
      "geography",
      "geology",
      "history",
      "journalism",
      "law",
      "linguistics",
      "literature",
      "mathematics",
      "medicine",
      "music",
      "painting",
      "philosophy",
      "photography",
      "physics",
      "politics",
      "psychology",
      "sociology",
      "theater",
      "theology",
      "transportation",
    )),
    optional: true,
  ),
  compiler: t.version(optional: true),
  exclude: t.array(t.string(), optional: true),
))

#let template = t.dictionary((
  path: t.string(),
  entrypoint: t.string(),
  thumbnail: t.string(optional: true),
))

#let asset = t.dictionary((
  id: t.string(),
  src: t.string(),
  dest: t.string(),
))

#let document = t.dictionary(
  // typstyle off
  (
    // Document info
    title: t.content(),
    subtitle: t.content(optional: true),
    urls: t.array(t.url(), optional: true, pre-transform: t.coerce.array),
    date: t.date(pre-transform: t.optional-coerce(t.coerce.date), optional: true),
    abstract: t.content(optional: true),
    // General package-info
    // Will be pre-transform to the package dict
    // TODO: Should this be allowed to override package?
    // name: t.string(),
    // description: t.content(),
    // authors: t.array(author),
    // repository: t.url(optional: true),
    // version: t.version(),
    // license: t.string(),
    // Data loaded from typst.toml
    package: package,
    template: t.optional(template),
    // Options available to the theme
    theme-options: t.dictionary(
      (:),
      default: (:),
    ),
    // Configuration options
    show-index: t.boolean(default: true),
    show-outline: t.boolean(default: true),
    show-urls-in-footnotes: t.boolean(default: true),
    index-references: t.boolean(default: true),
    wrap-snippets: t.boolean(default: false),
    examples-scope: t.dictionary(
      (
        scope: t.dictionary((:)),
        imports: t.dictionary((:), optional: true),
      ),
      optional: true,
      pre-transform: t.coerce.dictionary(it => (scope: it)),
      post-transform: (_, it) => {
        if it == none {
          it = (:)
        }
        return (scope: (:), imports: (:)) + it
      },
    ),
    assets: t.array(
      asset,
      default: (),
      pre-transform: (_, it) => {
        if type(it) == dictionary {
          let assets = ()
          for (id, spec) in it {
            assets.push((
              id: id,
              src: if type(spec) == str { spec } else { spec.src },
              dest: if type(spec) == str { id } else { spec.at("dest", default: id) },
            ))
          }
          return assets
        } else {
          return it
        }
      },
    ),
    // Git info
    git: t.dictionary(
      (
        branch: t.string(default: "main"),
        hash: t.string(),
      ),
      optional: true,
      pre-transform: t.coerce.dictionary(it => if it != none { (hash: it) } else { none }),
    ),
  ),

  pre-transform: (self, it) => {
    // If package info is not loaded from typst.toml,
    // a faux package entry is created.
    if "package" not in it {
      it.insert("package", (entrypoint: ""))
    }
    // User supplied keys are moved to the "package"
    // dictionary and may overwrite data from typst.toml.
    for key in ("name", "description", "repository", "version", "license") {
      if key in it {
        it.package.insert(key, it.remove(key))
      }
    }

    // Mantys allows for authors to have more fields than package authors.
    if "authors" in it {
      it.package.insert("authors", it.remove("authors"))
    }
    if "author" in it {
      it.package.insert("authors", it.remove("author"))
    }

    // Set empty title
    if "title" not in it and "name" in it.package {
      if "template" in it {
        it.insert("title", [The #sym.quote#it.package.name#sym.quote template])
      } else {
        it.insert("title", [The #sym.quote#it.package.name#sym.quote package])
      }
    }
    it
  },
  aliases: (
    url: "urls",
    author: "authors",
  ),
)
