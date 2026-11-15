#import "../../../host/lib.typ" as host

// The editor parses BibTeX mechanically; identity, keys and merging are decided here.
#let bibtex-identity = (
  doi: value => lower(value
    .trim()
    .replace(regex("^https?://(dx\\.)?doi\\.org/"), "")),
  eprint: value => lower(
    value
      .trim()
      .replace(
        regex(
          "^(arXiv:|https?://arxiv\\.org/(abs|pdf)/|(https?://doi\\.org/)?10\\.48550/arXiv\\.)",
        ),
        "",
      )
      .replace(regex("\\.pdf$"), "")
      .replace(regex("v\\d+$"), ""),
  ),
  url: value => value
    .trim()
    .replace(regex("#.*$"), "")
    .replace(regex("/$"), ""),
  file: value => value.trim(),
)
#let bibtex-order = (
  "author",
  "title",
  "year",
  "journal",
  "booktitle",
  "doi",
  "url",
  "eprint",
  "archiveprefix",
  "primaryclass",
  "file",
)

#let bibtex-lines(fields) = {
  let clean(value) = value
    .replace(regex("\\s+"), " ")
    .trim()
    .replace(regex("[{}]"), "")
  let extra = fields.keys().filter(name => name not in bibtex-order).sorted()
  (bibtex-order.filter(name => name in fields) + extra)
    .filter(name => clean(fields.at(name)) != "")
    .map(name => "  " + name + " = {" + clean(fields.at(name)) + "},")
}

// Existing entries keep their text and key; a duplicate only gains missing fields.
#let merge-bibliography(bib, asset, read-file) = {
  let before = bib.before
  if before != none {
    // Binds the editor's parsed spans to the text this plan replaces.
    assert.eq(
      read-file(bib.path),
      before,
      message: "bibliography changed; retry capture",
    )
  }
  let entry = bib.entry
  assert(
    entry.type.contains(regex("^[a-zA-Z]+$")),
    message: "unsupported bibliography type",
  )
  assert(
    entry.fields.values().all(value => type(value) == str),
    message: "bibliography fields must be text",
  )
  let fields = entry.fields
  if asset != none { fields.insert("file", asset.path) }
  let same(old, field) = {
    let normalize = bibtex-identity.at(field)
    let value = normalize(fields.at(field, default: ""))
    value != "" and value == normalize(old.fields.at(field, default: ""))
  }
  let duplicate = bib.entries.find(old => bibtex-identity
    .keys()
    .any(field => same(old, field)))
  let key = entry.key
  if duplicate == none {
    let title(values) = lower(values.at("title", default: "").trim())
    let clash = bib.entries.find(old => old.key == key)
    if clash != none and title(clash.fields) == title(fields) {
      duplicate = clash
    } else if clash != none {
      let n = 2
      while bib.entries.any(old => old.key == key + "-" + str(n)) { n += 1 }
      key += "-" + str(n)
    }
  }
  if duplicate != none { key = duplicate.key }
  assert(
    key.contains(regex("^[a-zA-Z0-9_:.-]+$")),
    message: "unsupported bibliography key",
  )
  let content = if duplicate == none {
    let base = if before == none { "" } else { before }
    let gap = if base == "" { "" } else if base.ends-with("\n") { "\n" } else {
      "\n\n"
    }
    let lines = (
      ("@" + entry.type + "{" + key + ",",) + bibtex-lines(fields) + ("}",)
    )
    base + gap + lines.join("\n") + "\n"
  } else {
    let lines = bibtex-lines(
      fields
        .pairs()
        .filter(((name, _)) => name not in duplicate.fields)
        .to-dict(),
    )
    if lines == () { before } else {
      let text = before.slice(duplicate.start, duplicate.end)
      let head = text.slice(0, -1).trim(at: end)
      if not head.ends-with(",") { head += "," }
      (
        before.slice(0, duplicate.start)
          + head
          + "\n"
          + lines.join("\n")
          + "\n"
          + text.slice(-1)
          + before.slice(duplicate.end)
      )
    }
  }
  (path: bib.path, key: key, before: before, content: content)
}

// Project callbacks retain project-relative I/O and application policy.
// `existing(key, nodes)` may map a bibliography key to a card made before the registry.
#let plan(
  req,
  nodes: (),
  settings: none,
  read-file: none,
  allocate-id: none,
  note-path: none,
  register-note: none,
  verification: none,
  existing: (key, nodes) => none,
  registry-path: ".zettypst/captures.json",
) = {
  assert(
    req
      .keys()
      .all(key => (
        key
          in (
            "kind",
            "title",
            "abstract",
            "keywords",
            "selection",
            "url",
            "metadata",
            "asset",
            "bibliography",
            "now",
          )
      )),
    message: "unknown capture field",
  )
  assert(req.kind in ("web", "paper", "paper-note"))
  assert(type(req.title) == str and req.title.trim() != "")
  assert(
    type(req.abstract) == str
      and type(req.selection) == str
      and type(req.url) == str,
  )
  assert(
    type(req.keywords) == array and req.keywords.all(it => type(it) == str),
  )
  assert(type(req.metadata) == dictionary)
  let asset = req.at("asset", default: none)
  if asset != none {
    assert(asset.sha256.contains(regex("^[0-9a-f]{64}$")))
    assert.eq(asset.path, "assets/" + asset.sha256 + ".pdf")
  }
  let effects = ()
  let bib = req.at("bibliography", default: none)
  if bib != none {
    assert.eq(
      bib.path,
      settings.bibliography-path,
      message: "bibliography path differs from project capture config",
    )
    bib = merge-bibliography(bib, asset, read-file)
    req.bibliography = bib
    if bib.before == none {
      effects.push(host.create(bib.path, bib.content))
    } else if bib.content != bib.before {
      effects.push(host.replace(bib.path, bib.before, bib.content))
    }
  }
  let registry-before = read-file(registry-path)
  let registry = json(bytes(registry-before))
  let identity = if bib != none { "bib:" + bib.key } else { "url:" + req.url }
  let prior = registry.at(identity, default: none)
  if prior == none and asset != none {
    prior = registry
      .values()
      .find(record => record.at("sha256", default: none) == asset.sha256)
  }
  let id = if prior != none { prior.id } else if bib != none {
    existing(bib.key, nodes)
  }
  if id != none and not nodes.any(node => node.id == id) { id = none }
  let created = id == none
  if created { id = allocate-id(req.now) }
  let path = if created { note-path(id) } else {
    nodes.find(note => note.id == id).path
  }
  if created {
    let body = settings.render(req, id)
    if bib != none { body += "Source: #cite(label(" + repr(bib.key) + "))\n\n" }
    if req.url != "" { body += "#link(" + repr(req.url) + ")[Source URL]\n\n" }
    if asset != none {
      body += "#link(" + repr("../" + asset.path) + ")[Local PDF]\n\n"
    }
    if req.selection != "" {
      body += "#text(" + repr(req.selection) + ")\n"
    } else if req.abstract != "" {
      body += "#text(" + repr(req.abstract) + ")\n"
    }
    effects.push(host.create(path, body))
    effects += register-note(path)
  }
  let record = (id: id, note: path, kind: req.kind, url: req.url)
  if bib != none { record += (key: bib.key) }
  if asset != none { record += (file: asset.path, sha256: asset.sha256) }
  registry.insert(identity, record)
  let registry-after = json.encode(registry)
  if registry-before != registry-after {
    effects.push(host.replace(registry-path, registry-before, registry-after))
  }
  effects += settings.extra-effects(req, id, path)
  let key = if bib != none { bib.key }
  host.plan(
    effects,
    verification((
      id: id,
      path: path,
      title: req.title,
      created: created,
      identity: identity,
      key: key,
    )),
    result: (created: created, key: key),
  )
}

// Checks the post-state graph and registry; effect text is applied mechanically.
#let verify(
  intent,
  nodes: (),
  read-file: none,
  registry-path: ".zettypst/captures.json",
) = {
  let matches = nodes.filter(note => note.id == intent.id)
  assert.eq(matches.len(), 1)
  let note = matches.first()
  assert.eq(note.path, intent.path)
  if intent.created { assert.eq(note.title, intent.title) }
  assert.eq(
    json(bytes(read-file(registry-path))).at(intent.identity).id,
    intent.id,
  )
  note
}
