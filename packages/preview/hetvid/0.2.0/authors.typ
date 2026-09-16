// Multi-author rendering for hetvid template.
// Backward-compatible: if `author` is a string or content (old syntax),
// render it together with `old-affiliation` as before.

// Collect unique affiliations and compute per-author numbering.
// Returns (affil-list, author-nums) where author-nums is an array of
// arrays of 1-based indices into affil-list.
#let _collect-affils(authors) = {
  let affil-list = ()
  let author-nums = ()

  for author in authors {
    let affils = if "affiliation" not in author {
      ()
    } else if type(author.affiliation) == array {
      author.affiliation
    } else {
      (author.affiliation,)
    }

    // For each affiliation, find or insert into affil-list.
    let (al, nums) = affils.fold(
      (affil-list, ()),
      ((al, ns), affil) => {
        let r = repr(affil)
        let idx = al.position(x => repr(x) == r)
        if idx == none {
          (al + (affil,), ns + (al.len() + 1,))
        } else {
          (al, ns + (idx + 1,))
        }
      },
    )
    affil-list = al
    author-nums.push(nums)
  }

  (affil-list, author-nums)
}

// Render the author block.
// - authors: string, content, or array of dicts (name:, affiliation:, email:)
// - old-affiliation: the `affiliation` parameter from hetvid, used only in old single-author mode
// - emph-func: the emph show rule (pass `emph` or a custom function)
#let format-authors(authors, old-affiliation: none, emph-func: emph) = {
  if type(authors) == array {
    let (affil-list, author-nums) = _collect-affils(authors)
    let show-affil-nums = affil-list.len() > 1

    // Render "Name^(1,2), Name^(2,3), ..."
    let rendered = authors.enumerate().map(((i, author)) => {
      let nums = author-nums.at(i)
      let has-email = "email" in author and author.email != none and author.email != ""
      let name-part = if show-affil-nums and nums.len() > 0 {
        [#author.name#super(nums.sorted().map(str).join(","))]
      } else {
        author.name
      }
      if has-email {
        let email-str = if type(author.email) == str { author.email } else { repr(author.email) }
        [#name-part#footnote(numbering: _ => [])[#author.name: #raw(email-str)]]
      } else {
        name-part
      }
    })
    rendered.join([, ])


    // Render numbered affiliations (one per line)
    if show-affil-nums {
      v(1.2em, weak: true)
      for (i, affil) in affil-list.enumerate() {
        [#super(str(i + 1))#emph[#affil]]
        if i < affil-list.len() - 1 { linebreak() }
      }
    } else if affil-list.len() == 1 {
      // Single unique affiliation across all authors — no numbering needed
      emph-func(affil-list.at(0))
    }
  } else {
    // Old single-author mode
    authors
    if old-affiliation != none and old-affiliation != [] {
      linebreak()
      emph-func(old-affiliation)
    }
  }
}
